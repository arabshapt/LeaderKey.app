// swiftlint:disable file_length
import Cocoa
import Combine
import Defaults
import Kingfisher
import os
import Settings
import Sparkle
import SwiftUI
import UserNotifications

let updateLocationIdentifier = "UpdateCheck"

// MARK: - Callback Optimization State
// Consolidated state struct to reduce associated object lookups
private struct CallbackOptimizationState {
  var hasPendingActivation: Bool = false
  var lastActivationTime: CFAbsoluteTime = 0
  var stickyModeKeycodes: Set<UInt16>? = nil  // Pre-computed for O(1) lookup
  // Note: Other state like currentSequenceGroup is kept separate as it's
  // accessed from many places and needs proper synchronization
}

// MARK: - Settings Panes

private struct OpacityPane: View {
  @Default(.normalModeOpacity) var normalModeOpacity
  @Default(.stickyModeOpacity) var stickyModeOpacity

  var body: some View {
    Settings.Container(contentWidth: SettingsConfig.contentWidth) {
      Settings.Section(title: "Opacity") {
        VStack {
          VStack(alignment: .leading) {
            Text("Normal Mode Opacity")
            Slider(value: $normalModeOpacity, in: 0.0...1.0)
            Text(String(format: "%.2f", normalModeOpacity))
          }
          VStack(alignment: .leading) {
            Text("Sticky Mode Opacity")
            Slider(value: $stickyModeOpacity, in: 0.0...1.0)
            Text(String(format: "%.2f", stickyModeOpacity))
          }
        }
        .frame(minHeight: 500)
      }
    }
  }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, InputMethodDelegate, UnixSocketServerDelegate {
  private struct KarabinerActivationContext {
    enum Mode: Hashable {
      case defaultOnly
      case appSpecificWithFallback
      case fallbackOnly
    }

    let mode: Mode
    let bundleId: String?
    let activatedAt: Date
  }

  private struct ActionCacheKey: Hashable {
    let stateId: Int32
    let mode: KarabinerActivationContext.Mode
    let bundleId: String?
  }

  // --- Properties ---
  var controller: Controller!
  var statusItem = StatusItem()
  let config = UserConfig()
  var fileMonitor: FileMonitor!
  var state: UserState!
  @IBOutlet var updaterController: SPUStandardUpdaterController!
  
  // State ID to action mapping for Karabiner 2.0
  private var stateMappings: [Int32: Karabiner2Exporter.StateMapping] = [:]
  private var actionCache: [ActionCacheKey: Action] = [:]
  private var stateMappingsLastLoaded: Date?
  private var cancellables = Set<AnyCancellable>()
  private let controlSocketServer = UnixSocketServer.shared
  private let exportRefreshQueue = DispatchQueue(label: "com.leaderkey.export-refresh")
  private var isExportRefreshInFlight = false
  private var isGokuProfileSyncInFlight = false
  private var hasPendingExportRefresh = false
  private var lastExportStartTime: CFAbsoluteTime = 0
  private var karabinerActivationContext: KarabinerActivationContext?

  // --- Input Method Management ---
  private var currentInputMethod: InputMethod?
  private var voiceCoordinator: VoiceCoordinator?

  // --- Input and sequence state ---
  private var isMonitoring = false
  private var activeRootGroup: Group?
  private var currentSequenceGroup: Group?
  private var didShowPermissionsAlertRecently = false
  private var stickyModeToggled = false {
    didSet {
      setStickyModeStatus(active: stickyModeToggled)
    }
  }
  // Track if we're in Karabiner 2.0 sticky mode
  private var isKarabinerStickyMode = false
  // Consolidated callback optimization state
  private var callbackState = CallbackOptimizationState()
  private var currentBundleId: String?

  lazy var settingsWindowController = SettingsWindowController(
    panes: [
      Settings.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!,
        contentView: { GeneralPane().environmentObject(self.config) }
      ),
      Settings.Pane(
        identifier: .shortcuts,
        title: "Shortcuts",
        toolbarIcon: NSImage(
          systemSymbolName: "keyboard", accessibilityDescription: "Shortcut Map")!,
        contentView: { ShortcutsOverviewView(userConfig: self.config) }
      ),
      Settings.Pane(
        identifier: .opacity,
        title: "Opacity",
        toolbarIcon: NSImage(
          systemSymbolName: "slider.horizontal.3", accessibilityDescription: "Opacity Settings")!,
        contentView: { OpacityPane() }
      ),
      Settings.Pane(
        identifier: .preferences,
        title: "Preferences",
        toolbarIcon: NSImage(
          systemSymbolName: "switch.2", accessibilityDescription: "Preferences")!,
        contentView: { PreferencesPane() }
      ),
      Settings.Pane(
        identifier: .search, title: "Search",
        toolbarIcon: NSImage(
          systemSymbolName: "magnifyingglass", accessibilityDescription: "Search Sequences")!,
        contentView: { SearchPane().environmentObject(self.config) }
      ),
      Settings.Pane(
        identifier: .voice,
        title: "Voice",
        toolbarIcon: NSImage(
          systemSymbolName: "waveform", accessibilityDescription: "Voice Dispatcher")!,
        contentView: { VoicePane() }
      ),
      Settings.Pane(
        identifier: .advanced, title: "Advanced",
        toolbarIcon: NSImage(named: NSImage.advancedName)!,
        contentView: { AdvancedPane().environmentObject(self.config) }
      ),
    ],
    style: .segmentedControl,
    animated: false
  )

  // --- Lifecycle Methods ---
  func applicationDidFinishLaunching(_: Notification) {
    // Don't run main app logic during previews or tests
    guard
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    else {
      print("[AppDelegate] Detected Xcode Preview environment. Skipping full launch.")
      return
    }
    guard !isRunningTests() else {
      print("[AppDelegate] Detected XCTest environment. Skipping full launch.")
      return
    }  // isRunningTests() is in private extension

    #if DEBUG
      debugLog("[AppDelegate] applicationDidFinishLaunching: Starting up...")
    #endif

    // Setup Notifications
    UNUserNotificationCenter.current().delegate = self  // Conformance is in extension
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      granted, error in
      #if DEBUG
        if let error = error {
          debugLog("[AppDelegate] Error requesting notification permission: \(error)")
        }
      #endif
      #if DEBUG
        debugLog("[AppDelegate] Notification permission granted: \(granted)")
      #endif
    }

    // Setup Main Menu
    NSApp.mainMenu = MainMenu()

    // Load configuration and initialize state
    #if DEBUG
      debugLog("[AppDelegate] Initializing UserConfig and UserState...")
    #endif
    config.ensureAndLoad()  // Ensures config dir/file exists and loads default config
    state = UserState(userConfig: config)
    controller = Controller(userState: state, userConfig: config, appDelegate: self)
    #if DEBUG
      debugLog("[AppDelegate] UserConfig and UserState initialized.")
    #endif

    // Subscribe to reload events to manage event processing
    Events.sink { [weak self] event in
      guard let self = self else { return }
      self.handleConfigEvent(
        event,
        refreshStateMappings: { self.refreshStateMappingsIfNeeded() },
        refreshActiveSequenceAfterReload: { self.refreshActiveSequenceAfterReloadIfNeeded() }
      )
    }.store(in: &cancellables)

    controlSocketServer.delegate = self
    if controlSocketServer.start() {
      debugLog("[AppDelegate] Started app control socket")
    } else {
      debugLog("[AppDelegate] Failed to start app control socket")
    }

    // Setup background services and UI elements
    setupFileMonitor()  // Defined in private extension
    setupStatusItem()  // Defined in private extension
    setupVoiceCoordinator()
    setupUpdaterController()  // Configure auto-update behavior
    setupStateRecoveryTimer()  // Setup periodic state recovery checks

    // Configure global image cache to keep memory tight
    configureImageCaching()

    // Check initial permission state
    lastPermissionCheck = checkAccessibilityPermissions()
    print("[AppDelegate] Initial accessibility permission state: \(lastPermissionCheck ?? false)")

    // Attempt to start the global event tap immediately
    #if DEBUG
      debugLog("[AppDelegate] Attempting initial startEventTapMonitoring()...")
    #endif
    startEventTapMonitoring()  // Defined in Event Tap Handling extension

    // Add a delayed check to retry starting the event tap if it failed initially.
    // This helps if Accessibility permissions were granted just before launch
    // and the system needs a moment to register them.
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // Wait 2 seconds
      if !self.isMonitoring && self.checkAccessibilityPermissions() {
        print(
          "[AppDelegate] Delayed check: Permissions available but not monitoring. Retrying startEventTapMonitoring()..."
        )
        self.startEventTapMonitoring()
      } else if !self.isMonitoring {
        print(
          "[AppDelegate] Delayed check: Still no permissions. Health check will monitor for changes."
        )
      } else {
        print("[AppDelegate] Delayed check: Monitoring was already active.")
      }
    }
    print("[AppDelegate] applicationDidFinishLaunching completed.")

    // Make settings window resizable
    if let window = settingsWindowController.window {
      window.styleMask.insert(NSWindow.StyleMask.resizable)
      window.minSize = NSSize(width: 450, height: 650)
    }
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    // This is called when the app becomes active, e.g., by clicking its Dock icon,
    // using Cmd+Tab, or opening the Settings window.
    print("[AppDelegate] applicationDidBecomeActive triggered.")

    // Attempt to start monitoring if it failed previously (e.g., due to permissions not granted).
    // This provides another chance if the user grants permissions while the app is running
    // and then brings the app to the front.
    if !isMonitoring {
      print(
        "[AppDelegate] applicationDidBecomeActive: Not monitoring, attempting to start startEventTapMonitoring()..."
      )
      startEventTapMonitoring()
    } else {
      print("[AppDelegate] applicationDidBecomeActive: Already monitoring.")
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    print("[AppDelegate] applicationWillTerminate: Stopping event tap and saving config...")
    stopEventTapMonitoring()  // Defined in Event Tap Handling extension
    controlSocketServer.stop()
    config.saveCurrentlyEditingConfig()  // Save any unsaved changes from the settings pane
    stateRecoveryTimer?.invalidate()  // Stop state recovery timer
    inputMethodHealthTimer?.invalidate()  // Stop input method health timer
    permissionPollingTimer?.invalidate()  // Stop permission polling timer
    voiceCoordinator?.stop()
    configDirObserverTask?.cancel()
    menuBarIconObserverTask?.cancel()
    autoUpdateObserverTask?.cancel()
    inputMethodPrefObserverTask?.cancel()
    timeoutSettingsObserverTask?.cancel()
    print("[AppDelegate] applicationWillTerminate completed.")
  }

  private func setupVoiceCoordinator() {
    let coordinator = VoiceCoordinator(statusItem: statusItem, config: config)
    coordinator.start()
    voiceCoordinator = coordinator
  }

  // MARK: - State Recovery

  private var stateRecoveryTimer: Timer?
  private var inputMethodHealthTimer: Timer?
  private var lastPermissionCheck: Bool? = nil
  private var permissionPollingTimer: Timer?
  private var configDirObserverTask: Task<Void, Never>?
  private var menuBarIconObserverTask: Task<Void, Never>?
  private var autoUpdateObserverTask: Task<Void, Never>?
  private var inputMethodPrefObserverTask: Task<Void, Never>?
  private var timeoutSettingsObserverTask: Task<Void, Never>?
  private var permissionPollingStartTime: Date?

  private func setupStateRecoveryTimer() {
    // Check state every 5 seconds
    stateRecoveryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
      [weak self] _ in
      self?.checkAndRecoverWindowState()
    }

    // Check input method health every 5 seconds
    inputMethodHealthTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
      [weak self] _ in
      if let currentMethod = self?.currentInputMethod {
        _ = currentMethod.checkHealth()
      }
    }
  }

  private func checkAndRecoverWindowState() {
    guard let window = controller?.window else { return }

    // Check for inconsistent states (only check isVisible, not opacity since user can set opacity to 0)
    if window.isVisible {
      // Check if we have a stuck sequence with no active group
      if currentSequenceGroup == nil && activeRootGroup == nil {
        debugLog("[AppDelegate] State Recovery: Window visible but no active sequence. Hiding window.")
        hide()
      }
    }
  }

  // --- Actions & Window Handling ---
  @IBAction
  func settingsMenuItemActionHandler(_: NSMenuItem) {
    print("[AppDelegate] settingsMenuItemActionHandler called.")

    // Determine which config to focus on based on current state
    let configKeyToFocus = determineConfigToFocus()

    // Update the UserConfig to select the appropriate config for editing
    print("[AppDelegate] Setting config to focus on: \(configKeyToFocus)")
    config.loadConfigForEditing(key: configKeyToFocus)

    // Store the navigation path to be used after config loads
    let userStateNavigationPath = controller.userState.navigationPath
    let hasNavigationPath = !userStateNavigationPath.isEmpty
    if hasNavigationPath {
      print(
        "[AppDelegate] User has navigation path with \(userStateNavigationPath.count) groups to restore"
      )
    }

    // Ensure we have the window reference first
    guard let window = settingsWindowController.window else {
      print("[AppDelegate settings] Error: Could not get settings window reference.")
      settingsWindowController.show(pane: .general)
      NSApp.activate(ignoringOtherApps: true)
      return
    }

    // --- Configure Window Properties First ---
    window.styleMask.insert(NSWindow.StyleMask.resizable)
    window.minSize = NSSize(width: 450, height: 650)  // Ensure minSize is set

    // --- Position Window Before Showing to Prevent Flicker ---
    print("[AppDelegate settings] Positioning window before show...")
    var calculatedOrigin: NSPoint?
    let mouseLocation = NSEvent.mouseLocation
    let screen = NSScreen.screens.first { $0.frame.contains(mouseLocation) } ?? NSScreen.main

    if let targetScreen = screen {
      let screenFrame = targetScreen.visibleFrame
      let windowSize = window.frame.size
      let effectiveWidth = (windowSize.width > 0) ? windowSize.width : window.minSize.width
      let effectiveHeight = (windowSize.height > 0) ? windowSize.height : window.minSize.height

      if effectiveWidth > 0 && effectiveHeight > 0 {
        let newOriginX = screenFrame.origin.x + (screenFrame.size.width - effectiveWidth) / 2.0
        let newOriginY = screenFrame.origin.y + (screenFrame.size.height - effectiveHeight) / 2.0
        calculatedOrigin = NSPoint(x: newOriginX, y: newOriginY)
        print("[AppDelegate settings] Calculated Center Origin: \(calculatedOrigin!)")
      } else {
        print(
          "[AppDelegate settings] Warning: Could not determine effective window size (Size: \(windowSize)). Origin calculation skipped."
        )
      }
    } else {
      print(
        "[AppDelegate settings] Warning: Could not get target screen. Origin calculation skipped.")
    }

    // Set position before showing
    if let originToSet = calculatedOrigin {
      print("[AppDelegate settings] Setting origin: \(originToSet)")
      window.setFrameOrigin(originToSet)
    } else {
      print("[AppDelegate settings] Origin calculation failed. Centering window.")
      window.center()
    }

    // Show the window controller after positioning
    settingsWindowController.show(pane: .general)

    NSApp.activate(ignoringOtherApps: true)  // Bring the app to the front for settings
    print("[AppDelegate] Settings window show() called (positioning deferred).")

    // Post navigation notification if we have a navigation path
    if hasNavigationPath {
      // Build the navigation path using the loaded config
      let navigationPath = buildNavigationPathFromLoadedConfig(userStateNavigationPath)
      if let path = navigationPath, !path.isEmpty {
        print("[AppDelegate] Posting NavigateToSearchResult notification with path: \(path)")
        NotificationCenter.default.post(
          name: Notification.Name("NavigateToSearchResult"),
          object: nil,
          userInfo: ["path": path]
        )
      } else {
        print(
          "[AppDelegate] Failed to build navigation path for groups: \(userStateNavigationPath.map { $0.key ?? "nil" })"
        )
      }
    }
  }

  // Determine which config to focus on based on current state
  private func determineConfigToFocus() -> String {
    // First check if UserState has a stored config key
    if let activeConfigKey = controller.userState.activeConfigKey {
      debugLog("[AppDelegate] Using stored activeConfigKey from UserState: \(activeConfigKey)")
      return activeConfigKey
    }

    // Fallback: check if we have an active sequence state
    if let activeRoot = self.activeRootGroup {
      debugLog("[AppDelegate] Active sequence detected, determining config from activeRootGroup")
      return findConfigKeyForGroup(activeRoot)
    }

    // Check if the Controller's UserState has an active root (without stored key)
    if let userStateActiveRoot = controller.userState.activeRoot {
      debugLog("[AppDelegate] Using UserState activeRoot to determine config")
      return findConfigKeyForGroup(userStateActiveRoot)
    }

    // Check frontmost application to determine if we should use app-specific config
    if let frontmostApp = NSWorkspace.shared.frontmostApplication,
      let bundleId = frontmostApp.bundleIdentifier
    {
      debugLog("[AppDelegate] Using frontmost app (\(bundleId)) to determine config")

      // Check if an app-specific config exists for this bundle ID
      let appConfig = config.getConfig(for: bundleId)
      // If the returned config is not the default root, then an app-specific config exists
      if !areGroupsEqual(appConfig, config.root) {
        return findConfigKeyForGroup(appConfig)
      }
    }

    // Default fallback - use global default
    debugLog("[AppDelegate] Falling back to global default config")
    return globalDefaultDisplayName
  }

  // Find the configuration key for a given Group
  private func findConfigKeyForGroup(_ group: Group) -> String {
    // Check if this is the global default (root config)
    if areGroupsEqual(group, config.root) {
      return globalDefaultDisplayName
    }

    // Search through discovered config files to find a match
    for (key, filePath) in config.discoveredConfigFiles {
      // Skip the global default entry
      if key == globalDefaultDisplayName {
        continue
      }

      // Try to load the config from this file path and compare
      if let loadedGroup = config.decodeConfig(
        from: filePath, suppressAlerts: true, isDefaultConfig: false)
      {
        if areGroupsEqual(loadedGroup, group) {
          return key
        }
      }
    }

    // If we can't find a specific match, try to infer from bundle ID
    if let frontmostApp = NSWorkspace.shared.frontmostApplication,
      let bundleId = frontmostApp.bundleIdentifier
    {

      // Look for an app-specific config key pattern
      for key in config.discoveredConfigFiles.keys {
        if config.extractRegularAppBundleId(from: key) == bundleId {
          return key
        }
      }

      // Check if there's a fallback app config
      if config.discoveredConfigFiles.keys.contains(defaultAppConfigDisplayName) {
        return defaultAppConfigDisplayName
      }
    }

    // Final fallback
    return globalDefaultDisplayName
  }

  // Helper method to compare two Group objects for equality
  private func areGroupsEqual(_ group1: Group, _ group2: Group) -> Bool {
    return group1.key == group2.key && group1.label == group2.label
      && group1.actions.count == group2.actions.count
  }

  // Build navigation path from the loaded config using the navigationPath groups
  private func buildNavigationPathFromLoadedConfig(_ navigationPath: [Group]) -> [Int]? {
    guard !navigationPath.isEmpty else {
      print("[AppDelegate] buildNavigationPathFromLoadedConfig: Navigation path is empty")
      return nil
    }

    // Use the actually loaded config that's displayed in settings
    let rootGroup = config.currentlyEditingGroup
    print(
      "[AppDelegate] buildNavigationPathFromLoadedConfig: Using currentlyEditingGroup with key '\(rootGroup.key ?? "nil")'"
    )
    print(
      "[AppDelegate] buildNavigationPathFromLoadedConfig: Navigation path has \(navigationPath.count) groups"
    )

    // Check if the first group in navigationPath is the root itself (has same nil key and matches root)
    var groupsToProcess = navigationPath
    if let firstGroup = navigationPath.first,
      firstGroup.key == rootGroup.key && firstGroup.key == nil
    {
      print(
        "[AppDelegate] buildNavigationPathFromLoadedConfig: Skipping root group in navigation path")
      groupsToProcess = Array(navigationPath.dropFirst())
    }

    // If no groups left after removing root, return empty path
    guard !groupsToProcess.isEmpty else {
      print(
        "[AppDelegate] buildNavigationPathFromLoadedConfig: No groups to navigate after removing root"
      )
      return []
    }

    // Build the index path by finding each group in the hierarchy
    var indexPath: [Int] = []
    var currentGroup = rootGroup

    for (navIndex, targetGroup) in groupsToProcess.enumerated() {
      let targetKey = targetGroup.key ?? ""
      let targetLabel = targetGroup.label ?? ""
      print(
        "[AppDelegate] buildNavigationPathFromLoadedConfig: Looking for group with key='\(targetKey)' label='\(targetLabel)' at level \(navIndex)"
      )

      // Find the index of this group in the current level
      // Match by key if both have keys, otherwise try to match by label or other properties
      if let index = currentGroup.actions.firstIndex(where: { item in
        if case .group(let group) = item {
          // If target has a key, match by key and label
          if !targetKey.isEmpty {
            let matches =
              group.key == targetGroup.key
              && (targetGroup.label == nil || group.label == targetGroup.label)
            if matches {
              print(
                "[AppDelegate] buildNavigationPathFromLoadedConfig: Found match by key at index \(index)"
              )
            }
            return matches
          } else if !targetLabel.isEmpty {
            // If no key but has label, try matching by label alone
            let matches = group.label == targetGroup.label
            if matches {
              print(
                "[AppDelegate] buildNavigationPathFromLoadedConfig: Found match by label at index \(index)"
              )
            }
            return matches
          }
        }
        return false
      }) {
        indexPath.append(index)
        // Move to the next level
        if case .group(let nextGroup) = currentGroup.actions[index] {
          currentGroup = nextGroup
          print(
            "[AppDelegate] buildNavigationPathFromLoadedConfig: Moving to next level, now at group with key='\(nextGroup.key ?? "nil")' label='\(nextGroup.label ?? "")'"
          )
        }
      } else {
        // If we can't find the group, log available groups for debugging
        let availableGroups = currentGroup.actions.compactMap { item -> String in
          if case .group(let g) = item {
            return "key='\(g.key ?? "nil")' label='\(g.label ?? "")'"
          }
          return ""
        }.filter { !$0.isEmpty }
        print(
          "[AppDelegate] buildNavigationPathFromLoadedConfig: Could not find group with key='\(targetKey)' label='\(targetLabel)' at level \(navIndex)"
        )
        print(
          "[AppDelegate] buildNavigationPathFromLoadedConfig: Available groups at this level: \(availableGroups)"
        )
        return nil
      }
    }

    print(
      "[AppDelegate] buildNavigationPathFromLoadedConfig: Successfully built path: \(indexPath)")
    return indexPath
  }

  // Build navigation path from UserState's navigationPath to indices (legacy method kept for compatibility)
  private func buildNavigationPath() -> [Int]? {
    let navigationPath = controller.userState.navigationPath
    guard !navigationPath.isEmpty else {
      return nil
    }

    // Get the root group that settings will show
    let configKey = determineConfigToFocus()
    let rootGroup: Group

    if configKey == globalDefaultDisplayName {
      rootGroup = config.root
    } else if let filePath = config.discoveredConfigFiles[configKey],
      let loadedGroup = config.decodeConfig(
        from: filePath, suppressAlerts: true, isDefaultConfig: false)
    {
      switch config.configFileKind(forPath: filePath) {
      case .app(let bundleId):
        let rawMergedGroup = config.mergeConfigWithFallback(
          appSpecificConfig: loadedGroup, bundleId: bundleId)
        rootGroup = config.sortGroupRecursively(group: rawMergedGroup)
      case .normalApp(let bundleId):
        let rawMergedGroup = config.mergeNormalConfigWithFallback(
          appSpecificConfig: loadedGroup, bundleId: bundleId)
        rootGroup = config.sortGroupRecursively(group: rawMergedGroup)
      case .global, .appFallback, .normalFallback, .tag, .normalTag, .unknown:
        rootGroup = loadedGroup
      }
    } else {
      return nil
    }

    // Build the index path by finding each group in the hierarchy
    var indexPath: [Int] = []
    var currentGroup = rootGroup

    for targetGroup in navigationPath {
      // Find the index of this group in the current level
      if let index = currentGroup.actions.firstIndex(where: { item in
        if case .group(let group) = item {
          return group.key == targetGroup.key && group.label == targetGroup.label
        }
        return false
      }) {
        indexPath.append(index)
        // Move to the next level
        if case .group(let nextGroup) = currentGroup.actions[index] {
          currentGroup = nextGroup
        }
      } else {
        // If we can't find the group, the path is invalid
        print(
          "[AppDelegate] buildNavigationPath: Could not find group '\(targetGroup.key ?? "")' in current level"
        )
        return nil
      }
    }

    return indexPath
  }

  // Convenience method to show the main Leader Key window
  func show(
    type: Controller.ActivationType = .appSpecificWithFallback, bundleId: String? = nil, completion: (() -> Void)? = nil
  ) {
    debugLog("[AppDelegate] show(type: \(type), bundleId: \(bundleId ?? "nil")) called.")
    controller.show(type: type, bundleId: bundleId, completion: completion)
  }

  // Convenience method to hide the main Leader Key window
  func hide() {
    debugLog("[AppDelegate] hide() called.")

    controller.hide(afterClose: { [weak self] in
      // Reset sequence AFTER the window is fully closed to avoid visual flash
      self?.resetSequenceState()
    })
  }

  // Toggle sticky mode programmatically (for use in actions)
  func toggleStickyMode() {
    stickyModeToggled.toggle()
    debugLog("[AppDelegate] toggleStickyMode: Sticky mode toggled to \(stickyModeToggled)")

    // Update window transparency immediately if we're in a sequence
    if currentSequenceGroup != nil {
      let isStickyModeActive = isInStickyMode(NSEvent.modifierFlags)
      DispatchQueue.main.async {
        self.controller.window.alphaValue =
          isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
      }
    }
  }

  // Activate sticky mode programmatically (for use in actions with stickyMode enabled)
  func activateStickyMode() {
    if !stickyModeToggled {
      stickyModeToggled = true
      debugLog("[AppDelegate] activateStickyMode: Sticky mode activated")

      // Update window transparency immediately if we're in a sequence
      if currentSequenceGroup != nil {
        DispatchQueue.main.async {
          self.controller.window.alphaValue = Defaults[.stickyModeOpacity]
        }
      }
    }
  }

  // NOTE: All Event Tap methods (start/stop/handle/process...), Sparkle delegate methods,
  // UNUserNotificationCenter delegate methods, URL Scheme methods, and private helpers
  // (setupFileMonitor, setupStatusItem, isRunningTests) should be defined ONLY in extensions below.
  // Ensure there are NO duplicate definitions within this main class body.
}

// MARK: - Private Helpers
extension AppDelegate {
  // ... (setupFileMonitor, setupStatusItem, isRunningTests implementations - logs added within methods) ...
  fileprivate func setupFileMonitor() {
    print("[AppDelegate] setupFileMonitor: Setting up config directory watcher.")
    configDirObserverTask = Task {
      // Observe changes to the config directory path stored in Defaults
      for await newDir in Defaults.updates(.configDir) {
        print("[AppDelegate] Config directory changed to: \(newDir). Restarting file monitor.")
        self.fileMonitor?.stopMonitoring()  // Stop previous monitor if any
        self.fileMonitor = FileMonitor(fileURL: config.url) { [weak self] in  // Create new monitor for the current config URL
          print("[AppDelegate] FileMonitor detected change in config file. Reloading...")
          self?.config.reloadConfig()
        }
        self.fileMonitor.startMonitoring()
        print("[AppDelegate] FileMonitor started for: \(config.url.path)")
      }
    }
  }

  fileprivate func setupStatusItem() {
    print("[AppDelegate] setupStatusItem: Configuring status bar menu item.")
    // Assign actions to the status item menu options
    statusItem.handlePreferences = {
      print("[StatusItem] Preferences clicked.")
      self.settingsWindowController.show()
      NSApp.activate(ignoringOtherApps: true)
    }
    statusItem.handleReloadConfig = {
      print("[StatusItem] Reload Config clicked.")
      self.config.reloadConfig()
    }
    statusItem.handleRevealConfig = {
      print("[StatusItem] Reveal Config clicked.")
      NSWorkspace.shared.activateFileViewerSelecting([self.config.url])
    }
    statusItem.handleCheckForUpdates = {
      print("[StatusItem] Check for Updates clicked.")
      self.updaterController.checkForUpdates(nil)
    }
    statusItem.handleForceReset = {
      print("[StatusItem] Force Reset clicked.")
      self.forceResetState()
    }
    statusItem.handleShowPerformanceStats = {
      print("[StatusItem] Show Performance Stats clicked.")
      let stats = "Karabiner input method active"
      DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = "Input Method Status"
        alert.informativeText = stats
        alert.addButton(withTitle: "OK")
        alert.runModal()
      }
    }
    // Observe changes to the preference for showing the menu bar icon
    menuBarIconObserverTask = Task {
      for await value in Defaults.updates(.showMenuBarIcon) {
        DispatchQueue.main.async {
          print(
            "[AppDelegate] Show Menu Bar Icon setting changed to: \(value). Updating status item visibility."
          )
          if value {
            self.statusItem.enable()
          } else {
            self.statusItem.disable()
          }
        }
      }
    }
  }

  func handleConfigEvent(
    _ event: EventKey,
    refreshStateMappings: () -> Void,
    refreshActiveSequenceAfterReload: () -> Void
  ) {
    switch event {
    case .willDeactivate:
      break
    case .willReload:
      #if DEBUG
        debugLog("[AppDelegate] Config reload started")
      #endif
    case .didReload:
      refreshStateMappings()
      refreshActiveSequenceAfterReload()
      statusItem.indicateReloadSuccess()
      #if DEBUG
        debugLog("[AppDelegate] Config reload completed")
      #endif
    case .didSaveConfig:
      // Export is NOT triggered here — save already calls reloadConfig()
      // which sends .didReload, avoiding duplicate exports.
      debugLog("[AppDelegate] Config saved")
    default:
      break
    }
  }

  // Helper to check if running within Xcode's testing environment
  fileprivate func isRunningTests() -> Bool {
    let isTesting = ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil
    if isTesting { print("[AppDelegate] isRunningTests detected.") }
    return isTesting
  }

  fileprivate func setupUpdaterController() {
    print("[AppDelegate] setupUpdaterController: Configuring auto-update behavior.")

    // Set initial automatic update check preference
    updaterController.updater.automaticallyChecksForUpdates =
      Defaults[.automaticallyChecksForUpdates]

    // Observe changes to the auto-update preference
    autoUpdateObserverTask = Task {
      for await value in Defaults.updates(.automaticallyChecksForUpdates) {
        DispatchQueue.main.async {
          print(
            "[AppDelegate] Auto-update setting changed to: \(value). Updating Sparkle configuration."
          )
          self.updaterController.updater.automaticallyChecksForUpdates = value
        }
      }
    }

    // Observe changes to input method preference
    inputMethodPrefObserverTask = Task {
      for await value in Defaults.updates(.inputMethodPreference) {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          print(
            "[AppDelegate] Input method preference changed to: \(value.displayName). Restarting monitoring..."
          )

          // Stop current monitoring
          if self.isMonitoring {
            self.stopEventTapMonitoring()
          }

          // Start with new input method
          self.startEventTapMonitoring()
        }
      }
    }

    timeoutSettingsObserverTask = Task { [weak self] in
      await withTaskGroup(of: Void.self) { group in
        group.addTask {
          for await _ in Defaults.updates(.leaderSequenceTimeoutEnabled) {
            await self?.refreshExportForPreferenceChange()
          }
        }
        group.addTask {
          for await _ in Defaults.updates(.leaderSequenceTimeoutMS) {
            await self?.refreshExportForPreferenceChange()
          }
        }
        group.addTask {
          for await _ in Defaults.updates(.normalSequenceTimeoutEnabled) {
            await self?.refreshExportForPreferenceChange()
          }
        }
        group.addTask {
          for await _ in Defaults.updates(.normalSequenceTimeoutMS) {
            await self?.refreshExportForPreferenceChange()
          }
        }
      }
    }
  }

  @MainActor
  private func refreshExportForPreferenceChange() {
    refreshStateMappingsIfNeeded()
  }

  fileprivate func configureImageCaching() {
    // Kingfisher: reduce memory footprint and avoid caching huge originals
    let cache = KingfisherManager.shared.cache
    cache.memoryStorage.config.totalCostLimit = 25 * 1024 * 1024  // ~25MB in-RAM images
    cache.memoryStorage.config.countLimit = 1024
    cache.memoryStorage.config.expiration = .seconds(600)
    cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024  // 100MB on disk
    cache.diskStorage.config.expiration = .days(14)
  }
}

// MARK: - Sparkle Updates Delegate (SPUStandardUserDriverDelegate)
extension AppDelegate: SPUStandardUserDriverDelegate {
  // ... (Delegate method implementations) ...
  var supportsGentleScheduledUpdateReminders: Bool { return true }

  func standardUserDriverWillHandleShowingUpdate(
    _ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState
  ) {
    NSApp.setActivationPolicy(.regular)
    if !state.userInitiated {
      NSApp.dockTile.badgeLabel = "1"
      let content = UNMutableNotificationContent()
      content.title = "Leader Key Update Available"
      content.body = "Version \(update.displayVersionString) is now available"
      let request = UNNotificationRequest(
        identifier: updateLocationIdentifier, content: content, trigger: nil)
      UNUserNotificationCenter.current().add(request)
    }
  }

  func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
    NSApp.dockTile.badgeLabel = ""
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [
      updateLocationIdentifier
    ])
  }

  func standardUserDriverWillFinishUpdateSession() {
    NSApp.setActivationPolicy(.accessory)
  }
}

// MARK: - User Notifications Delegate (UNUserNotificationCenterDelegate)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // ... (Delegate method implementation) ...
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.notification.request.identifier == updateLocationIdentifier
      && response.actionIdentifier == UNNotificationDefaultActionIdentifier
    {
      updaterController.checkForUpdates(nil)
    }
    completionHandler()
  }
}

// MARK: - External Config Apply
extension AppDelegate {
  private func applyExternalConfigChanges(trigger: String) {
    debugLog("[AppDelegate] applyExternalConfigChanges: trigger=\(trigger)")
    config.reloadConfig()
  }

  private func startGokuProfileSync(trigger: String) -> String {
    exportRefreshQueue.async { [weak self] in
      guard let self else { return }
      if self.isGokuProfileSyncInFlight {
        debugLog("[AppDelegate] Goku profile sync already in flight, trigger=\(trigger)")
        return
      }

      self.isGokuProfileSyncInFlight = true
      let result = KarabinerTsExportService.shared.migrateGokuProfileToKarabinerTs()
      self.isGokuProfileSyncInFlight = false

      if result.success {
        debugLog("[AppDelegate] \(result.message)")
        DispatchQueue.main.async { [weak self] in
          self?.applyExternalConfigChanges(trigger: "\(trigger)-goku-profile-sync")
        }
      } else {
        debugLog("[AppDelegate] \(result.message)")
      }
    }

    return "OK: sync-goku-profile started"
  }
}

// MARK: - Unix Socket Delegate
extension AppDelegate {
  private func recordSocketTransportState(_ state: Int32) {
    (currentInputMethod as? Karabiner2InputMethod)?.recordTransportState(state)
  }

  func unixSocketServerDidReceiveActivation(bundleId: String?) {
    debugLog("[AppDelegate] Control socket activation, bundleId: \(bundleId ?? "nil")")
    recordSocketTransportState(1)
    inputMethodDidReceiveActivation(bundleId: bundleId)
  }

  func unixSocketServerDidReceiveApplyConfig() {
    debugLog("[AppDelegate] Control socket apply-config")
    inputMethodDidReceiveApplyConfig()
  }

  func unixSocketServerDidReceiveGokuProfileSync() -> String {
    debugLog("[AppDelegate] Control socket sync-goku-profile")
    return startGokuProfileSync(trigger: "unix-socket")
  }

  func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
    debugLog("[AppDelegate] Control socket key: \(keyCode), modifiers: \(modifiers)")
    inputMethodDidReceiveKey(keyCode, modifiers: modifiers)
  }

  func unixSocketServerDidReceiveDeactivation() {
    debugLog("[AppDelegate] Control socket deactivation")
    recordSocketTransportState(0)
    inputMethodDidReceiveDeactivation()
  }

  func unixSocketServerDidReceiveSettings() {
    debugLog("[AppDelegate] Control socket settings")
    inputMethodDidReceiveSettings()
  }

  func unixSocketServerDidReceiveSequence(_ sequence: String) {
    debugLog("[AppDelegate] Control socket sequence: \(sequence)")
    recordSocketTransportState(0)
    inputMethodDidReceiveSequence(sequence)
  }

  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool, bundleId: String?) {
    debugLog(
      "[AppDelegate] Control socket state ID: \(stateId), sticky: \(sticky), bundleId: \(bundleId ?? "nil")"
    )
    recordSocketTransportState(0)
    inputMethodDidReceiveStateId(stateId, sticky: sticky, bundleId: bundleId)
  }

  func unixSocketServerDidReceiveNormalModeStatus(_ status: StatusItem.NormalModeStatus) {
    debugLog("[AppDelegate] Control socket normal mode status: \(status)")
    setNormalModeStatus(status)
  }

  func unixSocketServerDidReceiveHintOverlay(_ command: HintOverlayCommand) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      switch command {
      case .on:
        self.controller.setHintOverlayVisible(true)
      case .off:
        self.controller.setHintOverlayVisible(false)
      case .toggle:
        self.controller.toggleHintOverlay()
      }
    }
  }

  func unixSocketServerDidReceiveShake() {
    debugLog("[AppDelegate] Control socket shake")
    inputMethodDidReceiveShake()
  }

  func unixSocketServerRequestState() -> [String: Any] {
    var state = inputMethodDidRequestState()
    state["currentState"] = (currentInputMethod as? Karabiner2InputMethod)?.transportState ?? 0
    state["mode"] = currentInputMethod is Karabiner2InputMethod ? "karabiner2" : "app_socket"
    return state
  }

  func unixSocketServerDidReceiveCommandScoutOpen(bundleId: String, source: String) {
    debugLog("[AppDelegate] Command Scout open: bundleId=\(bundleId) source=\(source)")
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      // Open settings and trigger Command Scout for this bundleId
      self.config.commandScoutPendingBundleId = bundleId
      self.unixSocketServerDidReceiveSettings()
    }
  }

  func unixSocketServerDidReceiveDispatchExecute(_ payload: [String: Any]) -> String {
    if Thread.isMainThread {
      return handleDispatchExecutePayload(payload)
    }

    var response = "{\"executed\":false,\"dry_run\":true,\"blocked\":true,\"needs_confirmation\":false,\"reason\":\"dispatch unavailable\",\"steps\":[]}"
    DispatchQueue.main.sync { [weak self] in
      response = self?.handleDispatchExecutePayload(payload)
        ?? "{\"executed\":false,\"dry_run\":true,\"blocked\":true,\"needs_confirmation\":false,\"reason\":\"Leader Key app delegate unavailable\",\"steps\":[]}"
    }
    return response
  }

  private func handleDispatchExecutePayload(_ payload: [String: Any]) -> String {
    ensureControllerReady()

    let dryRun = payload["dryRun"] as? Bool ?? true
    let allowDestructive = payload["allowDestructive"] as? Bool ?? false
    guard let steps = payload["steps"] as? [[String: Any]] else {
      return dispatchJSON([
        "blocked": true,
        "dry_run": dryRun,
        "executed": false,
        "needs_confirmation": false,
        "reason": "dispatch execute requires steps",
        "steps": [],
      ])
    }

    var reports: [[String: Any]] = []
    var resolved: [(index: Int, action: Action)] = []

    for step in steps {
      let actionId = step["actionId"] as? String ?? ""
      let label = step["label"] as? String ?? actionId
      let actionType = step["actionType"] as? String ?? ""
      let safety = step["safety"] as? String ?? "safe"
      let requiresConfirmation = step["requiresConfirmation"] as? Bool ?? false
      let stepRequiresConfirmation = requiresConfirmation || safety == "confirm" || safety == "block"
      var report: [String: Any] = [
        "action_id": actionId,
        "blocked": false,
        "dry_run": dryRun,
        "executed": false,
        "label": label,
        "requires_confirmation": stepRequiresConfirmation,
        "type": actionType,
      ]

      guard safety != "block" || allowDestructive else {
        report["blocked"] = true
        report["reason"] = "action marked blocked"
        reports.append(report)
        continue
      }

      guard !stepRequiresConfirmation || allowDestructive else {
        report["reason"] = "confirmation required"
        reports.append(report)
        continue
      }

      guard let scope = step["effectiveScope"] as? String,
            let keyPath = step["effectiveKeyPath"] as? [String],
            let root = dispatchRoot(forScope: scope, bundleId: step["bundleId"] as? String) else {
        report["blocked"] = true
        report["reason"] = "unsupported dispatch scope or path"
        reports.append(report)
        continue
      }

      guard let action = Self.resolveAction(in: root, path: keyPath) else {
        report["blocked"] = true
        report["reason"] = "action path not found"
        reports.append(report)
        continue
      }

      guard action.type.rawValue == actionType else {
        report["blocked"] = true
        report["reason"] = "action type mismatch"
        reports.append(report)
        continue
      }

      guard allowDestructive || (action.type != .command && !dispatchActionContainsCommand(action)) else {
        report["blocked"] = true
        report["reason"] = "voice dispatch blocks command actions"
        reports.append(report)
        continue
      }

      reports.append(report)
      resolved.append((index: reports.count - 1, action: action))
    }

    let blocked = reports.contains { ($0["blocked"] as? Bool) == true }
    let needsConfirmation = !allowDestructive && reports.contains { ($0["requires_confirmation"] as? Bool) == true }
    guard !blocked && !needsConfirmation && !dryRun else {
      return dispatchJSON([
        "blocked": blocked,
        "dry_run": dryRun,
        "executed": false,
        "needs_confirmation": needsConfirmation,
        "reason": blocked ? "blocked" : needsConfirmation ? "confirmation required" : "dry run",
        "steps": reports,
      ])
    }

    executeVoiceDispatchActionsSequentially(resolved.map { $0.action })
    for item in resolved {
      reports[item.index]["executed"] = true
    }

    return dispatchJSON([
      "blocked": false,
      "dry_run": false,
      "executed": !resolved.isEmpty,
      "needs_confirmation": false,
      "reason": "executed",
      "steps": reports,
    ])
  }

  private func dispatchRoot(forScope scope: String, bundleId: String?) -> Group? {
    switch scope {
    case "global":
      return config.root
    case "fallback":
      return config.getFallbackConfig()
    case "app":
      return config.getConfig(for: bundleId)
    case "normalFallback":
      return config.getNormalFallbackConfig()
    case "normalApp":
      return config.getNormalConfig(for: bundleId)
    default:
      return nil
    }
  }

  private func executeVoiceDispatchActionsSequentially(_ actions: [Action]) {
    guard !actions.isEmpty else { return }

    var delay: TimeInterval = 0
    for index in actions.indices {
      let action = actions[index]
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        self?.controller.runAction(action)
      }

      let nextAction = index + 1 < actions.count ? actions[index + 1] : nil
      delay += Self.voiceDispatchDelay(after: action, before: nextAction)
    }
  }

  private static func voiceDispatchDelay(after action: Action, before nextAction: Action?) -> TimeInterval {
    if action.type == .application, nextAction != nil {
      return 0.45
    }
    if isVoiceWindowManagementAction(action) {
      return 0.15
    }
    return 0.12
  }

  private static func isVoiceWindowManagementAction(_ action: Action?) -> Bool {
    guard let action, action.type == .url else { return false }
    let value = action.value.lowercased()
    return value.contains("raycast://extensions/raycast/window-management/")
      || value.contains("raycast://window-management/")
  }

  private func dispatchActionContainsCommand(_ action: Action) -> Bool {
    guard action.type == .macro else {
      return false
    }

    return action.macroSteps?.contains { step in
      guard step.enabled else { return false }
      return step.action.type == .command || dispatchActionContainsCommand(step.action)
    } ?? false
  }

  private func dispatchJSON(_ object: [String: Any]) -> String {
    guard JSONSerialization.isValidJSONObject(object),
          let data = try? JSONSerialization.data(withJSONObject: object, options: []),
          let json = String(data: data, encoding: .utf8) else {
      return "{\"executed\":false,\"dry_run\":true,\"blocked\":true,\"needs_confirmation\":false,\"reason\":\"failed to encode dispatch response\",\"steps\":[]}"
    }
    return json
  }

  func setNormalModeStatus(active: Bool) {
    setNormalModeStatus(active ? .normal : .inactive)
  }

  func setNormalModeStatus(_ status: StatusItem.NormalModeStatus) {
    DispatchQueue.main.async { [weak self] in
      self?.statusItem.normalModeStatus = status
    }
  }

  func setStickyModeStatus(active: Bool) {
    DispatchQueue.main.async { [weak self] in
      self?.statusItem.stickyModeActive = active
    }
  }
}

// MARK: - Event Tap Handling
extension AppDelegate {

  // --- Event Tap Logic Methods ---

  func startEventTapMonitoring() {
    guard !isMonitoring else {
      print("[AppDelegate] startEventTapMonitoring: Already monitoring. Aborting.")
      return
    }
    print("[AppDelegate] startEventTapMonitoring: Starting Karabiner input method...")

    currentInputMethod = Karabiner2InputMethod()

    // Pass loadStateMappings as onExportComplete callback so state mappings are
    // loaded from the freshly exported configuration. (The app-config cache
    // itself is thread-safe via UserConfig's locked accessors.)
    if let method = currentInputMethod, method.start(with: self, onExportComplete: { [weak self] in
      self?.loadStateMappings()
    }) {
      print("[AppDelegate] Karabiner input method started successfully")
      self.isMonitoring = true
      self.didShowPermissionsAlertRecently = false
    } else {
      print("[AppDelegate] Failed to start Karabiner input method")
    }
  }

  func stopEventTapMonitoring() {
    guard isMonitoring else { return }
    debugLog("[AppDelegate] stopEventTapMonitoring: Stopping...")

    currentInputMethod?.stop()
    currentInputMethod = nil
    resetSequenceState()
    self.isMonitoring = false

    debugLog("[AppDelegate] stopEventTapMonitoring: Stopped.")
  }

  // --- Force Reset Mechanism ---

  func forceResetState() {
    print("[AppDelegate] forceResetState: Performing nuclear state reset.")

    // Cancel all timers immediately

    // Force clear all state variables immediately (no delays, no callbacks)
    self.currentSequenceGroup = nil
    self.activeRootGroup = nil
    self.stickyModeToggled = false

    // Force hide the window immediately if it's visible
    if controller.window.isVisible {
      print("[AppDelegate] forceResetState: Force hiding window.")
      DispatchQueue.main.async {
        self.controller.window.orderOut(nil)
        self.controller.userState.clear()
      }
    }

    // Restart event tap monitoring to ensure clean state
    if isMonitoring {
      print("[AppDelegate] forceResetState: Restarting event monitoring for clean state.")
      let wasMonitoring = true
      stopEventTapMonitoring()

      // Brief delay to allow system cleanup before restart
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        if wasMonitoring {
          self.startEventTapMonitoring()
        }
      }
    }

    print("[AppDelegate] forceResetState: Nuclear reset completed.")
  }

  // This function is called when an activation shortcut is pressed or a socket/user command arrives.
  // It sets up the initial state for a new key sequence based on the loaded config.
  private func startSequence(
    activationType: Controller.ActivationType,
    bundleId: String? = nil
  ) {
    let spid = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: "startSequence", signpostID: spid)
    defer { os_signpost(.end, log: signpostLog, name: "startSequence", signpostID: spid) }
    debugLog("[AppDelegate] startSequence: Starting sequence with type: \(activationType)")

    // Reset sticky mode when starting any new sequence
    if stickyModeToggled {
      debugLog("[AppDelegate] startSequence: Resetting sticky mode for new sequence.")
      stickyModeToggled = false
    }

    // Get the root group determined by the show() method via the controller's UserState
    // UserState.activeRoot should have been set by Controller.show() just before this.
    guard let rootGroup = controller.userState.activeRoot else {
      // This should ideally not happen if Controller.show() worked correctly.
      debugLog(
        "[AppDelegate] startSequence: ERROR - controller.userState.activeRoot is nil! Falling back to default config root."
      )
      // Fallback logic, though this indicates a potential issue elsewhere
      self.activeRootGroup = config.root  // Store the determined root group locally
      self.currentSequenceGroup = config.root  // Start the sequence at this root
      // If the window is somehow visible, try to update its UI state.
      if self.controller.window.isVisible {
        debugLog(
          "[AppDelegate] startSequence (Fallback): Window visible, navigating UI to default root.")
        DispatchQueue.main.async {
          self.controller.userState.navigateToGroup(self.config.root)
        }
      }
      return
    }

    // Preprocess the config for fast lookups
    // Determine the bundle ID for caching
    let cacheId: String
    switch activationType {
    case .defaultOnly:
      cacheId = "global"
    case .appSpecificWithFallback:
      // Check if we have __FALLBACK__ bundleId
      if let overrideBundleId = bundleId, overrideBundleId == "__FALLBACK__" {
        cacheId = "fallback"
      } else {
        // Use bundleId from Karabiner (single source of truth)
        cacheId = bundleId ?? "global"
      }
    case .fallbackOnly:
      cacheId = "fallback"
    }

    // Store current bundle ID for later use
    self.currentBundleId = cacheId

    // Preprocess and cache the config for O(1) lookups
    let keyLookupCache = ConfigPreprocessor.shared.getOrCreateProcessedConfig(
      rootGroup, for: cacheId)
    self.controller.keyLookupCache = keyLookupCache

    debugLog(
      "[AppDelegate] startSequence: Preprocessed config for '\(cacheId)' with \(keyLookupCache.getCacheStats())"
    )

    // Store the root group for the current sequence and set the current level to the root.
    debugLog(
      "[AppDelegate] startSequence: Setting activeRootGroup and currentSequenceGroup to: '\(rootGroup.displayName)'"
    )
    self.activeRootGroup = rootGroup
    self.currentSequenceGroup = rootGroup

    // Pre-compute keycodes for sticky mode optimization
    var state = callbackState
    state.stickyModeKeycodes = keyLookupCache.getValidKeycodes(forGroupId: rootGroup.id)
    callbackState = state
    debugLog(
      "[AppDelegate] Pre-computed \(state.stickyModeKeycodes?.count ?? 0) keycodes for sticky mode")

    // If the window is already visible (e.g., reactivation with .reset), update the UI state.
    if self.controller.window.isVisible {
      debugLog("[AppDelegate] startSequence: Window is visible, updating UI state for root group.")
      DispatchQueue.main.async {
        // Ensure UI reflects the start of the sequence at the root group.
        self.controller.userState.navigateToGroup(rootGroup)
        // Reset window transparency when starting a new sequence
        self.controller.window.alphaValue = Defaults[.normalModeOpacity]
      }
    }
    debugLog("[AppDelegate] startSequence: Sequence setup complete.")
  }

  // Resets the internal state variables used to track the current key sequence.
  func resetSequenceState() {
    // Only perform reset if a sequence is actually active
    if currentSequenceGroup != nil || activeRootGroup != nil {
      debugLog(
        "[AppDelegate] resetSequenceState: Resetting sequence state (currentSequenceGroup and activeRootGroup to nil)."
      )
      self.currentSequenceGroup = nil
      self.activeRootGroup = nil

      // Clear pre-computed sticky-mode keycodes when sequence resets
      var state = callbackState
      state.stickyModeKeycodes = nil
      callbackState = state

      // Reset sticky mode toggle state
      if stickyModeToggled {
        debugLog("[AppDelegate] resetSequenceState: Resetting sticky mode toggle state.")
        self.stickyModeToggled = false
      }

      // Also tell the UserState to clear its navigation path etc. on the main thread
      DispatchQueue.main.async {
        debugLog("[AppDelegate] resetSequenceState: Dispatching UserState.clear() to main thread.")
        self.controller.userState.clear()
      }
    } else {
      debugLog("[AppDelegate] resetSequenceState: No active sequence to reset.")
    }
  }

  // Checks if the 'Sticky Mode' modifier key is held down.
  private func isInStickyMode(_ modifierFlags: NSEvent.ModifierFlags) -> Bool {
    let config = Defaults[.modifierKeyConfiguration]
    let modifierStickyMode: Bool
    switch config {
    case .controlGroupOptionSticky:
      modifierStickyMode = modifierFlags.contains(.command)
    case .optionGroupControlSticky:
      modifierStickyMode = modifierFlags.contains(.control)
    }

    // Sticky mode is active if either the modifier is held OR it's been toggled on
    let isSticky = modifierStickyMode || stickyModeToggled
    setStickyModeStatus(active: currentSequenceGroup != nil && isSticky)
    #if DEBUG
      print(
        "[AppDelegate] isInStickyMode: Config = \(config), Mods = \(describeModifiers(modifierFlags)), Toggled = \(stickyModeToggled), IsSticky = \(isSticky)"
      )
    #endif
    return isSticky
  }

  // Helper function to create a readable string for modifier flags
  private func describeModifiers(_ modifiers: NSEvent.ModifierFlags) -> String {
    var parts: [String] = []
    if modifiers.contains(.command) { parts.append("Cmd") }
    if modifiers.contains(.option) { parts.append("Opt") }
    if modifiers.contains(.control) { parts.append("Ctrl") }
    if modifiers.contains(.shift) { parts.append("Shift") }
    if modifiers.contains(.capsLock) { parts.append("CapsLock") }  // Include CapsLock for completeness
    if parts.isEmpty { return "[None]" }
    return "[" + parts.joined(separator: "][") + "]"
  }

  // --- Permissions Helpers ---
  // Checks if Accessibility permissions are granted *without* prompting the user.
  private func checkAccessibilityPermissions() -> Bool {
    // Method 1: Try CGPreflightListenEventAccess first - it's more reliable for immediate detection
    let hasEventAccess = CGPreflightListenEventAccess()

    // Method 2: Also check AXIsProcessTrustedWithOptions
    let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
    let options = [checkOptPrompt: false]  // Option to not prompt
    let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

    // Use either check - if either returns true, we have permissions
    let enabled = hasEventAccess || isTrusted

    print(
      "[AppDelegate] checkAccessibilityPermissions: CGPreflightListenEventAccess=\(hasEventAccess), AXIsProcessTrustedWithOptions=\(isTrusted), final=\(enabled)"
    )
    return enabled
  }

  // Start aggressive permission polling after showing the alert
  private func startPermissionPolling() {
    print("[AppDelegate] Starting aggressive permission polling...")
    permissionPollingStartTime = Date()

    // Stop any existing polling timer
    permissionPollingTimer?.invalidate()

    // Poll every 1 second for the first 30 seconds after prompt
    permissionPollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
      [weak self] _ in
      guard let self = self else { return }

      // Check if permissions are now granted
      if self.checkAccessibilityPermissions() {
        print("[AppDelegate] Permission polling: Permissions granted! Starting event tap...")
        self.permissionPollingTimer?.invalidate()
        self.permissionPollingTimer = nil
        self.startEventTapMonitoring()
        return
      }

      // Stop aggressive polling after 30 seconds
      if let startTime = self.permissionPollingStartTime,
        Date().timeIntervalSince(startTime) > 30.0
      {
        print("[AppDelegate] Permission polling: Timeout reached. Stopping aggressive polling.")
        self.permissionPollingTimer?.invalidate()
        self.permissionPollingTimer = nil
        // Regular health check will continue monitoring
      }
    }
  }

  // Shows the standard alert explaining why Accessibility is needed and offering to open Settings.
  private func showPermissionsAlert() {
    print("[AppDelegate] showPermissionsAlert: Displaying Accessibility permissions alert.")
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = "Accessibility Permissions May Be Required"
      // Final final attempt at formatting
      let line1 = "To activate Leader Key while another application is active, "
      let line2 = "macOS requires Accessibility permissions.\n\n"
      let line3 = "Consider enabling it in: "
      let line4 = "System Settings > Privacy & Security > Accessibility."
      alert.informativeText = line1 + line2 + line3 + line4
      alert.addButton(withTitle: "Open System Settings")
      alert.addButton(withTitle: "Cancel")
      if alert.runModal() == .alertFirstButtonReturn {
        let urlString =
          "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        let backupPath = "/System/Library/PreferencePanes/Security.prefPane"
        if let url = URL(string: urlString) {
          NSWorkspace.shared.open(url)
        } else {
          NSWorkspace.shared.open(URL(fileURLWithPath: backupPath))
        }

        // Start aggressive permission polling after user opens System Settings
        self.startPermissionPolling()
      }
    }
  }

  private func ensureControllerReady() {
    if state == nil {
      state = UserState(userConfig: config)
    }
    if controller == nil {
      controller = Controller(userState: state, userConfig: config, appDelegate: self)
    }
    if controller.window == nil {
      let windowClass = Theme.classFor(Defaults[.theme])
      controller.window = windowClass.init(controller: controller)
    }
  }

  // MARK: - InputMethodDelegate

  func inputMethodDidReceiveApplyConfig() {
    DispatchQueue.main.async { [weak self] in
      self?.applyExternalConfigChanges(trigger: "unix-socket")
    }
  }

  func inputMethodDidReceiveActivation(bundleId: String?) {
    // Handle activation from Karabiner
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.ensureControllerReady()

      debugLog("[ConfigDebug] activation bundleId from Karabiner: \(bundleId ?? "nil")")
      if let bundleId = bundleId {
        debugLog("[InputMethod] Activation received with bundleId: \(bundleId)")
      }

      // Reset Karabiner sticky mode when activating
      self.isKarabinerStickyMode = false

      // Determine activation type based on bundleId
      let activationType: Controller.ActivationType
      let activationContext: KarabinerActivationContext
      if bundleId == "__FALLBACK__" {
        activationType = .fallbackOnly
        activationContext = KarabinerActivationContext(
          mode: .fallbackOnly,
          bundleId: nil,
          activatedAt: Date()
        )
      } else if let bundleId = bundleId {
        activationType = .appSpecificWithFallback
        activationContext = KarabinerActivationContext(
          mode: .appSpecificWithFallback,
          bundleId: bundleId,
          activatedAt: Date()
        )
      } else {
        activationType = .defaultOnly
        activationContext = KarabinerActivationContext(
          mode: .defaultOnly,
          bundleId: nil,
          activatedAt: Date()
        )
      }
      self.karabinerActivationContext = activationContext

      // Check if window is already visible (same as handleActivation does)
      if self.controller.window.isVisible {
        debugLog("[InputMethod] Window is already visible, checking reactivation behavior")

        switch Defaults[.reactivateBehavior] {
        case .hide:
          // Hide the window if activated again while visible
          debugLog("[InputMethod] Reactivate behavior is 'hide'. Hiding window.")
          self.hide()
          return

        case .reset:
          // Reset the sequence if activated again while visible
          debugLog("[InputMethod] Reactivate behavior is 'reset'. Resetting sequence.")

          // Ensure window is visible and frontmost
          if !self.controller.window.isVisible {
            self.controller.window.orderFront(nil)
          }

          // Clear existing state
          self.controller.userState.clear()
          self.currentSequenceGroup = nil
          self.activeRootGroup = nil
          self.stickyModeToggled = false

          // Determine new active root based on activation type
          let newRoot: Group
          switch activationType {
          case .defaultOnly:
            newRoot = self.config.root
          case .appSpecificWithFallback:
            // Check if we have __FALLBACK__ bundleId
            if let bundleId = bundleId, bundleId == "__FALLBACK__" {
              // For __FALLBACK__, use merged config (same as no app-specific config)
              newRoot = self.config.getConfig(for: nil)
            } else {
              newRoot = self.config.getConfig(for: bundleId)
            }
          case .fallbackOnly:
            newRoot = self.config.getFallbackConfig()
          }
          self.controller.userState.activeRoot = newRoot
          self.controller.userState.isActive = true  // Ensure keys are processed after reset

          // Reposition and start new sequence
          self.controller.repositionWindowNearMouse()
          self.startSequence(activationType: activationType, bundleId: bundleId)

        case .nothing:
          // Do nothing if activated again while visible, unless no sequence is active
          debugLog("[InputMethod] Reactivate behavior is 'nothing'.")

          // Ensure window is visible
          if !self.controller.window.isVisible {
            self.controller.window.orderFront(nil)
          }

          // Start a sequence only if one wasn't already active
          if self.currentSequenceGroup == nil {
            debugLog("[InputMethod] No current sequence, starting new sequence.")
            self.controller.userState.isActive = true  // Ensure keys are processed
            self.startSequence(activationType: activationType, bundleId: bundleId)
          } else {
            debugLog("[InputMethod] Sequence already active, doing nothing.")
          }
        }
      } else {
        // Window not visible, show it and start sequence
        debugLog("[InputMethod] Window not visible, showing and starting sequence")

        // Show the window (this sets up userState.activeRoot)
        // Pass bundleId to handle __FALLBACK__ correctly
        self.controller.show(type: activationType, bundleId: bundleId) {
          // After window is shown, initialize sequence state
          // This matches what handleActivation() does for CGEventTap mode
          self.startSequence(activationType: activationType, bundleId: bundleId)
        }
      }
    }
  }

  func inputMethodDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
    // Handle key event from Karabiner
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      debugLog("[InputMethod] Key received: \(keyCode), modifiers: \(modifiers)")

      // Process the key through the normal flow
      if self.controller.userState.isActive {
        if keyCode == 57 {
          // Primary Caps Lock cancel comes from the user's Goku to_if_alone rule.
          // This fallback keeps direct socket/legacy key input consistent if key 57 reaches the app.
          debugLog("[InputMethod] Caps Lock key received while active; deactivating")
          self.controller.hide()
          self.resetSequenceState()
          return
        }

        // Convert keyCode to character
        guard let character = self.keyCodeToCharacter(keyCode) else {
          debugLog("[InputMethod] Unable to convert keyCode \(keyCode) to character")
          return
        }

        debugLog("[InputMethod] Processing key '\(character)'")
        self.controller.handleKey(character, withModifiers: modifiers)
      }
    }
  }

  private func keyCodeToCharacter(_ keyCode: UInt16) -> String? {
    // Map common keycodes to their character representations
    switch keyCode {
    // Letters
    case 0: return "a"
    case 1: return "s"
    case 2: return "d"
    case 3: return "f"
    case 4: return "h"
    case 5: return "g"
    case 6: return "z"
    case 7: return "x"
    case 8: return "c"
    case 9: return "v"
    case 11: return "b"
    case 12: return "q"
    case 13: return "w"
    case 14: return "e"
    case 15: return "r"
    case 16: return "y"
    case 17: return "t"
    case 18: return "1"
    case 19: return "2"
    case 20: return "3"
    case 21: return "4"
    case 22: return "6"
    case 23: return "5"
    case 24: return "="
    case 25: return "9"
    case 26: return "7"
    case 27: return "-"
    case 28: return "8"
    case 29: return "0"
    case 30: return "]"
    case 31: return "o"
    case 32: return "u"
    case 33: return "["
    case 34: return "i"
    case 35: return "p"
    case 36: return "\r"  // Return
    case 37: return "l"
    case 38: return "j"
    case 39: return "'"
    case 40: return "k"
    case 41: return ";"
    case 42: return "\\"
    case 43: return ","
    case 44: return "/"
    case 45: return "n"
    case 46: return "m"
    case 47: return "."
    case 48: return "\t"  // Tab
    case 49: return " "  // Space
    case 50: return "`"
    case 51: return "\u{7F}"  // Delete/Backspace
    case 53: return "\u{1B}"  // Escape
    default: return nil
    }
  }

  func inputMethodDidReceiveDeactivation() {
    // Handle deactivation from Karabiner
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      debugLog("[InputMethod] Deactivation received")
      self.karabinerActivationContext = nil
      
      // Reset Karabiner sticky mode flag and opacity
      if self.isKarabinerStickyMode {
        self.isKarabinerStickyMode = false
        self.controller.window.alphaValue = Defaults[.normalModeOpacity]
      }

      if self.controller.userState.isActive {
        self.controller.hide()
        self.resetSequenceState()  // Reset sequence state to match CGEventTap behavior
      }
    }
  }

  func inputMethodDidReceiveSettings() {
    // Handle settings command from Karabiner
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      debugLog("[InputMethod] Settings command received")
      self.karabinerActivationContext = nil
      
      // If Leader Key is active, hide it and reset state (like deactivate does)
      if self.controller.userState.isActive {
        self.controller.hide()
        self.resetSequenceState()
      }
      
      // Call the settings menu item action handler to open settings
      self.settingsMenuItemActionHandler(NSMenuItem())
    }
  }

  func inputMethodDidReceiveSequence(_ sequence: String) {
    // Handle key sequence from Karabiner
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      debugLog("[InputMethod] Sequence received: \(sequence)")

      // Parse and process the sequence
      // This could be used for multi-key shortcuts sent from Karabiner
    }
  }
  
  func inputMethodDidReceiveStateId(_ stateId: Int32, sticky: Bool = false, bundleId: String? = nil) {
    // Handle state ID from Karabiner 2.0
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.ensureControllerReady()
      
      debugLog(
        "[InputMethod] State ID received: \(stateId), sticky: \(sticky), bundleId: \(bundleId ?? "nil")"
      )
      
      // Look up the action by state ID and execute it
      self.executeActionByStateId(stateId, sticky: sticky, bundleId: bundleId)
    }
  }

  func inputMethodDidReceiveShake() {
    // Handle shake command from catch-all rule
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      debugLog("[InputMethod] Shake command received - undefined key pressed")
      
      // Call notFound which handles shake properly for each theme
      self.controller.window?.notFound()
    }
  }

  func inputMethodDidRequestState() -> [String: Any] {
    // Return current Leader Key state
    return [
      "active": controller.userState.isActive,
      "currentGroup": controller.userState.currentGroup?.label ?? "",
      "bundleId": NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "",
    ]
  }
  
  // MARK: - State ID Action Execution
  
  private func loadStateMappings() {
    let mappingFilePath = (Defaults[.configDir] as NSString).appendingPathComponent("export/leaderkey-state-mappings.json")
    
    guard FileManager.default.fileExists(atPath: mappingFilePath) else {
      debugLog("[AppDelegate] State mappings file not found at: \(mappingFilePath)")
      return
    }
    
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: mappingFilePath))
      let decoder = JSONDecoder()
      let mappings = try decoder.decode([Karabiner2Exporter.StateMapping].self, from: data)
      
      // Convert to dictionary for O(1) lookup
      stateMappings.removeAll()
      for mapping in mappings {
        stateMappings[mapping.stateId] = mapping
      }
      
      stateMappingsLastLoaded = Date()
      debugLog("[AppDelegate] Loaded \(mappings.count) state mappings")
      
      // Actions are resolved lazily because appShared mappings depend on the activation context.
      actionCache.removeAll(keepingCapacity: true)
      
    } catch {
      debugLog("[AppDelegate] Failed to load state mappings: \(error)")
    }
  }
  
  private func refreshStateMappingsIfNeeded() {
    guard Defaults[.inputMethodPreference] == .karabiner2 else {
      return
    }

    exportRefreshQueue.async { [weak self] in
      guard let self else { return }

      // Debounce: skip if an export started within the last 2 seconds
      let sinceLastStart = CFAbsoluteTimeGetCurrent() - self.lastExportStartTime
      if sinceLastStart < 2.0 {
        debugLog("[AppDelegate] Export refresh skipped (started \(String(format: "%.0f", sinceLastStart * 1000))ms ago)")
        return
      }

      if self.isExportRefreshInFlight {
        self.hasPendingExportRefresh = true
        debugLog("[AppDelegate] Export refresh already running; coalescing request")
        return
      }

      self.isExportRefreshInFlight = true
      self.lastExportStartTime = CFAbsoluteTimeGetCurrent()
      self.runExportRefresh()
    }
  }

  /// Runs the export pipeline and reloads state mappings from the exported file.
  ///
  /// **Ordering dependency**: `exportCurrentConfiguration` MUST write the state mappings file
  /// synchronously before returning. `loadStateMappings()` reads that same file immediately after.
  /// See `Karabiner2InputMethod.exportUsingKarabinerTS` for the full pipeline flow diagram.
  private func runExportRefresh() {
    debugLog("[AppDelegate] Refreshing state mappings after config change")
    let karabiner2Method = (currentInputMethod as? Karabiner2InputMethod) ?? Karabiner2InputMethod()
    karabiner2Method.exportCurrentConfiguration(caller: "refreshStateMappings")

    // Reads export/leaderkey-state-mappings.json written synchronously by exportUsingKarabinerTS above.
    DispatchQueue.main.async { [weak self] in
      self?.loadStateMappings()
    }

    exportRefreshQueue.async { [weak self] in
      guard let self else { return }

      self.isExportRefreshInFlight = false

      if self.hasPendingExportRefresh {
        self.hasPendingExportRefresh = false
        // Skip coalesced run — the export we just finished already
        // picked up the latest config state from disk.
        debugLog("[AppDelegate] Skipping coalesced export (just completed)")
      }
    }
  }

  private func refreshActiveSequenceAfterReloadIfNeeded() {
    guard controller.userState.isActive || currentSequenceGroup != nil || activeRootGroup != nil else {
      return
    }

    let childGroupKeys = Array(controller.userState.navigationPath.dropFirst()).compactMap(\.key)
    let cacheId = currentBundleId ?? "global"

    let refreshedRoot: Group
    switch cacheId {
    case "fallback":
      refreshedRoot = config.getMarkedFallbackConfig()
    case "global":
      refreshedRoot = config.root
    default:
      refreshedRoot = config.getConfig(for: cacheId)
    }

    let keyLookupCache = ConfigPreprocessor.shared.getOrCreateProcessedConfig(refreshedRoot, for: cacheId)
    controller.keyLookupCache = keyLookupCache

    var refreshedNavigationPath: [Group] = [refreshedRoot]
    var currentGroup = refreshedRoot

    for key in childGroupKeys {
      guard let nextGroup = currentGroup.actions.compactMap({ item -> Group? in
        guard case .group(let group) = item else { return nil }
        return group.key == key ? group : nil
      }).first else {
        break
      }

      refreshedNavigationPath.append(nextGroup)
      currentGroup = nextGroup
    }

    activeRootGroup = refreshedRoot
    currentSequenceGroup = refreshedNavigationPath.last ?? refreshedRoot
    controller.userState.activeRoot = refreshedRoot
    controller.userState.navigationPath = refreshedNavigationPath

    var state = callbackState
    state.stickyModeKeycodes = keyLookupCache.getValidKeycodes(forGroupId: currentGroup.id)
    callbackState = state

    debugLog("[AppDelegate] Refreshed active sequence after config reload")
  }

  private func activationType(for contextMode: KarabinerActivationContext.Mode) -> Controller.ActivationType {
    switch contextMode {
    case .defaultOnly:
      return .defaultOnly
    case .appSpecificWithFallback:
      return .appSpecificWithFallback
    case .fallbackOnly:
      return .fallbackOnly
    }
  }

  private func bundleIdForShow(context: KarabinerActivationContext) -> String? {
    switch context.mode {
    case .defaultOnly:
      return nil
    case .appSpecificWithFallback:
      return context.bundleId
    case .fallbackOnly:
      return "__FALLBACK__"
    }
  }

  private func appSpecificContext(
    bundleId: String?,
    activatedAt: Date
  ) -> KarabinerActivationContext? {
    guard let bundleId = bundleId?.trimmingCharacters(in: .whitespacesAndNewlines),
          !bundleId.isEmpty,
          bundleId != "__FALLBACK__"
    else {
      return nil
    }
    return KarabinerActivationContext(
      mode: .appSpecificWithFallback,
      bundleId: bundleId,
      activatedAt: activatedAt
    )
  }

  private func resolvedActivationContext(
    for mapping: Karabiner2Exporter.StateMapping,
    explicitBundleId: String? = nil
  ) -> KarabinerActivationContext {
    let activatedAt = karabinerActivationContext?.activatedAt ?? Date()

    switch mapping.scope {
    case .global:
      return KarabinerActivationContext(mode: .defaultOnly, bundleId: nil, activatedAt: activatedAt)

    case .fallbackOnly:
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activatedAt)

    case .appShared:
      if let context = appSpecificContext(bundleId: explicitBundleId, activatedAt: activatedAt) {
        return context
      }
      if let activationContext = karabinerActivationContext {
        switch activationContext.mode {
        case .defaultOnly:
          return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activationContext.activatedAt)
        case .appSpecificWithFallback, .fallbackOnly:
          return activationContext
        }
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activatedAt)

    case .appOverride, .appSuppress:
      if let context = appSpecificContext(bundleId: mapping.bundleId, activatedAt: activatedAt) {
        return context
      }
      if let context = appSpecificContext(bundleId: explicitBundleId, activatedAt: activatedAt) {
        return context
      }
      if let activationContext = karabinerActivationContext,
         activationContext.mode == .appSpecificWithFallback {
        return activationContext
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activatedAt)

    case .normalShared:
      if let bundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier {
        return KarabinerActivationContext(mode: .appSpecificWithFallback, bundleId: bundleId, activatedAt: activatedAt)
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activatedAt)

    case .normalOverride, .normalSuppress:
      if let bundleId = mapping.bundleId {
        return KarabinerActivationContext(mode: .appSpecificWithFallback, bundleId: bundleId, activatedAt: activatedAt)
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activatedAt)
    }
  }

  private func cacheId(for context: KarabinerActivationContext) -> String {
    switch context.mode {
    case .defaultOnly:
      return "global"
    case .appSpecificWithFallback:
      return context.bundleId ?? "global"
    case .fallbackOnly:
      return "fallback"
    }
  }

  private func configKey(for context: KarabinerActivationContext) -> String {
    switch context.mode {
    case .defaultOnly:
      return globalDefaultDisplayName
    case .appSpecificWithFallback:
      return config.configKey(forBundleId: context.bundleId)
    case .fallbackOnly:
      return defaultAppConfigDisplayName
    }
  }

  private func applyRegularSequenceContext(
    mapping: Karabiner2Exporter.StateMapping,
    activationContext: KarabinerActivationContext
  ) {
    let resolvedRoot = rootGroupForMapping(mapping, activationContext: activationContext)
    let previousContext = karabinerActivationContext
    let contextChanged =
      previousContext?.mode != activationContext.mode || previousContext?.bundleId != activationContext.bundleId
    let shouldResetNavigation =
      contextChanged ||
      !controller.userState.isActive ||
      controller.userState.activeRoot == nil ||
      controller.userState.navigationPath.isEmpty
    let root = shouldResetNavigation ? resolvedRoot : (controller.userState.activeRoot ?? resolvedRoot)
    let cacheId = cacheId(for: activationContext)
    let cache = ConfigPreprocessor.shared.getOrCreateProcessedConfig(root, for: cacheId)

    controller.userState.activeRoot = root
    controller.userState.activeBundleId =
      activationContext.mode == .appSpecificWithFallback ? activationContext.bundleId : nil
    controller.userState.activeConfigKey = configKey(for: activationContext)
    if shouldResetNavigation {
      controller.userState.navigationPath = [root]
    }
    controller.userState.display = nil
    controller.userState.isActive = true

    activeRootGroup = root
    if shouldResetNavigation || currentSequenceGroup == nil {
      currentSequenceGroup = controller.userState.navigationPath.last ?? root
    }
    currentBundleId = cacheId
    karabinerActivationContext = activationContext

    controller.keyLookupCache = cache

    var callback = callbackState
    callback.stickyModeKeycodes = cache.getValidKeycodes(forGroupId: root.id)
    callbackState = callback
  }

  private func isNormalModeScope(_ scope: Karabiner2Exporter.StateMapping.Scope) -> Bool {
    switch scope {
    case .normalShared, .normalOverride, .normalSuppress:
      return true
    case .global, .fallbackOnly, .appShared, .appOverride, .appSuppress:
      return false
    }
  }

  private func rootGroupForMapping(
    _ mapping: Karabiner2Exporter.StateMapping,
    activationContext: KarabinerActivationContext?
  ) -> Group {
    switch mapping.scope {
    case .global:
      return config.root

    case .fallbackOnly:
      return config.getFallbackConfig()

    case .appShared:
      guard let activationContext else {
        return config.getFallbackConfig()
      }
      switch activationContext.mode {
      case .defaultOnly, .fallbackOnly:
        return config.getFallbackConfig()
      case .appSpecificWithFallback:
        return config.getConfig(for: activationContext.bundleId)
      }

    case .appOverride, .appSuppress:
      let bundleId = activationContext?.bundleId ?? mapping.bundleId
      return config.getConfig(for: bundleId)

    case .normalShared:
      guard let activationContext else {
        return config.getNormalFallbackConfig()
      }
      switch activationContext.mode {
      case .defaultOnly, .fallbackOnly:
        return config.getNormalFallbackConfig()
      case .appSpecificWithFallback:
        return config.getNormalConfig(for: activationContext.bundleId)
      }

    case .normalOverride, .normalSuppress:
      let bundleId = activationContext?.bundleId ?? mapping.bundleId
      return config.getNormalConfig(for: bundleId)
    }
  }
  
  private func findActionForMapping(
    _ mapping: Karabiner2Exporter.StateMapping,
    activationContext: KarabinerActivationContext
  ) -> Action? {
    let rootGroup = rootGroupForMapping(mapping, activationContext: activationContext)

    if let action = Self.resolveAction(in: rootGroup, path: mapping.path) {
      return action
    }

    let pathDescription = mapping.path.joined(separator: " ")
    debugLog(
      "[AppDelegate] Could not find action for state ID \(mapping.stateId) " +
        "at path: \(pathDescription)"
    )
    return nil
  }

  static func resolveAction(in rootGroup: Group, path: [String]) -> Action? {
    resolveAction(in: rootGroup.actions, path: ArraySlice(path))
  }

  private static func resolveAction(in items: [ActionOrGroup], path: ArraySlice<String>) -> Action? {
    guard let key = path.first else {
      return nil
    }

    if path.count == 1 {
      for item in items {
        switch item {
        case .action(let action) where action.key == key:
          return action
        case .layer(let layer) where layer.key == key:
          return layer.tapAction
        default:
          continue
        }
      }
      return nil
    }

    let remainingPath = path.dropFirst()
    for item in items {
      switch item {
      case .group(let group) where group.key == key:
        return resolveAction(in: group.actions, path: remainingPath)
      case .layer(let layer) where layer.key == key:
        return resolveAction(in: layer.actions, path: remainingPath)
      default:
        continue
      }
    }

    return nil
  }

  private func cachedAction(
    for mapping: Karabiner2Exporter.StateMapping,
    activationContext: KarabinerActivationContext
  ) -> Action? {
    let cacheKey = ActionCacheKey(
      stateId: mapping.stateId,
      mode: activationContext.mode,
      bundleId: activationContext.mode == .appSpecificWithFallback ? activationContext.bundleId : nil
    )

    if let cachedAction = actionCache[cacheKey] {
      return cachedAction
    }

    guard let action = findActionForMapping(mapping, activationContext: activationContext) else {
      return nil
    }

    actionCache[cacheKey] = action
    return action
  }
  
  private func executeActionByStateId(
    _ stateId: Int32,
    sticky: Bool = false,
    bundleId: String? = nil
  ) {
    // Load mappings if they haven't been loaded yet
    if stateMappingsLastLoaded == nil {
      loadStateMappings()
    }

    guard let mapping = stateMappings[stateId] else {
      debugLog("[AppDelegate] No mapping found for state ID: \(stateId)")
      return
    }

    let activationContext = resolvedActivationContext(for: mapping, explicitBundleId: bundleId)
    let isNormalModeDispatch = isNormalModeScope(mapping.scope)
    let activationType = activationType(for: activationContext.mode)
    let activationBundleId = bundleIdForShow(context: activationContext)

    debugLog(
      "[AppDelegate] Found mapping for state ID \(stateId): scope=\(mapping.scope.rawValue), " +
        "type=\(mapping.actionType), label=\(mapping.actionLabel ?? "unknown"), " +
        "bundleId=\(mapping.bundleId ?? "nil"), explicitBundle=\(bundleId ?? "nil"), activeBundle=\(activationBundleId ?? "nil")")

    if !isNormalModeDispatch {
      applyRegularSequenceContext(mapping: mapping, activationContext: activationContext)
    }

    // Helper: ensure window is visible with the correct config, then run continuation
    let ensureWindowVisible: (@escaping () -> Void) -> Void = { [weak self] continuation in
      guard let self = self else { return }
      if self.controller.window.isVisible {
        continuation()
      } else {
        debugLog("[AppDelegate] Window not visible, showing with bundleId: \(activationBundleId ?? "nil")")
        self.controller.show(type: activationType, bundleId: activationBundleId) {
          self.startSequence(activationType: activationType, bundleId: activationBundleId)
          continuation()
        }
      }
    }

    // Check if this is a group state or an action state
    if mapping.actionType == "group" {
      if isNormalModeDispatch {
        debugLog("[AppDelegate] Ignoring normal-mode group state ID \(stateId); group transitions are handled by Karabiner")
        return
      }

      // This is a group state - show window if needed, then navigate
      debugLog("[AppDelegate] State ID \(stateId) is a group, simulating key navigation for path: \(mapping.path)")

      ensureWindowVisible { [weak self] in
        guard let self = self else { return }

        guard let rootGroup = self.controller.userState.activeRoot else {
          debugLog("[AppDelegate] No active root group")
          return
        }

        // Clear current navigation to start fresh from root
        self.controller.userState.clear()
        self.controller.userState.activeRoot = rootGroup
        self.controller.userState.isActive = true
        self.currentSequenceGroup = rootGroup

        // Simulate pressing each key in the path to navigate to the target group
        for key in mapping.path {
          debugLog("[AppDelegate] Simulating key press: '\(key)'")
          self.controller.handleKey(key)
        }
      }

    } else if mapping.actionType == "action" {
      // This is an action state - execute it
      debugLog("[AppDelegate] State ID \(stateId) is an action, executing")

      // Resolve lazily so shared fallback state IDs use the current app context when needed.
      if let cachedAction = cachedAction(for: mapping, activationContext: activationContext) {
        if isNormalModeDispatch {
          debugLog("[AppDelegate] Executing normal-mode action silently")
          controller.runAction(cachedAction)
          return
        }

        if sticky {
          // In sticky mode, show window if needed, then execute action
          ensureWindowVisible { [weak self] in
            guard let self = self else { return }
            debugLog("[AppDelegate] Executing action in sticky mode - keeping popup open")
            self.isKarabinerStickyMode = true
            self.controller.window.alphaValue = Defaults[.stickyModeOpacity]
            self.controller.runAction(cachedAction)
          }
        } else {
          // Normal mode - execute action, hide if window is visible
          if controller.window.isVisible {
            controller.hide {
              self.controller.runAction(cachedAction)
            }
          } else {
            controller.runAction(cachedAction)
          }
        }
        debugLog("[AppDelegate] Executed cached action for state ID \(stateId): \(cachedAction.value) with \(cachedAction.macroSteps?.count ?? 0) macro steps, sticky: \(sticky)")
      } else {
        debugLog("[AppDelegate] No action found for state ID \(stateId). This may happen if the config changed since mappings were exported.")
      }
    } else {
      debugLog("[AppDelegate] Unknown action type for state ID \(stateId): \(mapping.actionType)")
    }
  }
}
