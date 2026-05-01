// swiftlint:disable file_length
import Cocoa
import Combine
import Defaults
import KeyboardShortcuts
import Kingfisher
import ObjectiveC
import os
import Settings
import Sparkle
import SwiftUI
import UserNotifications

let updateLocationIdentifier = "UpdateCheck"

// Define the same unique tag here
private let leaderKeySyntheticEventTag: Int64 = 0xDEAD_BEEF

// MARK: - Legacy Event Tap Callback (removed — Karabiner 2.0 is the only input method)

// MARK: - Key Code Constants (Example)

// Define key codes for easier reference
struct KeyCodes {
  static let keyK: UInt16 = 40
  static let escape: UInt16 = 53
  // Add other key codes as needed
}

// MARK: - Key Event Queue Structure
private struct QueuedKeyEvent {
  let cgEvent: CGEvent
  let nsEvent: NSEvent  // Cache NSEvent to avoid re-conversion
  let keyCode: UInt16
  let modifiers: NSEvent.ModifierFlags
}

private let maxQueueSize = 3  // Reduced queue size to minimize latency

// MARK: - Callback Optimization State
// Consolidated state struct to reduce associated object lookups
private struct CallbackOptimizationState {
  var hasPendingActivation: Bool = false
  var lastActivationTime: CFAbsoluteTime = 0
  var stickyModeKeycodes: Set<UInt16>? = nil  // Pre-computed for O(1) lookup
  // Note: Other state like currentSequenceGroup is kept separate as it's
  // accessed from many places and needs proper synchronization
}

// MARK: - Performance Monitoring

// High-precision timing utilities using mach_absolute_time
private struct MachTime {
  private static var timebaseInfo: mach_timebase_info = {
    var info = mach_timebase_info()
    mach_timebase_info(&info)
    return info
  }()

  static func now() -> UInt64 {
    return mach_absolute_time()
  }

  static func toMilliseconds(_ machTime: UInt64) -> Double {
    let nanos = machTime * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)
    return Double(nanos) / 1_000_000.0
  }

  static func toMicroseconds(_ machTime: UInt64) -> Double {
    let nanos = machTime * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)
    return Double(nanos) / 1_000.0
  }
}

// Statistics tracking for callback performance
private struct CallbackStatistics {
  var totalCallbacks: Int64 = 0
  var totalDuration: Double = 0  // in milliseconds
  var slowCallbacks: Int64 = 0  // callbacks > 1ms
  var verySlowCallbacks: Int64 = 0  // callbacks > 5ms
  var maxDuration: Double = 0
  var minDuration: Double = Double.infinity
  var lastDuration: Double = 0
  var lastResetTime = Date()

  // Histogram buckets for percentile calculation (in ms)
  var histogram: [Double: Int64] = [
    0.1: 0,  // < 0.1ms
    0.5: 0,  // 0.1-0.5ms
    1.0: 0,  // 0.5-1ms
    5.0: 0,  // 1-5ms
    10.0: 0,  // 5-10ms
    Double.infinity: 0,  // > 10ms
  ]

  mutating func record(duration: Double) {
    totalCallbacks += 1
    totalDuration += duration
    lastDuration = duration

    if duration > maxDuration { maxDuration = duration }
    if duration < minDuration { minDuration = duration }
    if duration > 1.0 { slowCallbacks += 1 }
    if duration > 5.0 {
      verySlowCallbacks += 1
      print("[PERF WARNING] Callback took \(String(format: "%.2f", duration))ms")
    }

    // Update histogram
    for bucket in histogram.keys.sorted() {
      if duration <= bucket {
        histogram[bucket]! += 1
        break
      }
    }
  }

  var averageDuration: Double {
    totalCallbacks > 0 ? totalDuration / Double(totalCallbacks) : 0
  }

  var slowPercentage: Double {
    totalCallbacks > 0 ? (Double(slowCallbacks) / Double(totalCallbacks)) * 100 : 0
  }

  mutating func reset() {
    totalCallbacks = 0
    totalDuration = 0
    slowCallbacks = 0
    verySlowCallbacks = 0
    maxDuration = 0
    minDuration = Double.infinity
    lastDuration = 0
    lastResetTime = Date()
    histogram.keys.forEach { histogram[$0] = 0 }
  }

  var summary: String {
    if totalCallbacks == 0 { return "No callbacks recorded" }

    return """
      Callback Performance Stats (since \(lastResetTime.formatted())):
      - Total callbacks: \(totalCallbacks)
      - Average: \(String(format: "%.3f", averageDuration))ms
      - Min/Max: \(String(format: "%.3f", minDuration))ms / \(String(format: "%.3f", maxDuration))ms
      - Last: \(String(format: "%.3f", lastDuration))ms
      - Slow (>1ms): \(slowCallbacks) (\(String(format: "%.1f", slowPercentage))%)
      - Very slow (>5ms): \(verySlowCallbacks)
      """
  }
}

// MARK: - Associated Object Helpers

// Helper functions for associated objects (needed for storing properties in extensions)
// Moved *before* the extensions that use them.
private func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
  return objc_getAssociatedObject(object, key) as? T
}

private func setAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T?) {
  objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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

  lazy var settingsWindowController = SettingsWindowController(
    panes: [
      Settings.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!,
        contentView: { GeneralPane().environmentObject(self.config) }
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
    let coordinator = VoiceCoordinator(statusItem: statusItem)
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
      case .global, .appFallback, .normalFallback, .unknown:
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

  // MARK: - Command Key Release Handling Methods

  private func handleCommandPressed(_ modifierFlags: NSEvent.ModifierFlags) {
    // Command key press is tracked but no action needed on press
    // We only act on release
    debugLog("[AppDelegate] handleCommandPressed: Command key pressed")
  }

  private func handleCommandReleased(_ modifierFlags: NSEvent.ModifierFlags) {
    // Only reset and close if the setting is enabled and we're in a sequence
    guard Defaults[.resetOnCmdRelease] && currentSequenceGroup != nil else {
      return
    }

    // Also check that we're in the correct modifier configuration (command used for sticky mode)
    let config = Defaults[.modifierKeyConfiguration]
    guard config == .controlGroupOptionSticky else {
      return
    }

    // If we still have an active activation shortcut, this means the user hasn't
    // started using Leader Key yet, so ignore this Cmd release (it's part of the activation)
    if activeActivationShortcut != nil {
      debugLog(
        "[AppDelegate] handleCommandReleased: Still have active activation shortcut - user hasn't started using Leader Key yet. Ignoring."
      )
      return
    }

    debugLog(
      "[AppDelegate] handleCommandReleased: Command key released with resetOnCmdRelease enabled. Hiding window (state resets after close)."
    )
    DispatchQueue.main.async {
      debugLog("[AppDelegate] handleCommandReleased: Hiding window – state will reset after close.")
      self.hide()
    }
  }

  // --- Activation Logic (Called by Event Tap) ---
  func handleActivation(
    type: Controller.ActivationType, activationShortcut: KeyboardShortcuts.Shortcut? = nil
  ) {
    let spid = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: "handleActivation", signpostID: spid, "type=%{public}s", String(describing: type))
    defer { os_signpost(.end, log: signpostLog, name: "handleActivation", signpostID: spid) }
    debugLog("[AppDelegate] handleActivation: Received activation request of type: \(type)")
    // Track the activation shortcut to prevent immediate command release triggers
    activeActivationShortcut = activationShortcut

    // This function decides what to do when an activation shortcut is pressed.

    if controller.window.isVisible {  // Check if the Leader Key window is already visible
      debugLog("[AppDelegate] handleActivation: Window is already visible.")
      switch Defaults[.reactivateBehavior] {  // Check user preference for reactivation
      case .hide:
        // Preference: Hide the window if activated again while visible.
        debugLog(
          "[AppDelegate] handleActivation: Reactivate behavior is 'hide'. Hiding window and resetting sequence."
        )
        hide()
        return  // Stop processing here

      case .reset:
        // Preference: Reset the sequence if activated again while visible.
        debugLog("[AppDelegate] handleActivation: Reactivate behavior is 'reset'. Resetting sequence.")
        // Ensure window is visible and frontmost (but not key to avoid interfering with overlays)
        if !controller.window.isVisible {
          debugLog("[AppDelegate] handleActivation (Reset): Making window visible.")
          controller.window.orderFront(nil)  // Just bring to front without making key
        }
        // Clear existing UI state and perform a lightweight in-place reset of internal trackers.
        controller.userState.clear()
        self.currentSequenceGroup = nil
        self.activeRootGroup = nil
        self.stickyModeToggled = false
        self.lastModifierFlags = []
        // Determine new active root based on the activation shortcut that was just pressed
        do {
          let newRoot: Group
          switch type {
          case .defaultOnly:
            newRoot = self.config.root
          case .appSpecificWithFallback:
            newRoot = self.config.getConfig(for: NSWorkspace.shared.frontmostApplication?.bundleIdentifier)
          case .fallbackOnly:
            newRoot = self.config.getFallbackConfig()
          }
          self.controller.userState.activeRoot = newRoot
        }
        debugLog("[AppDelegate] handleActivation (Reset): Starting new sequence.")
        controller.repositionWindowNearMouse()
        startSequence(activationType: type)

      case .nothing:
        // Preference: Do nothing if activated again while visible, unless window lost focus.
        debugLog("[AppDelegate] handleActivation: Reactivate behavior is 'nothing'.")
        // Ensure window is visible (but not key to avoid interfering with overlays)
        if !controller.window.isVisible {
          debugLog("[AppDelegate] handleActivation (Nothing): Making window visible.")
          controller.window.orderFront(nil)  // Just bring to front without making key
        }
        // Start a sequence only if one wasn't already active (e.g., if Escape was pressed before).
        // This prevents restarting if the user just presses the shortcut again mid-sequence.
        if currentSequenceGroup == nil {
          debugLog(
            "[AppDelegate] handleActivation (Nothing): No current sequence, starting new sequence.")
          startSequence(activationType: type)
        } else {
          debugLog("[AppDelegate] handleActivation (Nothing): Sequence already active, doing nothing.")
        }
      }
    } else {
      // Show window invisibly; when ready, start sequence, then the window will reveal.
      show(type: type) {
        self.startSequence(activationType: type)
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
    case .willReload:
      isReloading = true
      #if DEBUG
        debugLog("[AppDelegate] Config reload started - pausing event processing")
      #endif
    case .didReload:
      isReloading = false
      refreshStateMappings()
      refreshActiveSequenceAfterReload()
      statusItem.indicateReloadSuccess()
      #if DEBUG
        debugLog("[AppDelegate] Config reload completed - resuming event processing")
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

  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool) {
    debugLog("[AppDelegate] Control socket state ID: \(stateId), sticky: \(sticky)")
    recordSocketTransportState(0)
    inputMethodDidReceiveStateId(stateId, sticky: sticky)
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
      var report: [String: Any] = [
        "action_id": actionId,
        "blocked": false,
        "dry_run": dryRun,
        "executed": false,
        "label": label,
        "requires_confirmation": requiresConfirmation || safety == "confirm",
        "type": actionType,
      ]

      guard safety != "block" else {
        report["blocked"] = true
        report["reason"] = "action marked blocked"
        reports.append(report)
        continue
      }

      guard !(requiresConfirmation || safety == "confirm") else {
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

      guard action.type != .command, !dispatchActionContainsCommand(action) else {
        report["blocked"] = true
        report["reason"] = "voice dispatch blocks command actions"
        reports.append(report)
        continue
      }

      reports.append(report)
      resolved.append((index: reports.count - 1, action: action))
    }

    let blocked = reports.contains { ($0["blocked"] as? Bool) == true }
    let needsConfirmation = reports.contains { ($0["requires_confirmation"] as? Bool) == true }
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

    for item in resolved {
      controller.runAction(item.action)
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

  // --- Event Tap Properties (Using Associated Objects) ---
  private var eventTap: CFMachPort? {
    get { getAssociatedObject(self, &AssociatedKeys.eventTap) }
    set { setAssociatedObject(self, &AssociatedKeys.eventTap, newValue) }
  }
  private var runLoopSource: CFRunLoopSource? {
    get { getAssociatedObject(self, &AssociatedKeys.runLoopSource) }
    set { setAssociatedObject(self, &AssociatedKeys.runLoopSource, newValue) }
  }
  private var isMonitoring: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.isMonitoring) ?? false }
    set { setAssociatedObject(self, &AssociatedKeys.isMonitoring, newValue) }
  }
  private var activeRootGroup: Group? {
    get { getAssociatedObject(self, &AssociatedKeys.activeRootGroup) }
    set { setAssociatedObject(self, &AssociatedKeys.activeRootGroup, newValue) }
  }
  private var currentSequenceGroup: Group? {
    get { getAssociatedObject(self, &AssociatedKeys.currentSequenceGroup) }
    set { setAssociatedObject(self, &AssociatedKeys.currentSequenceGroup, newValue) }
  }
  private var isProcessingKey: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.isProcessingKey) ?? false }
    set { setAssociatedObject(self, &AssociatedKeys.isProcessingKey, newValue) }
  }
  private var keyEventQueue: [QueuedKeyEvent] {
    get { getAssociatedObject(self, &AssociatedKeys.keyEventQueue) ?? [] }
    set { setAssociatedObject(self, &AssociatedKeys.keyEventQueue, newValue) }
  }
  private var didShowPermissionsAlertRecently: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.didShowPermissionsAlertRecently) ?? false }
    set { setAssociatedObject(self, &AssociatedKeys.didShowPermissionsAlertRecently, newValue) }
  }
  private var stickyModeToggled: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.stickyModeToggled) ?? false }
    set {
      setAssociatedObject(self, &AssociatedKeys.stickyModeToggled, newValue)
      setStickyModeStatus(active: newValue)
    }
  }
  private var lastModifierFlags: NSEvent.ModifierFlags {
    get {
      NSEvent.ModifierFlags(
        rawValue: getAssociatedObject(self, &AssociatedKeys.lastModifierFlags) ?? 0)
    }
    set { setAssociatedObject(self, &AssociatedKeys.lastModifierFlags, newValue.rawValue) }
  }
  private var activeActivationShortcut: KeyboardShortcuts.Shortcut? {
    get { getAssociatedObject(self, &AssociatedKeys.activeActivationShortcut) }
    set { setAssociatedObject(self, &AssociatedKeys.activeActivationShortcut, newValue) }
  }
  
  // Track if we're in Karabiner 2.0 sticky mode
  private var isKarabinerStickyMode: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.isKarabinerStickyMode) ?? false }
    set { setAssociatedObject(self, &AssociatedKeys.isKarabinerStickyMode, newValue) }
  }
  private var cpuMonitorTimer: Timer? {
    get { getAssociatedObject(self, &AssociatedKeys.cpuMonitorTimer) }
    set { setAssociatedObject(self, &AssociatedKeys.cpuMonitorTimer, newValue) }
  }
  private var isHighCpuMode: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.isHighCpuMode) ?? false }
    set { setAssociatedObject(self, &AssociatedKeys.isHighCpuMode, newValue) }
  }
  private var lastNavigationTime: CFAbsoluteTime {
    get { getAssociatedObject(self, &AssociatedKeys.lastNavigationTime) ?? 0 }
    set { setAssociatedObject(self, &AssociatedKeys.lastNavigationTime, newValue) }
  }

  // --- Key String Cache for Performance ---
  private struct KeyCacheEntry: Hashable {
    let keyCode: UInt16
    let modifierFlags: UInt  // Use UInt instead of NSEvent.ModifierFlags for simpler hashing
  }

  private var keyStringCache: [KeyCacheEntry: String] {
    get { getAssociatedObject(self, &AssociatedKeys.keyStringCache) ?? [:] }
    set { setAssociatedObject(self, &AssociatedKeys.keyStringCache, newValue) }
  }

  // --- Cached Activation Shortcuts for O(1) lookup ---
  private var cachedActivationKeyCodes: Set<UInt16> {
    get { getAssociatedObject(self, &AssociatedKeys.cachedActivationKeyCodes) ?? [] }
    set { setAssociatedObject(self, &AssociatedKeys.cachedActivationKeyCodes, newValue) }
  }

  private var cachedActivationShortcuts:
    [UInt16: [(KeyboardShortcuts.Shortcut, Controller.ActivationType)]]
  {
    get { getAssociatedObject(self, &AssociatedKeys.cachedActivationShortcuts) ?? [:] }
    set { setAssociatedObject(self, &AssociatedKeys.cachedActivationShortcuts, newValue) }
  }

  // --- Config Preprocessing for Fast Lookups ---
  private var currentKeyLookupCache: KeyLookupCache? {
    get { getAssociatedObject(self, &AssociatedKeys.currentKeyLookupCache) }
    set { setAssociatedObject(self, &AssociatedKeys.currentKeyLookupCache, newValue) }
  }

  private var currentBundleId: String? {
    get { getAssociatedObject(self, &AssociatedKeys.currentBundleId) }
    set { setAssociatedObject(self, &AssociatedKeys.currentBundleId, newValue) }
  }

  // --- Config Reload Tracking ---
  private var isReloading: Bool {
    get { getAssociatedObject(self, &AssociatedKeys.isReloading) ?? false }
    set { setAssociatedObject(self, &AssociatedKeys.isReloading, newValue) }
  }

  private struct AssociatedKeys {
    static var eventTap = "eventTap"
    static var runLoopSource = "runLoopSource"
    static var isMonitoring = "isMonitoring"
    static var activeRootGroup = "activeRootGroup"
    static var currentSequenceGroup = "currentSequenceGroup"
    static var isProcessingKey = "isProcessingKey"
    static var keyEventQueue = "keyEventQueue"
    static var didShowPermissionsAlertRecently = "didShowPermissionsAlertRecently"
    static var stickyModeToggled = "stickyModeToggled"
    static var lastModifierFlags = "lastModifierFlags"
    static var activeActivationShortcut = "activeActivationShortcut"
    static var cpuMonitorTimer = "cpuMonitorTimer"
    static var isHighCpuMode = "isHighCpuMode"
    static var lastNavigationTime = "lastNavigationTime"
    static var keyStringCache = "keyStringCache"
    static var isKarabinerStickyMode = "isKarabinerStickyMode"
    static var cachedActivationKeyCodes = "cachedActivationKeyCodes"
    static var cachedActivationShortcuts = "cachedActivationShortcuts"
    static var cachedActivationModifiers = "cachedActivationModifiers"
    static var callbackOptimizationState = "callbackOptimizationState"
    static var currentKeyLookupCache = "currentKeyLookupCache"
    static var currentBundleId = "currentBundleId"
    static var isReloading = "isReloading"
  }

  // --- Event Tap Logic Methods ---

  func startEventTapMonitoring() {
    guard !isMonitoring else {
      print("[AppDelegate] startEventTapMonitoring: Already monitoring. Aborting.")
      return
    }
    print("[AppDelegate] startEventTapMonitoring: Starting Karabiner input method...")

    currentInputMethod = Karabiner2InputMethod()

    // Pass loadStateMappings as onExportComplete callback to avoid a data race:
    // exportCurrentConfiguration runs on a background thread and mutates config.appConfigs.
    // loadStateMappings calls findActionForMapping which reads config.appConfigs.
    // Running both concurrently crashes (Swift dicts are not thread-safe).
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

  // Performance monitoring methods removed — only needed for CGEventTap

  // --- Optimized Event Processing ---

  // Background queue for async event processing (static to avoid stored property in extension)
  private static let eventProcessingQueue = DispatchQueue(
    label: "com.leaderkey.eventprocessing", qos: .userInteractive)

  // Quick check if we should consume an event (ultra-fast, no NSEvent creation)
  func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
    // Don't consume events during config reload
    if isReloading { return false }

    // Only check keyDown events
    guard event.type == .keyDown else { return false }

    // Get keycode directly from CGEvent
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

    // Single lookup of consolidated state
    let currentState = callbackState

    // Check if it's in our cached activation keys
    var isActivationKey = false
    if cachedActivationKeyCodes.contains(keyCode) {
      // Check modifiers match
      let flags = event.flags
      if let expectedFlags = cachedActivationModifiers[keyCode] {
        // Simple modifier check
        let hasCommand = flags.contains(.maskCommand) == expectedFlags.contains(.maskCommand)
        let hasShift = flags.contains(.maskShift) == expectedFlags.contains(.maskShift)
        let hasOption = flags.contains(.maskAlternate) == expectedFlags.contains(.maskAlternate)
        let hasControl = flags.contains(.maskControl) == expectedFlags.contains(.maskControl)

        if hasCommand && hasShift && hasOption && hasControl {
          isActivationKey = true
          // Mark that we have a pending activation (single state update)
          var newState = currentState
          newState.hasPendingActivation = true
          newState.lastActivationTime = CFAbsoluteTimeGetCurrent()
          callbackState = newState
          return true
        }
      }
    }

    // Check if we're in an active sequence
    if isInActiveSequence {
      // Get modifier flags
      let flags = event.flags

      // Special handling for CMD+, (Settings shortcut) - always consume
      if keyCode == 43 && flags.contains(.maskCommand) {
        return true  // Always consume CMD+, in sequences
      }

      // Check for sticky mode
      let modifiers = cgFlagsToNSModifiers(flags)
      let isStickyMode = isInStickyMode(modifiers)

      // If in sticky mode, use pre-computed keycodes for O(1) lookup
      if isStickyMode {
        // First check if we have pre-computed keycodes
        if let validKeycodes = currentState.stickyModeKeycodes {
          // Direct O(1) keycode check - no string conversion needed!
          return validKeycodes.contains(keyCode)
        }

        // Fallback: compute on-demand if not cached (shouldn't happen normally)
        if let currentGroup = currentSequenceGroup,
          let cache = currentKeyLookupCache
        {
          // Extract key string from the event for lookup
          if let keyString = fastKeyStringForEvent(cgEvent: event, keyCode: keyCode, flags: flags) {
            // O(1) lookup: only consume if this key exists in the current group
            return cache.hasKey(keyString, inGroupId: currentGroup.id)
          }
          // If we can't determine the key string, don't consume (pass through)
          return false
        }
      }

      // Not in sticky mode or no cache - consume all keys in sequence
      return true
    }

    // Consume if we have a pending activation being processed
    if currentState.hasPendingActivation {
      return true
    }

    // Consume if we recently activated (within 100ms window)
    let timeSinceActivation = CFAbsoluteTimeGetCurrent() - currentState.lastActivationTime
    if timeSinceActivation < 0.1 {  // 100ms window
      return true
    }

    return false
  }

  // Check if we're currently in an active sequence
  var isInActiveSequence: Bool {
    return currentSequenceGroup != nil || activeActivationShortcut != nil
  }

  // Convert CGEventFlags to NSEvent.ModifierFlags properly
  private func cgFlagsToNSModifiers(_ cgFlags: CGEventFlags) -> NSEvent.ModifierFlags {
    var modifiers: NSEvent.ModifierFlags = []

    if cgFlags.contains(.maskCommand) { modifiers.insert(.command) }
    if cgFlags.contains(.maskShift) { modifiers.insert(.shift) }
    if cgFlags.contains(.maskControl) { modifiers.insert(.control) }
    if cgFlags.contains(.maskAlternate) { modifiers.insert(.option) }
    if cgFlags.contains(.maskAlphaShift) { modifiers.insert(.capsLock) }
    if cgFlags.contains(.maskSecondaryFn) { modifiers.insert(.function) }

    return modifiers
  }

  // Helper function to identify letter key codes (a-z)
  private func isLetterKeyCode(_ keyCode: UInt16) -> Bool {
    return (keyCode >= 0x00 && keyCode <= 0x11)  // a-q range
      || (keyCode >= 0x1F && keyCode <= 0x2E && keyCode != 0x2B && keyCode != 0x2C
        && keyCode != 0x2D)  // o,p,r-z range (excluding punctuation)
  }

  // Fast key string extraction for O(1) lookups (without NSEvent creation)
  private func fastKeyStringForEvent(cgEvent: CGEvent, keyCode: UInt16, flags: CGEventFlags)
    -> String?
  {
    // Try forced English layout first (covers 95% of keys)
    if Defaults[.forceEnglishKeyboardLayout] {
      let hasShift = flags.contains(.maskShift)

      // Check shifted keymap first for non-letter keys when shift is pressed
      if hasShift, !isLetterKeyCode(keyCode), let shiftedMapping = englishShiftedKeymap[keyCode] {
        return shiftedMapping
      }

      // Then check regular keymap
      if let mapped = englishKeymap[keyCode] {
        // Only uppercase letters when shift is pressed
        if hasShift && isLetterKeyCode(keyCode) {
          return mapped.uppercased()
        }
        return mapped
      }
    }

    // Fallback: For system layout, we need to create NSEvent
    // This is slower but ensures accuracy for non-English layouts
    guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return nil }
    let modifiers = cgFlagsToNSModifiers(flags)

    // Get the character respecting modifiers
    if modifiers.contains(.control) || modifiers.contains(.option) {
      return nsEvent.charactersIgnoringModifiers
    } else {
      return nsEvent.characters
    }
  }

  // Enqueue event for async processing
  func enqueueEventForProcessing(_ event: CGEvent) {
    // Don't process events during reload
    if isReloading { return }

    // Copy the event to prevent it from being released
    guard let eventCopy = event.copy() else { return }

    // Check if this is an activation key
    let keyCode = UInt16(eventCopy.getIntegerValueField(.keyboardEventKeycode))
    let isActivationKey = cachedActivationKeyCodes.contains(keyCode)

    // Process events serially to maintain order
    // The serial queue ensures events are processed one at a time in FIFO order
    AppDelegate.eventProcessingQueue.async { [weak self] in
      guard let self = self else { return }

      // Double-check we're not reloading and still monitoring
      guard !self.isReloading && self.isMonitoring else { return }

      // Create NSEvent with validation
      // Sometimes CGEvent can become invalid, especially during config changes
      guard let nsEvent = NSEvent(cgEvent: eventCopy) else {
        #if DEBUG
          debugLog(
            "[AppDelegate] Warning: Failed to create NSEvent from CGEvent - event may be invalid")
        #endif
        return
      }

      // Use a semaphore to ensure main thread processing completes before next event
      let semaphore = DispatchSemaphore(value: 0)

      DispatchQueue.main.async {
        // Only process if still monitoring and not reloading
        if self.isMonitoring && !self.isReloading {
          _ = self.processKeyEvent(
            cgEvent: eventCopy,
            keyCode: nsEvent.keyCode,
            modifiers: nsEvent.modifierFlags
          )
        }

        // Clear pending activation flag after processing an activation key
        if isActivationKey {
          self.hasPendingActivation = false
        }

        semaphore.signal()
      }

      // Wait for main thread processing to complete before allowing next event
      semaphore.wait()
    }
  }

  // Cache activation key modifiers (CGEventFlags instead of NSEvent.ModifierFlags)
  private var cachedActivationModifiers: [UInt16: CGEventFlags] {
    get { getAssociatedObject(self, &AssociatedKeys.cachedActivationModifiers) ?? [:] }
    set { setAssociatedObject(self, &AssociatedKeys.cachedActivationModifiers, newValue) }
  }

  // Consolidated callback optimization state (single associated object lookup)
  private var callbackState: CallbackOptimizationState {
    get {
      getAssociatedObject(self, &AssociatedKeys.callbackOptimizationState)
        ?? CallbackOptimizationState()
    }
    set { setAssociatedObject(self, &AssociatedKeys.callbackOptimizationState, newValue) }
  }

  // Track if we have a pending activation being processed
  private var hasPendingActivation: Bool {
    get { callbackState.hasPendingActivation }
    set {
      var state = callbackState
      state.hasPendingActivation = newValue
      callbackState = state
    }
  }

  // Track when we last started an activation
  private var lastActivationTime: CFAbsoluteTime {
    get { callbackState.lastActivationTime }
    set {
      var state = callbackState
      state.lastActivationTime = newValue
      callbackState = state
    }
  }

  // --- Force Reset Mechanism ---

  func forceResetState() {
    print("[AppDelegate] forceResetState: Performing nuclear state reset.")

    // Cancel all timers immediately

    // Force clear all state variables immediately (no delays, no callbacks)
    self.currentSequenceGroup = nil
    self.activeRootGroup = nil
    self.stickyModeToggled = false
    self.lastModifierFlags = []
    self.activeActivationShortcut = nil
    self.hasPendingActivation = false

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

  // CPU monitoring removed — only needed for CGEventTap input method

  // This is the entry point called by the C callback `eventTapCallback`
  // NOTE: This is now bypassed for keyDown events which are handled asynchronously
  func handleCGEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    // Update event tap activity tracking

    // Handle different event types
    switch event.type {
    case .keyDown:
      // KeyDown events are now handled asynchronously in the callback
      // This path should not be reached anymore
      return Unmanaged.passRetained(event)
    case .keyUp:
      return handleKeyUpEvent(event)
    case .flagsChanged:
      return handleFlagsChangedEvent(event)
    default:
      return Unmanaged.passRetained(event)
    }
  }

  private func handleKeyDownEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    // Synthetic event check removed - now handled in callback for early exit

    // Prevent concurrent key processing to avoid race conditions
    if isProcessingKey {
      // Buffer the event for later processing instead of passing it through
      guard let nsEvent = NSEvent(cgEvent: event) else {
        #if DEBUG
          debugLog(
            "[AppDelegate] handleKeyDownEvent: Cannot convert CGEvent to NSEvent for buffering. Passing through."
          )
        #endif
        return Unmanaged.passRetained(event)
      }

      // Check queue size limit to prevent memory issues
      if keyEventQueue.count >= maxQueueSize {
        #if DEBUG
          debugLog(
            "[AppDelegate] handleKeyDownEvent: Queue full (size: \(keyEventQueue.count)). Dropping oldest event to make space."
          )
        #endif
        keyEventQueue.removeFirst()
      }

      let queuedEvent = QueuedKeyEvent(
        cgEvent: event, nsEvent: nsEvent, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags
      )
      keyEventQueue.append(queuedEvent)
      #if DEBUG
        debugLog(
          "[AppDelegate] handleKeyDownEvent: Buffered keypress '\(keyStringForEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags) ?? "?")'. Queue size: \(keyEventQueue.count)"
        )
      #endif
      return nil  // Consume the event (don't pass through)
    }

    isProcessingKey = true
    defer {
      isProcessingKey = false
      processQueuedEvents()
    }

    // Try to convert CGEvent to NSEvent to easily access key code and modifiers
    guard let nsEvent = NSEvent(cgEvent: event) else {
      #if DEBUG
        debugLog(
          "[AppDelegate] handleKeyDownEvent: Failed to convert CGEvent to NSEvent. Passing event through."
        )
      #endif
      return Unmanaged.passRetained(event)
    }
    // Process the key event using our main logic function
    #if DEBUG
      // Get the mapped key string here for better logging (only in debug builds)
      let mappedKeyString =
        keyStringForEvent(
          cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags)
        ?? "[?Unmapped?]"
      let modsDescription = describeModifiers(nsEvent.modifierFlags)
      debugLog(
        "[AppDelegate] handleKeyDownEvent: keyCode=\(nsEvent.keyCode) ('\(mappedKeyString)') mods=\(modsDescription) – processing…"
      )
    #endif
    let handled = processKeyEvent(
      cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags)

    // If 'handled' is true, consume the event (return nil). Otherwise, pass it through (return retained event).
    #if DEBUG
      debugLog(
        "[AppDelegate] handleKeyDownEvent: Event handled = \(handled). Returning \(handled ? "nil (consume)" : "event (pass through)")."
      )
    #endif
    return handled ? nil : Unmanaged.passRetained(event)
  }

  private func processQueuedEvents() {
    // Process ALL queued events in a single pass (no recursion)
    while !keyEventQueue.isEmpty && !isProcessingKey {
      let queuedEvent = keyEventQueue.removeFirst()

      #if DEBUG
        debugLog(
          "[AppDelegate] processQueuedEvents: Processing queued keypress '\(keyStringForEvent(cgEvent: queuedEvent.cgEvent, keyCode: queuedEvent.keyCode, modifiers: queuedEvent.modifiers) ?? "?")'. Remaining in queue: \(keyEventQueue.count)"
        )
      #endif

      // Set processing flag to prevent new events from being processed
      isProcessingKey = true

      // Process the queued event using the same logic as handleKeyDownEvent
      let handled = processKeyEvent(
        cgEvent: queuedEvent.cgEvent, keyCode: queuedEvent.keyCode, modifiers: queuedEvent.modifiers
      )

      #if DEBUG
        debugLog("[AppDelegate] processQueuedEvents: Queued event handled = \(handled)")
      #endif

      // Clear flag and continue to next event without recursion
      isProcessingKey = false
    }
  }

  private func clearKeyEventQueue() {
    if !keyEventQueue.isEmpty {
      #if DEBUG
        debugLog("[AppDelegate] clearKeyEventQueue: Clearing \(keyEventQueue.count) queued events")
      #endif
      keyEventQueue.removeAll()
    }
  }

  private func handleKeyUpEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    if currentSequenceGroup != nil {
      guard let nsEvent = NSEvent(cgEvent: event) else {
        return Unmanaged.passRetained(event)
      }

      // Skip opacity changes while an activation shortcut is still in effect to avoid starting
      // the sequence with sticky-mode transparency.
      if self.activeActivationShortcut == nil {
        let isStickyModeActive = isInStickyMode(nsEvent.modifierFlags)
        DispatchQueue.main.async {
          self.controller.window.alphaValue =
            isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
        }
      }
    }

    // Always pass through key up events
    return Unmanaged.passRetained(event)
  }

  private func handleFlagsChangedEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    // Handle modifier key changes (Command, Option, Control, Shift)
    if currentSequenceGroup != nil {
      guard let nsEvent = NSEvent(cgEvent: event) else {
        return Unmanaged.passRetained(event)
      }

      let currentFlags = nsEvent.modifierFlags
      let previousFlags = lastModifierFlags

      // Detect command press/release
      let commandPressed = currentFlags.contains(.command) && !previousFlags.contains(.command)
      let commandReleased = !currentFlags.contains(.command) && previousFlags.contains(.command)

      if commandPressed {
        handleCommandPressed(currentFlags)
      } else if commandReleased {
        handleCommandReleased(currentFlags)
      }

      // Update stored modifier flags
      lastModifierFlags = currentFlags

      // Skip opacity changes while an activation shortcut is still being held to avoid a visible flicker.
      if self.activeActivationShortcut == nil {
        let isStickyModeActive = isInStickyMode(currentFlags)
        DispatchQueue.main.async {
          self.controller.window.alphaValue =
            isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
        }
      }
      let stickyState = isInStickyMode(currentFlags)
      #if DEBUG
        debugLog(
          "[AppDelegate] handleFlagsChangedEvent: cmdPressed=\(commandPressed) cmdReleased=\(commandReleased) sticky=\(stickyState)"
        )
      #endif
    }

    // Always pass through modifier changes
    return Unmanaged.passRetained(event)
  }

  private func processKeyEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags)
    -> Bool
  {
    // OPTIMIZATION: Early exit if keycode is not in our cached activation set
    if !cachedActivationKeyCodes.contains(keyCode) && keyCode != KeyCodes.escape && keyCode != 43 {
      // Not an activation key or escape - check if we're in a sequence
      if currentSequenceGroup != nil {
        // We're in a sequence, so process this key
        #if DEBUG
          debugLog("[AppDelegate] processKeyEvent: Non-activation key in sequence, processing...")
        #endif
        // Clear activation shortcut since user is actively using Leader Key
        if activeActivationShortcut != nil {
          activeActivationShortcut = nil
        }
        return processKeyInSequence(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
      }
      // Not in sequence and not an activation key - pass through immediately
      return false
    }

    // Check cached shortcuts if this keycode matches any activation
    if let shortcuts = cachedActivationShortcuts[keyCode] {
      // Check each shortcut with this keycode
      for (shortcut, activationType) in shortcuts {
        if matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
          // Handle activation
          #if DEBUG
            debugLog("[AppDelegate] processKeyEvent: Matched \(activationType) shortcut.")
          #endif
          handleActivation(type: activationType, activationShortcut: shortcut)
          return true
        }
      }
    }

    // 4. If NOT an activation shortcut, check for Escape
    if keyCode == KeyCodes.escape {
      let isWindowVisible = self.controller.window.isVisible
      let windowAlpha = self.controller.window.alphaValue
      let hasActiveSequence = (currentSequenceGroup != nil || activeRootGroup != nil)

      #if DEBUG
        debugLog(
          "[AppDelegate] Escape pressed. Window isVisible: \(isWindowVisible), alpha: \(windowAlpha), hasActiveSequence: \(hasActiveSequence)"
        )
      #endif

      // Check multiple conditions to determine if we should hide the window
      if isWindowVisible || windowAlpha > 0 || hasActiveSequence {
        // Window is visible OR has opacity OR we have an active sequence - hide it
        #if DEBUG
          debugLog("[AppDelegate] Escape: Hiding window and resetting state.")
        #endif
        hide()
        resetSequenceState()
        return true  // Consume the Escape press
      } else {
        // Window is truly hidden, no active sequence - pass through
        #if DEBUG
          debugLog(
            "[AppDelegate] Escape: Window is hidden, no active sequence. Passing event through.")
        #endif
        return false  // Pass through the Escape press
      }
    }

    // 5. If NOT activation, Escape, or Cmd+, check if we are in a sequence
    if currentSequenceGroup != nil {
      // --- SPECIAL CHECK WITHIN ACTIVE SEQUENCE ---
      // Check for Cmd+, specifically *before* normal sequence processing
      if modifiers.contains(.command),
        let nsEvent = NSEvent(cgEvent: cgEvent),
        nsEvent.charactersIgnoringModifiers == ","
      {
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyEvent: Cmd+, detected while sequence active. Opening settings."
          )
        #endif
        NSApp.sendAction(
          #selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil, from: nil)
        // Reset sequence state and hide the panel
        hide()
        return true  // Consume the Cmd+, press
      }
      // --- END SPECIAL CHECK ---

      // If not Cmd+, process the key normally within the sequence
      #if DEBUG
        debugLog(
          "[AppDelegate] processKeyEvent: Active sequence detected (and not Cmd+). Processing key within sequence..."
        )
      #endif

      // Clear the activation shortcut since the user is now actively using Leader Key
      // This enables the Cmd-release reset feature after activation
      if activeActivationShortcut != nil {
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyEvent: Clearing activeActivationShortcut - user is now actively using Leader Key."
          )
        #endif
        activeActivationShortcut = nil
      }

      return processKeyInSequence(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
    }

    // 5. If NOT activation, Escape, or in a sequence, let the event pass through
    #if DEBUG
      debugLog(
        "[AppDelegate] processKeyEvent: No activation shortcut, Escape, or active sequence matched. Passing event through."
      )
    #endif
    return false
  }

  private func processKeyInSequence(
    cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags
  ) -> Bool {
    #if DEBUG
      debugLog(
        "[AppDelegate] processKeyInSequence: Processing keyCode: \(keyCode), mods: \(describeModifiers(modifiers))"
      )
    #endif

    // Get the single character string representation for the key event
    guard
      let keyString = keyStringForEvent(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
    else {
      // If we can't map the key event to a string, decide based on sticky mode.
      let isStickyModeActive = isInStickyMode(modifiers)
      if isStickyModeActive {
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyInSequence: Could not map event to keyString, but sticky mode ACTIVE – passing event through."
          )
        #endif
        return false  // Event NOT handled – let it propagate
      } else {
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyInSequence: Could not map event to keyString. Shaking window.")
        #endif
        DispatchQueue.main.async { self.controller.window.shake() }
        return true  // Event handled (by shaking)
      }
    }

    #if DEBUG
      debugLog("[AppDelegate] processKeyInSequence: Mapped keyString: '\(keyString)'")
    #endif

    // Check if the keyString matches an action or group within the currently active group
    if let currentGroup = currentSequenceGroup,
      let hit = currentGroup.actions.first(where: { $0.item.key == keyString })
    {
      #if DEBUG
        debugLog(
          "[AppDelegate] processKeyInSequence: Found match for '\(keyString)' in group '\(currentGroup.displayName).'"
        )
      #endif
      switch hit {
      case .action(let action):
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyInSequence: Matched ACTION: '\\(action.displayName)' (\\(action.value))."
          )
        #endif
        // Run the action
        controller.runAction(action)

        // Original Behavior: Check Sticky Mode for ALL action types
        let isStickyModeActive = isInStickyMode(modifiers)
        if !isStickyModeActive {
          #if DEBUG
            debugLog(
              "[AppDelegate] processKeyInSequence: Sticky mode NOT active. Hiding window and resetting sequence."
            )
          #endif
          hide()
        } else {
          #if DEBUG
            debugLog(
              "[AppDelegate] processKeyInSequence: Sticky mode ACTIVE. Keeping window open and preserving sequence state."
            )
          #endif
        }
        return true  // Event handled

      case .group(let subgroup):
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyInSequence: Matched GROUP: '\(subgroup.displayName). Navigating into subgroup."
          )
        #endif

        // Update sequence state immediately to prevent race conditions
        currentSequenceGroup = subgroup

        // Update pre-computed keycodes for the new group
        if let cache = currentKeyLookupCache {
          var state = callbackState
          state.stickyModeKeycodes = cache.getValidKeycodes(forGroupId: subgroup.id)
          callbackState = state
        }

        // Update UI state first to ensure correct display
        DispatchQueue.main.async {
          self.controller.userState.navigateToGroup(subgroup)
        }

        // Check if the group has sticky mode enabled
        if subgroup.stickyMode == true {
          #if DEBUG
            debugLog(
              "[AppDelegate] processKeyInSequence: Group has stickyMode enabled. Activating sticky mode."
            )
          #endif
          activateStickyMode()
        }

        return true  // Event handled
      case .layer(let layer):
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyInSequence: Ignoring normal-mode layer '\(layer.displayName)' in Leader Key overlay."
          )
        #endif
        DispatchQueue.main.async { self.controller.window.shake() }
        return true
      }
    } else {
      // Key not found in the current group.
      let groupName = currentSequenceGroup?.displayName ?? "(nil)"
      #if DEBUG
        debugLog(
          "[AppDelegate] processKeyInSequence: Key '\(keyString)' not found in current group '\(groupName)'."
        )
      #endif

      let isStickyModeActive = isInStickyMode(modifiers)
      if isStickyModeActive {
        // In sticky mode: pass the event through so the underlying app receives the key/shortcut.
        #if DEBUG
          debugLog(
            "[AppDelegate] processKeyInSequence: Sticky mode ACTIVE -> passing event through.")
        #endif
        return false  // Event NOT handled – let it propagate
      } else {
        // Not in sticky mode: indicate error by shaking the window and consuming the event.
        DispatchQueue.main.async { self.controller.window.shake() }
        return true  // Event handled (by shaking)
      }
    }
  }

  // This function is called when an activation shortcut is pressed or a socket/user command arrives.
  // It sets up the initial state for a new key sequence based on the loaded config.
  private func startSequence(activationType: Controller.ActivationType, bundleId: String? = nil) {
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
    self.currentKeyLookupCache = keyLookupCache
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

      // Clear any queued key events when sequence ends
      clearKeyEventQueue()

      // Clear pending activation flag and pre-computed keycodes when sequence resets
      self.hasPendingActivation = false
      var state = callbackState
      state.stickyModeKeycodes = nil
      callbackState = state

      // Reset sticky mode toggle state
      if stickyModeToggled {
        debugLog("[AppDelegate] resetSequenceState: Resetting sticky mode toggle state.")
        self.stickyModeToggled = false
      }

      // Reset modifier flags tracking
      self.lastModifierFlags = []

      // Clear activation shortcut tracking
      self.activeActivationShortcut = nil

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

  // Converts a key event into a single character string suitable for matching against config keys.
  // Handles forced English layout if enabled. Now with caching for performance.
  private func keyStringForEvent(
    cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags
  ) -> String? {
    // Create cache key - use relevant modifiers only
    let relevantModifiers = modifiers.intersection([.shift, .control, .option, .command])
    let cacheKey = KeyCacheEntry(keyCode: keyCode, modifierFlags: relevantModifiers.rawValue)

    // Check cache first
    if let cached = keyStringCache[cacheKey] {
      return cached.isEmpty ? nil : cached
    }

    // Cache miss - calculate the key string
    var result: String?

    // --- Option 1: Forced English Layout ---
    if Defaults[.forceEnglishKeyboardLayout] {
      // Check shifted keymap first for non-letter keys when shift is pressed
      if modifiers.contains(.shift), !isLetterKeyCode(keyCode),
        let shiftedMapping = englishShiftedKeymap[keyCode]
      {
        result = shiftedMapping
      } else if let mapped = englishKeymap[keyCode] {
        // Only uppercase letters when shift is pressed
        if modifiers.contains(.shift) && isLetterKeyCode(keyCode) {
          result = mapped.uppercased()
        } else {
          result = mapped
        }
      }
      #if DEBUG
        if result != nil {
          print(
            "[AppDelegate] keyStringForEvent (Forced English): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result!)' (Case Sensitive)"
          )
        }
      #endif
    } else {
      // --- Option 2: System Layout (Case Sensitive, Ignore Ctrl/Opt Effect) ---

      // Handle specific non-character keys FIRST by keycode
      switch keyCode {
      case 36: result = "\u{21B5}"  // Enter
      case 48: result = "\t"  // Tab
      case 49: result = " "  // Space
      case 51: result = "\u{0008}"  // Backspace
      case KeyCodes.escape: result = "\u{001B}"  // Escape
      case 126: result = "↑"  // Up Arrow
      case 125: result = "↓"  // Down Arrow
      case 123: result = "←"  // Left Arrow
      case 124: result = "→"  // Right Arrow
      default:
        // For remaining keys, determine character based on modifiers
        let nsEvent = NSEvent(cgEvent: cgEvent)

        // If Control or Option are involved, get the base character *ignoring* those modifiers,
        // BUT respecting Shift for case sensitivity lookup.
        if modifiers.contains(.control) || modifiers.contains(.option) {
          // Get characters ignoring Ctrl/Opt, which might still include Shift effect
          result = nsEvent?.charactersIgnoringModifiers
          #if DEBUG
            print(
              "[AppDelegate] keyStringForEvent (System Layout - Ctrl/Opt): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Ignoring Ctrl/Opt effect)"
            )
          #endif
        } else {
          // No Ctrl/Opt involved. Get the character directly, which includes Shift effect.
          result = nsEvent?.characters
          #if DEBUG
            print(
              "[AppDelegate] keyStringForEvent (System Layout - Shift/Base): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Respecting Shift)"
            )
          #endif
        }
      }
    }

    // Store in cache (including empty strings to avoid recalculation)
    if let result = result {
      keyStringCache[cacheKey] = result
      // Limit cache size to prevent unbounded growth
      if keyStringCache.count > 500 {
        // Clear cache when it gets too large
        #if DEBUG
          print("[AppDelegate] keyStringForEvent: Cache size exceeded 500, clearing cache")
        #endif
        keyStringCache.removeAll(keepingCapacity: true)
      }
    }

    // Final check: return nil if the resulting string is empty.
    if result?.isEmpty ?? true {
      #if DEBUG
        print("[AppDelegate] keyStringForEvent: Result is empty or nil, returning nil.")
      #endif
      return nil
    } else {
      return result
    }
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

  // Add the missing helper function back
  private func matchesShortcut(
    keyCode: UInt16, modifiers: NSEvent.ModifierFlags, shortcut: KeyboardShortcuts.Shortcut
  ) -> Bool {
    // Compare the key code
    guard keyCode == shortcut.carbonKeyCode else { return false }

    // Compare the modifiers - ensuring ONLY the required modifiers are present
    // (NSEvent.ModifierFlags includes flags for key state like Caps Lock, which we usually want to ignore)
    let requiredModifiers = shortcut.modifiers
    let relevantFlags: NSEvent.ModifierFlags = [.shift, .control, .option, .command]
    let incomingRelevantModifiers = modifiers.intersection(relevantFlags)

    return incomingRelevantModifiers == requiredModifiers
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
          self.lastModifierFlags = []

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
  
  func inputMethodDidReceiveStateId(_ stateId: Int32, sticky: Bool = false) {
    // Handle state ID from Karabiner 2.0
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.ensureControllerReady()
      
      debugLog("[InputMethod] State ID received: \(stateId), sticky: \(sticky)")
      
      // Look up the action by state ID and execute it
      self.executeActionByStateId(stateId, sticky: sticky)
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
    currentKeyLookupCache = keyLookupCache
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

  private func resolvedActivationContext(for mapping: Karabiner2Exporter.StateMapping) -> KarabinerActivationContext {
    switch mapping.scope {
    case .global:
      return KarabinerActivationContext(mode: .defaultOnly, bundleId: nil, activatedAt: Date())

    case .fallbackOnly:
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: Date())

    case .appShared:
      if let activationContext = karabinerActivationContext {
        switch activationContext.mode {
        case .defaultOnly:
          return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: activationContext.activatedAt)
        case .appSpecificWithFallback, .fallbackOnly:
          return activationContext
        }
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: Date())

    case .appOverride, .appSuppress:
      if let activationContext = karabinerActivationContext,
         activationContext.mode == .appSpecificWithFallback {
        return activationContext
      }
      if let bundleId = mapping.bundleId {
        return KarabinerActivationContext(mode: .appSpecificWithFallback, bundleId: bundleId, activatedAt: Date())
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: Date())

    case .normalShared:
      if let bundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier {
        return KarabinerActivationContext(mode: .appSpecificWithFallback, bundleId: bundleId, activatedAt: Date())
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: Date())

    case .normalOverride, .normalSuppress:
      if let bundleId = mapping.bundleId {
        return KarabinerActivationContext(mode: .appSpecificWithFallback, bundleId: bundleId, activatedAt: Date())
      }
      return KarabinerActivationContext(mode: .fallbackOnly, bundleId: nil, activatedAt: Date())
    }
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
  
  private func executeActionByStateId(_ stateId: Int32, sticky: Bool = false) {
    // Load mappings if they haven't been loaded yet
    if stateMappingsLastLoaded == nil {
      loadStateMappings()
    }

    guard let mapping = stateMappings[stateId] else {
      debugLog("[AppDelegate] No mapping found for state ID: \(stateId)")
      return
    }

    let activationContext = resolvedActivationContext(for: mapping)
    let isNormalModeDispatch = isNormalModeScope(mapping.scope)
    let activationType = activationType(for: activationContext.mode)
    let activationBundleId = bundleIdForShow(context: activationContext)

    debugLog(
      "[AppDelegate] Found mapping for state ID \(stateId): scope=\(mapping.scope.rawValue), " +
        "type=\(mapping.actionType), label=\(mapping.actionLabel ?? "unknown"), " +
        "bundleId=\(mapping.bundleId ?? "nil"), activeBundle=\(activationBundleId ?? "nil")")

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

// NOTE: Associated object helpers are now defined globally above AppDelegate.
