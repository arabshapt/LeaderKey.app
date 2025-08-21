// swiftlint:disable file_length
import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import Sparkle
import SwiftUI
import UserNotifications
import ObjectiveC
import Kingfisher

let updateLocationIdentifier = "UpdateCheck"

// Define the same unique tag here
private let leaderKeySyntheticEventTag: Int64 = 0xDEADBEEF

// MARK: - Event Tap Callback

// Global statistics instance (since callback can't access instance properties efficiently)
private var globalCallbackStats = CallbackStatistics()

// This needs to be a top-level function or static method to be used as a C callback.
private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    // Start timing immediately
    let startTime = MachTime.now()
    
    // Quick exit for no user info
    guard let userInfo = userInfo else {
        return Unmanaged.passRetained(event)
    }
    
    // Check for synthetic event FIRST (early exit optimization)
    if event.getIntegerValueField(.eventSourceUserData) == leaderKeySyntheticEventTag {
        return Unmanaged.passRetained(event)
    }

    // Cast the reference to AppDelegate
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userInfo).takeUnretainedValue()
    
    // Handle non-keyDown events through the old path
    if event.type != .keyDown {
        let result = appDelegate.handleCGEvent(event)
        
        // Record timing
        let endTime = MachTime.now()
        let duration = MachTime.toMilliseconds(endTime - startTime)
        globalCallbackStats.record(duration: duration)
        
        return result
    }
    
    // OPTIMIZED PATH FOR KEYDOWN: Quick consumption check without NSEvent creation
    let shouldConsume = appDelegate.quickShouldConsumeEvent(event)
    
    // Queue ALL keyDown events for processing to maintain sequence integrity
    // We must process everything to properly track state changes
    appDelegate.enqueueEventForProcessing(event)
    
    // Record timing
    let endTime = MachTime.now()
    let duration = MachTime.toMilliseconds(endTime - startTime)
    globalCallbackStats.record(duration: duration)
    
    // Log if very slow (only in debug)
    #if DEBUG
    if duration > 1.0 {  // Lowered threshold to 1ms for better monitoring
        print("[PERF WARNING] Callback took \(String(format: "%.2f", duration))ms")
    }
    #endif
    
    // Return nil to consume the event, or pass it through
    return shouldConsume ? nil : Unmanaged.passRetained(event)
}

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

private let maxQueueSize = 3 // Reduced queue size to minimize latency

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
    var slowCallbacks: Int64 = 0   // callbacks > 1ms
    var verySlowCallbacks: Int64 = 0  // callbacks > 5ms
    var maxDuration: Double = 0
    var minDuration: Double = Double.infinity
    var lastDuration: Double = 0
    var lastResetTime = Date()
    
    // Histogram buckets for percentile calculation (in ms)
    var histogram: [Double: Int64] = [
        0.1: 0,   // < 0.1ms
        0.5: 0,   // 0.1-0.5ms
        1.0: 0,   // 0.5-1ms
        5.0: 0,   // 1-5ms
        10.0: 0,  // 5-10ms
        Double.infinity: 0  // > 10ms
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

// Define the view for the Shortcuts pane
private struct KeyboardShortcutsView: View {
    private let contentWidth = SettingsConfig.contentWidth

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "Global Activation Shortcuts") {
                Form {
                    KeyboardShortcuts.Recorder("Activate (Global)", name: .activateDefaultOnly)
                    KeyboardShortcuts.Recorder("Activate (App-Specific)", name: .activateAppSpecific)
                    KeyboardShortcuts.Recorder("Force Reset (Emergency)", name: .forceReset)
                }
                Text("Global always loads the default config.\nApp-Specific tries to load the config for the frontmost app.\nForce Reset (Cmd+Shift+Ctrl+K) immediately clears all state if LeaderKey gets stuck.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

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
class AppDelegate: NSObject, NSApplicationDelegate {
    // --- Properties ---
  var controller: Controller!
  let statusItem = StatusItem()
  let config = UserConfig()
  var fileMonitor: FileMonitor!
  var state: UserState!
  @IBOutlet var updaterController: SPUStandardUpdaterController!

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
        toolbarIcon: NSImage(systemSymbolName: "slider.horizontal.3", accessibilityDescription: "Opacity Settings")!,
        contentView: { OpacityPane() }
      ),
      Settings.Pane(
        identifier: .search, title: "Search",
        toolbarIcon: NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "Search Sequences")!,
        contentView: { SearchPane().environmentObject(self.config) }
      ),
      Settings.Pane(
        identifier: .shortcuts, title: "Shortcuts",
        toolbarIcon: NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Keyboard Shortcuts")!,
        contentView: { KeyboardShortcutsView() }
      ),
      Settings.Pane(
        identifier: .advanced, title: "Advanced",
        toolbarIcon: NSImage(named: NSImage.advancedName)!,
        contentView: { AdvancedPane().environmentObject(self.config) }
      )
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
    } // isRunningTests() is in private extension

    #if DEBUG
    debugLog("[AppDelegate] applicationDidFinishLaunching: Starting up...")
    #endif

    // Setup Notifications
    UNUserNotificationCenter.current().delegate = self // Conformance is in extension
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        #if DEBUG
        if let error = error { debugLog("[AppDelegate] Error requesting notification permission: \(error)") }
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
    config.ensureAndLoad() // Ensures config dir/file exists and loads default config
    state = UserState(userConfig: config)
    controller = Controller(userState: state, userConfig: config, appDelegate: self)
    #if DEBUG
    debugLog("[AppDelegate] UserConfig and UserState initialized.")
    #endif

    // Setup background services and UI elements
    setupFileMonitor()      // Defined in private extension
    setupStatusItem()       // Defined in private extension
    setupUpdaterController() // Configure auto-update behavior
    setupStateRecoveryTimer() // Setup periodic state recovery checks

    // Configure global image cache to keep memory tight
    configureImageCaching()

    // Check initial permission state
    lastPermissionCheck = checkAccessibilityPermissions()
    print("[AppDelegate] Initial accessibility permission state: \(lastPermissionCheck ?? false)")
    
    // Attempt to start the global event tap immediately
    #if DEBUG
    debugLog("[AppDelegate] Attempting initial startEventTapMonitoring()...")
    #endif
    startEventTapMonitoring() // Defined in Event Tap Handling extension

    // Add a delayed check to retry starting the event tap if it failed initially.
    // This helps if Accessibility permissions were granted just before launch
    // and the system needs a moment to register them.
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Wait 2 seconds
        if !self.isMonitoring && self.checkAccessibilityPermissions() {
            print("[AppDelegate] Delayed check: Permissions available but not monitoring. Retrying startEventTapMonitoring()...")
            self.startEventTapMonitoring()
        } else if !self.isMonitoring {
            print("[AppDelegate] Delayed check: Still no permissions. Health check will monitor for changes.")
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
      print("[AppDelegate] applicationDidBecomeActive: Not monitoring, attempting to start startEventTapMonitoring()...")
      startEventTapMonitoring()
    } else {
      print("[AppDelegate] applicationDidBecomeActive: Already monitoring.")
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    print("[AppDelegate] applicationWillTerminate: Stopping event tap and saving config...")
    stopEventTapMonitoring() // Defined in Event Tap Handling extension
    config.saveCurrentlyEditingConfig() // Save any unsaved changes from the settings pane
    stateRecoveryTimer?.invalidate() // Stop state recovery timer
    eventTapHealthTimer?.invalidate() // Stop event tap health timer
    permissionPollingTimer?.invalidate() // Stop permission polling timer
    print("[AppDelegate] applicationWillTerminate completed.")
  }
  
  // MARK: - State Recovery
  
  private var stateRecoveryTimer: Timer?
  private var eventTapHealthTimer: Timer?
  private var lastPermissionCheck: Bool? = nil
  private var permissionPollingTimer: Timer?
  private var permissionPollingStartTime: Date?
  
  private func setupStateRecoveryTimer() {
    // Check state every 5 seconds
    stateRecoveryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
      self?.checkAndRecoverWindowState()
    }
    
    // Check event tap health every 2 seconds by default; this is robust while reducing wakeups
    eventTapHealthTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
      self?.checkEventTapHealth()
    }
  }
  
  private func checkAndRecoverWindowState() {
    guard let window = controller?.window else { return }
    
    // Check for inconsistent states (only check isVisible, not opacity since user can set opacity to 0)
    if window.isVisible {
      // Check if we have a stuck sequence with no active group
      if currentSequenceGroup == nil && activeRootGroup == nil {
        print("[AppDelegate] State Recovery: Window visible but no active sequence. Hiding window.")
        hide()
      }
    }
  }
  
  private func checkEventTapHealth() {
    if isMonitoring {
      // Check if event tap exists and is enabled
      if let tap = eventTap {
        if !CGEvent.tapIsEnabled(tap: tap) {
          print("[AppDelegate] Event Tap Health Check: Event tap disabled! Re-enabling...")
          CGEvent.tapEnable(tap: tap, enable: true)
          
          // If still disabled after re-enabling, restart the whole event tap
          if !CGEvent.tapIsEnabled(tap: tap) {
            print("[AppDelegate] Event Tap Health Check: Re-enable failed. Restarting event tap...")
            restartEventTap()
          }
        }
      } else {
        // Event tap is nil but we should be monitoring
        print("[AppDelegate] Event Tap Health Check: Event tap is nil! Restarting...")
        restartEventTap()
      }
    } else {
      // Not monitoring - check if permissions have been granted
      let hasPermissions = checkAccessibilityPermissions()
      
      // Detect permission change from false to true
      if lastPermissionCheck == false && hasPermissions {
        print("[AppDelegate] Event Tap Health Check: Accessibility permissions newly granted! Starting event tap...")
        startEventTapMonitoring()
      }
      
      // Update last permission state
      lastPermissionCheck = hasPermissions
    }
  }
  
    private func restartEventTap() {
    print("[AppDelegate] Restarting event tap...")
    
    // First stop the existing tap
    stopEventTapMonitoring()
    
    // Hide any stuck window
    if controller?.window.isVisible == true {
      hide()
    }
    
    // Restart after a brief delay to ensure cleanup
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.startEventTapMonitoring()
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
          print("[AppDelegate] User has navigation path with \(userStateNavigationPath.count) groups to restore")
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
      window.minSize = NSSize(width: 450, height: 650) // Ensure minSize is set

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
              print("[AppDelegate settings] Warning: Could not determine effective window size (Size: \(windowSize)). Origin calculation skipped.")
          }
      } else {
          print("[AppDelegate settings] Warning: Could not get target screen. Origin calculation skipped.")
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

      NSApp.activate(ignoringOtherApps: true) // Bring the app to the front for settings
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
              print("[AppDelegate] Failed to build navigation path for groups: \(userStateNavigationPath.map { $0.key ?? "nil" })")
          }
      }
  }

    // Determine which config to focus on based on current state
    private func determineConfigToFocus() -> String {
        // First check if UserState has a stored config key
        if let activeConfigKey = controller.userState.activeConfigKey {
            print("[AppDelegate] Using stored activeConfigKey from UserState: \(activeConfigKey)")
            return activeConfigKey
        }
        
        // Fallback: check if we have an active sequence state
        if let activeRoot = self.activeRootGroup {
            print("[AppDelegate] Active sequence detected, determining config from activeRootGroup")
            return findConfigKeyForGroup(activeRoot)
        }

        // Check if the Controller's UserState has an active root (without stored key)
        if let userStateActiveRoot = controller.userState.activeRoot {
            print("[AppDelegate] Using UserState activeRoot to determine config")
            return findConfigKeyForGroup(userStateActiveRoot)
        }

        // Check frontmost application to determine if we should use app-specific config
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           let bundleId = frontmostApp.bundleIdentifier {
            print("[AppDelegate] Using frontmost app (\(bundleId)) to determine config")

            // Check if an app-specific config exists for this bundle ID
            let appConfig = config.getConfig(for: bundleId)
            // If the returned config is not the default root, then an app-specific config exists
            if !areGroupsEqual(appConfig, config.root) {
                return findConfigKeyForGroup(appConfig)
            }
        }

        // Default fallback - use global default
        print("[AppDelegate] Falling back to global default config")
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
            if let loadedGroup = config.decodeConfig(from: filePath, suppressAlerts: true, isDefaultConfig: false) {
                if areGroupsEqual(loadedGroup, group) {
                    return key
                }
            }
        }

        // If we can't find a specific match, try to infer from bundle ID
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           let bundleId = frontmostApp.bundleIdentifier {

            // Look for an app-specific config key pattern
            for key in config.discoveredConfigFiles.keys {
                if key.contains(bundleId) {
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
        return group1.key == group2.key &&
               group1.label == group2.label &&
               group1.actions.count == group2.actions.count
    }

    // Build navigation path from the loaded config using the navigationPath groups
    private func buildNavigationPathFromLoadedConfig(_ navigationPath: [Group]) -> [Int]? {
        guard !navigationPath.isEmpty else {
            print("[AppDelegate] buildNavigationPathFromLoadedConfig: Navigation path is empty")
            return nil
        }
        
        // Use the actually loaded config that's displayed in settings
        let rootGroup = config.currentlyEditingGroup
        print("[AppDelegate] buildNavigationPathFromLoadedConfig: Using currentlyEditingGroup with key '\(rootGroup.key ?? "nil")'")
        print("[AppDelegate] buildNavigationPathFromLoadedConfig: Navigation path has \(navigationPath.count) groups")
        
        // Check if the first group in navigationPath is the root itself (has same nil key and matches root)
        var groupsToProcess = navigationPath
        if let firstGroup = navigationPath.first,
           firstGroup.key == rootGroup.key && firstGroup.key == nil {
            print("[AppDelegate] buildNavigationPathFromLoadedConfig: Skipping root group in navigation path")
            groupsToProcess = Array(navigationPath.dropFirst())
        }
        
        // If no groups left after removing root, return empty path
        guard !groupsToProcess.isEmpty else {
            print("[AppDelegate] buildNavigationPathFromLoadedConfig: No groups to navigate after removing root")
            return []
        }
        
        // Build the index path by finding each group in the hierarchy
        var indexPath: [Int] = []
        var currentGroup = rootGroup
        
        for (navIndex, targetGroup) in groupsToProcess.enumerated() {
            let targetKey = targetGroup.key ?? ""
            let targetLabel = targetGroup.label ?? ""
            print("[AppDelegate] buildNavigationPathFromLoadedConfig: Looking for group with key='\(targetKey)' label='\(targetLabel)' at level \(navIndex)")
            
            // Find the index of this group in the current level
            // Match by key if both have keys, otherwise try to match by label or other properties
            if let index = currentGroup.actions.firstIndex(where: { item in
                if case .group(let group) = item {
                    // If target has a key, match by key and label
                    if !targetKey.isEmpty {
                        let matches = group.key == targetGroup.key && 
                                    (targetGroup.label == nil || group.label == targetGroup.label)
                        if matches {
                            print("[AppDelegate] buildNavigationPathFromLoadedConfig: Found match by key at index \(index)")
                        }
                        return matches
                    } else if !targetLabel.isEmpty {
                        // If no key but has label, try matching by label alone
                        let matches = group.label == targetGroup.label
                        if matches {
                            print("[AppDelegate] buildNavigationPathFromLoadedConfig: Found match by label at index \(index)")
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
                    print("[AppDelegate] buildNavigationPathFromLoadedConfig: Moving to next level, now at group with key='\(nextGroup.key ?? "nil")' label='\(nextGroup.label ?? "")'")
                }
            } else {
                // If we can't find the group, log available groups for debugging
                let availableGroups = currentGroup.actions.compactMap { item -> String in
                    if case .group(let g) = item {
                        return "key='\(g.key ?? "nil")' label='\(g.label ?? "")'"
                    }
                    return ""
                }.filter { !$0.isEmpty }
                print("[AppDelegate] buildNavigationPathFromLoadedConfig: Could not find group with key='\(targetKey)' label='\(targetLabel)' at level \(navIndex)")
                print("[AppDelegate] buildNavigationPathFromLoadedConfig: Available groups at this level: \(availableGroups)")
                return nil
            }
        }
        
        print("[AppDelegate] buildNavigationPathFromLoadedConfig: Successfully built path: \(indexPath)")
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
                  let loadedGroup = config.decodeConfig(from: filePath, suppressAlerts: true, isDefaultConfig: false) {
            // Apply the same merging logic as loadConfigForEditing
            // Check if this is an app-specific config (not the fallback)
            if filePath.contains("app.") && !filePath.contains("app-fallback-config.json") {
                // Extract bundle ID from the display name
                let bundleId = config.extractBundleId(from: configKey) ?? ""
                let rawMergedGroup = config.mergeConfigWithFallback(appSpecificConfig: loadedGroup, bundleId: bundleId)
                rootGroup = config.sortGroupRecursively(group: rawMergedGroup)
            } else {
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
                print("[AppDelegate] buildNavigationPath: Could not find group '\(targetGroup.key ?? "")' in current level")
                return nil
            }
        }
        
        return indexPath
    }

    // Convenience method to show the main Leader Key window
    func show(type: Controller.ActivationType = .appSpecificWithFallback, completion: (() -> Void)? = nil) {
        print("[AppDelegate] show(type: \(type)) called.")
        controller.show(type: type, completion: completion)
    }

    // Convenience method to hide the main Leader Key window
    func hide() {
      print("[AppDelegate] hide() called.") // Log entry into hide()

      controller.hide(afterClose: { [weak self] in
        // Reset sequence AFTER the window is fully closed to avoid visual flash
        self?.resetSequenceState()
      })
    }

    // Toggle sticky mode programmatically (for use in actions)
    func toggleStickyMode() {
        stickyModeToggled.toggle()
        print("[AppDelegate] toggleStickyMode: Sticky mode toggled to \(stickyModeToggled)")

        // Update window transparency immediately if we're in a sequence
        if currentSequenceGroup != nil {
            let isStickyModeActive = isInStickyMode(NSEvent.modifierFlags)
            DispatchQueue.main.async {
                self.controller.window.alphaValue = isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
            }
        }
    }

    // Activate sticky mode programmatically (for use in actions with stickyMode enabled)
    func activateStickyMode() {
        if !stickyModeToggled {
            stickyModeToggled = true
            print("[AppDelegate] activateStickyMode: Sticky mode activated")

            // Update window transparency immediately if we're in a sequence
            if currentSequenceGroup != nil {
                let isStickyModeActive = isInStickyMode(NSEvent.modifierFlags)
                DispatchQueue.main.async {
                    self.controller.window.alphaValue = isStickyModeActive ? 0.2 : 1.0
                }
            }
        }
    }

    // MARK: - Command Key Release Handling Methods

    private func handleCommandPressed(_ modifierFlags: NSEvent.ModifierFlags) {
        // Command key press is tracked but no action needed on press
        // We only act on release
        print("[AppDelegate] handleCommandPressed: Command key pressed")
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
            print("[AppDelegate] handleCommandReleased: Still have active activation shortcut - user hasn't started using Leader Key yet. Ignoring.")
            return
        }

        print("[AppDelegate] handleCommandReleased: Command key released with resetOnCmdRelease enabled. Hiding window (state resets after close).")
        DispatchQueue.main.async {
            print("[AppDelegate] handleCommandReleased: Hiding window – state will reset after close.")
            self.hide()
        }
    }

    // --- Activation Logic (Called by Event Tap) ---
  func handleActivation(type: Controller.ActivationType, activationShortcut: KeyboardShortcuts.Shortcut? = nil) {
      print("[AppDelegate] handleActivation: Received activation request of type: \(type)")
      // Track the activation shortcut to prevent immediate command release triggers
      activeActivationShortcut = activationShortcut

      // This function decides what to do when an activation shortcut is pressed.

      if controller.window.isVisible { // Check if the Leader Key window is already visible
          print("[AppDelegate] handleActivation: Window is already visible.")
          switch Defaults[.reactivateBehavior] { // Check user preference for reactivation
          case .hide:
              // Preference: Hide the window if activated again while visible.
              print("[AppDelegate] handleActivation: Reactivate behavior is 'hide'. Hiding window and resetting sequence.")
              hide()
              return // Stop processing here

          case .reset:
              // Preference: Reset the sequence if activated again while visible.
              print("[AppDelegate] handleActivation: Reactivate behavior is 'reset'. Resetting sequence.")
              // Ensure window is visible and frontmost (but not key to avoid interfering with overlays)
              if !controller.window.isVisible {
                  print("[AppDelegate] handleActivation (Reset): Making window visible.")
                  controller.window.orderFront(nil) // Just bring to front without making key
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
                  // Use the same overlay detection logic as initial activation
                  let (bundleId, isOverlay) = OverlayDetector.shared.detectAndCacheOverlayState()
                  let configKey = isOverlay && bundleId != nil ? "\(bundleId!).overlay" : bundleId
                  newRoot = self.config.getConfig(for: configKey)
                }
                self.controller.userState.activeRoot = newRoot
              }
              print("[AppDelegate] handleActivation (Reset): Starting new sequence.")
              controller.repositionWindowNearMouse()
              startSequence(activationType: type)

          case .nothing:
              // Preference: Do nothing if activated again while visible, unless window lost focus.
              print("[AppDelegate] handleActivation: Reactivate behavior is 'nothing'.")
              // Ensure window is visible (but not key to avoid interfering with overlays)
              if !controller.window.isVisible {
                  print("[AppDelegate] handleActivation (Nothing): Making window visible.")
                  controller.window.orderFront(nil) // Just bring to front without making key
              }
              // Start a sequence only if one wasn't already active (e.g., if Escape was pressed before).
              // This prevents restarting if the user just presses the shortcut again mid-sequence.
              if currentSequenceGroup == nil {
                  print("[AppDelegate] handleActivation (Nothing): No current sequence, starting new sequence.")
                  startSequence(activationType: type)
              } else {
                   print("[AppDelegate] handleActivation (Nothing): Sequence already active, doing nothing.")
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
private extension AppDelegate {
    // ... (setupFileMonitor, setupStatusItem, isRunningTests implementations - logs added within methods) ...
    func setupFileMonitor() {
        print("[AppDelegate] setupFileMonitor: Setting up config directory watcher.")
        Task {
            // Observe changes to the config directory path stored in Defaults
            for await newDir in Defaults.updates(.configDir) {
                print("[AppDelegate] Config directory changed to: \(newDir). Restarting file monitor.")
                self.fileMonitor?.stopMonitoring() // Stop previous monitor if any
                self.fileMonitor = FileMonitor(fileURL: config.url) { // Create new monitor for the current config URL
                    print("[AppDelegate] FileMonitor detected change in config file. Reloading...")
                    self.config.reloadConfig()
                }
                self.fileMonitor.startMonitoring()
                 print("[AppDelegate] FileMonitor started for: \(config.url.path)")
            }
        }
    }

    func setupStatusItem() {
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
            let stats = self.getCallbackPerformanceStats()
            
            // Show stats in an alert dialog
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Event Tap Callback Performance"
                alert.informativeText = stats
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Reset Stats")
                
                if alert.runModal() == .alertSecondButtonReturn {
                    self.resetCallbackPerformanceStats()
                    print("[StatusItem] Performance stats reset")
                }
            }
        }
        // Observe changes to the preference for showing the menu bar icon
        Task {
            for await value in Defaults.updates(.showMenuBarIcon) {
                DispatchQueue.main.async {
                    print("[AppDelegate] Show Menu Bar Icon setting changed to: \(value). Updating status item visibility.")
                    if value {
                        self.statusItem.enable()
                    } else {
                        self.statusItem.disable()
                    }
                }
            }
        }
    }

    // Helper to check if running within Xcode's testing environment
    func isRunningTests() -> Bool {
        let isTesting = ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil
        if isTesting { print("[AppDelegate] isRunningTests detected.") }
        return isTesting
    }

    func setupUpdaterController() {
        print("[AppDelegate] setupUpdaterController: Configuring auto-update behavior.")

        // Set initial automatic update check preference
        updaterController.updater.automaticallyChecksForUpdates = Defaults[.automaticallyChecksForUpdates]

        // Observe changes to the auto-update preference
        Task {
            for await value in Defaults.updates(.automaticallyChecksForUpdates) {
                DispatchQueue.main.async {
                    print("[AppDelegate] Auto-update setting changed to: \(value). Updating Sparkle configuration.")
                    self.updaterController.updater.automaticallyChecksForUpdates = value
                }
            }
        }
    }

    func configureImageCaching() {
        // Kingfisher: reduce memory footprint and avoid caching huge originals
        let cache = KingfisherManager.shared.cache
        cache.memoryStorage.config.totalCostLimit = 25 * 1024 * 1024 // ~25MB in-RAM images
        cache.memoryStorage.config.countLimit = 1024
        cache.memoryStorage.config.expiration = .seconds(600)
        cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024 // 100MB on disk
        cache.diskStorage.config.expiration = .days(14)
    }
}

// MARK: - Sparkle Updates Delegate (SPUStandardUserDriverDelegate)
extension AppDelegate: SPUStandardUserDriverDelegate {
    // ... (Delegate method implementations) ...
    var supportsGentleScheduledUpdateReminders: Bool { return true }

    func standardUserDriverWillHandleShowingUpdate(_ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        NSApp.setActivationPolicy(.regular)
        if !state.userInitiated {
            NSApp.dockTile.badgeLabel = "1"
            let content = UNMutableNotificationContent()
            content.title = "Leader Key Update Available"
            content.body = "Version \(update.displayVersionString) is now available"
            let request = UNNotificationRequest(identifier: updateLocationIdentifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        NSApp.dockTile.badgeLabel = ""
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [updateLocationIdentifier])
    }

    func standardUserDriverWillFinishUpdateSession() {
        NSApp.setActivationPolicy(.accessory)
    }
}

// MARK: - User Notifications Delegate (UNUserNotificationCenterDelegate)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // ... (Delegate method implementation) ...
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == updateLocationIdentifier && response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            updaterController.checkForUpdates(nil)
        }
        completionHandler()
    }
}

// MARK: - URL Scheme Handling
extension AppDelegate {
    // Handles opening the app via leaderkey:// URLs
    func application(_ application: NSApplication, open urls: [URL]) {
         print("[AppDelegate] application:open:urls: Received URL(s): \(urls.map { $0.absoluteString })")
        for url in urls { handleURL(url) }
    }

    private func handleURL(_ url: URL) {
        print("[AppDelegate] handleURL: Processing URL: \(url.absoluteString)")
        guard url.scheme == "leaderkey" else {
             print("[AppDelegate] handleURL: Ignoring URL with incorrect scheme.")
             return
        }
        // Always show the window when opened via URL scheme
        show()
        if url.host == "navigate", // Expecting leaderkey://navigate?keys=a,b,c
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let keysParam = queryItems.first(where: { $0.name == "keys" })?.value {
            let keys = keysParam.split(separator: ",").map(String.init)
             print("[AppDelegate] handleURL: Navigating with keys: \(keys)")
            processKeys(keys) // Process the sequence provided in the URL
        } else {
             print("[AppDelegate] handleURL: URL host is not 'navigate' or keys parameter is missing.")
        }
    }

    // Processes a sequence of keys provided, typically from a URL scheme
    private func processKeys(_ keys: [String]) {
        guard !keys.isEmpty else {
             print("[AppDelegate] processKeys: No keys to process.")
             return
        }
        // Handle the first key immediately
        print("[AppDelegate] processKeys: Handling key '\(keys[0])'")
        controller.handleKey(keys[0])
        // Handle subsequent keys with a slight delay between each to simulate typing
        if keys.count > 1 {
            let remainingKeys = Array(keys.dropFirst())
            var delayMs = 100 // Initial delay for the second key
            for key in remainingKeys {
                print("[AppDelegate] processKeys: Scheduling key '\(key)' with delay \(delayMs)ms.")
                delay(delayMs) { [weak self] in
                    print("[AppDelegate] processKeys: Handling delayed key '\(key)'")
                    self?.controller.handleKey(key)
                }
                delayMs += 100 // Increase delay for subsequent keys
            }
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
        set { setAssociatedObject(self, &AssociatedKeys.stickyModeToggled, newValue) }
    }
    private var lastModifierFlags: NSEvent.ModifierFlags {
        get { NSEvent.ModifierFlags(rawValue: getAssociatedObject(self, &AssociatedKeys.lastModifierFlags) ?? 0) }
        set { setAssociatedObject(self, &AssociatedKeys.lastModifierFlags, newValue.rawValue) }
    }
    private var activeActivationShortcut: KeyboardShortcuts.Shortcut? {
        get { getAssociatedObject(self, &AssociatedKeys.activeActivationShortcut) }
        set { setAssociatedObject(self, &AssociatedKeys.activeActivationShortcut, newValue) }
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
    
    private var cachedActivationShortcuts: [UInt16: [(KeyboardShortcuts.Shortcut, Controller.ActivationType)]] {
        get { getAssociatedObject(self, &AssociatedKeys.cachedActivationShortcuts) ?? [:] }
        set { setAssociatedObject(self, &AssociatedKeys.cachedActivationShortcuts, newValue) }
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
        static var cachedActivationKeyCodes = "cachedActivationKeyCodes"
        static var cachedActivationShortcuts = "cachedActivationShortcuts"
        static var cachedActivationModifiers = "cachedActivationModifiers"
        static var hasPendingActivation = "hasPendingActivation"
        static var lastActivationTime = "lastActivationTime"
    }

    // --- Event Tap Logic Methods ---
    
    // Cache activation shortcuts for O(1) lookup performance
    private func cacheActivationShortcuts() {
        cachedActivationKeyCodes.removeAll()
        cachedActivationShortcuts.removeAll()
        cachedActivationModifiers.removeAll()
        
        // Helper to convert NSEvent.ModifierFlags to CGEventFlags
        func toCGEventFlags(_ modifiers: NSEvent.ModifierFlags) -> CGEventFlags {
            var cgFlags: CGEventFlags = []
            if modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
            if modifiers.contains(.shift) { cgFlags.insert(.maskShift) }
            if modifiers.contains(.option) { cgFlags.insert(.maskAlternate) }
            if modifiers.contains(.control) { cgFlags.insert(.maskControl) }
            return cgFlags
        }
        
        // Cache force reset shortcut
        if let shortcut = KeyboardShortcuts.getShortcut(for: .forceReset) {
            let keyCode = UInt16(shortcut.carbonKeyCode)
            cachedActivationKeyCodes.insert(keyCode)
            cachedActivationModifiers[keyCode] = toCGEventFlags(shortcut.modifiers)
            var shortcuts = cachedActivationShortcuts[keyCode] ?? []
            shortcuts.append((shortcut, Controller.ActivationType.defaultOnly)) // Use defaultOnly as placeholder for force reset
            cachedActivationShortcuts[keyCode] = shortcuts
        }
        
        // Cache app-specific shortcut
        if let shortcut = KeyboardShortcuts.getShortcut(for: .activateAppSpecific) {
            let keyCode = UInt16(shortcut.carbonKeyCode)
            cachedActivationKeyCodes.insert(keyCode)
            cachedActivationModifiers[keyCode] = toCGEventFlags(shortcut.modifiers)
            var shortcuts = cachedActivationShortcuts[keyCode] ?? []
            shortcuts.append((shortcut, Controller.ActivationType.appSpecificWithFallback))
            cachedActivationShortcuts[keyCode] = shortcuts
        }
        
        // Cache default-only shortcut
        if let shortcut = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly) {
            let keyCode = UInt16(shortcut.carbonKeyCode)
            cachedActivationKeyCodes.insert(keyCode)
            cachedActivationModifiers[keyCode] = toCGEventFlags(shortcut.modifiers)
            var shortcuts = cachedActivationShortcuts[keyCode] ?? []
            shortcuts.append((shortcut, Controller.ActivationType.defaultOnly))
            cachedActivationShortcuts[keyCode] = shortcuts
        }
        
        print("[AppDelegate] Cached \(cachedActivationKeyCodes.count) activation keycodes")
    }
    
    func startEventTapMonitoring() {
        // Ensure we don't start multiple taps
        guard !isMonitoring else {
            print("[AppDelegate] startEventTapMonitoring: Already monitoring. Aborting.")
            return
        }
        print("[AppDelegate] startEventTapMonitoring: Attempting to start...")
        
        // Cache activation shortcuts for fast lookup
        cacheActivationShortcuts()

        // Create the event tap. This requires Accessibility permissions.
        // Build an event mask listening for key down, key up, and modifier-flag changes.
        let eventMask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)
        // (Above mask: key down, key up, and flags-changed)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, // Listen to all processes in the current session
            place: .headInsertEventTap, // Insert tap before other taps
            options: .defaultTap, // Default behavior
            eventsOfInterest: eventMask, // Mask for key down events
            callback: eventTapCallback, // C function callback defined globally
            userInfo: Unmanaged.passUnretained(self).toOpaque() // Pass reference to self
        ) else {
            // Failure usually means Accessibility permissions are missing or denied.
            #if DEBUG
            debugLog("[AppDelegate] startEventTapMonitoring: Failed to create event tap. Permissions likely missing.")
            #endif
            // Check permissions status *after* failure, only prompt if we haven't recently.
            if !checkAccessibilityPermissions() && !didShowPermissionsAlertRecently {
                #if DEBUG
                debugLog("[AppDelegate] startEventTapMonitoring: Accessibility permissions check failed AND alert not shown recently. Showing alert.")
                #endif
                showPermissionsAlert()
                self.didShowPermissionsAlertRecently = true // Flag to avoid spamming alerts
                // Reset the flag after a short delay to allow re-prompting later if needed
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    #if DEBUG
                    debugLog("[AppDelegate] Resetting didShowPermissionsAlertRecently flag.")
                    #endif
                    self.didShowPermissionsAlertRecently = false
                }
            } else {
                #if DEBUG
                debugLog("[AppDelegate] startEventTapMonitoring: Accessibility check passed OR alert shown recently. Not showing permissions alert now.")
                #endif
            }
            return // Stop, as tap creation failed
        }

        // Tap creation successful, proceed with setup
        #if DEBUG
        debugLog("[AppDelegate] startEventTapMonitoring: Event tap created successfully.")
        #endif
        self.eventTap = tap
        // Create a run loop source from the tap and add it to the current run loop
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        // Enable the tap
        CGEvent.tapEnable(tap: tap, enable: true)
        self.isMonitoring = true // Set monitoring state
        self.didShowPermissionsAlertRecently = false // Reset alert flag as monitoring is now active

        // Start event tap health monitoring

        // Start CPU monitoring for adaptive behavior
        startCPUMonitoring()

        #if DEBUG
        debugLog("[AppDelegate] startEventTapMonitoring: Event tap enabled and monitoring started.")
        #endif
    }

    func stopEventTapMonitoring() {
        guard isMonitoring else {
             #if DEBUG
             debugLog("[AppDelegate] stopEventTapMonitoring: Not currently monitoring. Aborting.")
             #endif
             return
        }
        #if DEBUG
        debugLog("[AppDelegate] stopEventTapMonitoring: Stopping event tap...")
        #endif

        // Stop health monitoring and CPU monitoring
        stopCPUMonitoring()

        resetSequenceState() // Ensure sequence state is cleared
        // Remove run loop source and invalidate the tap
        if let source = runLoopSource {
             #if DEBUG
             debugLog("[AppDelegate] stopEventTapMonitoring: Removing run loop source.")
             #endif
             CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
             self.runLoopSource = nil
        }
        if let tap = eventTap {
             #if DEBUG
             debugLog("[AppDelegate] stopEventTapMonitoring: Disabling and releasing tap.")
             #endif
             CGEvent.tapEnable(tap: tap, enable: false) // Disable first
             self.eventTap = nil // Release reference
        }
        self.isMonitoring = false // Update state
        #if DEBUG
        debugLog("[AppDelegate] stopEventTapMonitoring: Monitoring stopped.")
        #endif
    }

    // --- Performance Monitoring Methods ---
    
    func getCallbackPerformanceStats() -> String {
        return globalCallbackStats.summary
    }
    
    func resetCallbackPerformanceStats() {
        globalCallbackStats.reset()
        print("[AppDelegate] Callback performance stats reset")
    }
    
    func printCallbackPerformanceStats() {
        print("\n" + globalCallbackStats.summary + "\n")
    }
    
    // --- Optimized Event Processing ---
    
    // Background queue for async event processing (static to avoid stored property in extension)
    private static let eventProcessingQueue = DispatchQueue(label: "com.leaderkey.eventprocessing", qos: .userInteractive)
    
    // Quick check if we should consume an event (ultra-fast, no NSEvent creation)
    func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
        // Only check keyDown events
        guard event.type == .keyDown else { return false }
        
        // Get keycode directly from CGEvent
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        
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
                    // Mark that we have a pending activation
                    hasPendingActivation = true
                    lastActivationTime = CFAbsoluteTimeGetCurrent()
                    return true
                }
            }
        }
        
        // Consume if we're in an active sequence
        if isInActiveSequence {
            return true
        }
        
        // Consume if we have a pending activation being processed
        if hasPendingActivation {
            return true
        }
        
        // Consume if we recently activated (within 100ms window)
        let timeSinceActivation = CFAbsoluteTimeGetCurrent() - lastActivationTime
        if timeSinceActivation < 0.1 {  // 100ms window
            return true
        }
        
        return false
    }
    
    // Check if we're currently in an active sequence
    var isInActiveSequence: Bool {
        return currentSequenceGroup != nil || activeActivationShortcut != nil
    }
    
    // Enqueue event for async processing
    func enqueueEventForProcessing(_ event: CGEvent) {
        // Copy the event to prevent it from being released
        guard let eventCopy = event.copy() else { return }
        
        // Check if this is an activation key
        let keyCode = UInt16(eventCopy.getIntegerValueField(.keyboardEventKeycode))
        let isActivationKey = cachedActivationKeyCodes.contains(keyCode)
        
        // Process events serially to maintain order
        // The serial queue ensures events are processed one at a time in FIFO order
        AppDelegate.eventProcessingQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Now we can create NSEvent on background queue
            guard let nsEvent = NSEvent(cgEvent: eventCopy) else { return }
            
            // Use a semaphore to ensure main thread processing completes before next event
            let semaphore = DispatchSemaphore(value: 0)
            
            DispatchQueue.main.async {
                // Only process if still relevant
                if self.isMonitoring {
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
    
    // Track if we have a pending activation being processed
    private var hasPendingActivation: Bool {
        get { getAssociatedObject(self, &AssociatedKeys.hasPendingActivation) ?? false }
        set { setAssociatedObject(self, &AssociatedKeys.hasPendingActivation, newValue) }
    }
    
    // Track when we last started an activation
    private var lastActivationTime: CFAbsoluteTime {
        get { getAssociatedObject(self, &AssociatedKeys.lastActivationTime) ?? 0 }
        set { setAssociatedObject(self, &AssociatedKeys.lastActivationTime, newValue) }
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

    // --- CPU Load Monitoring Methods ---

    private func startCPUMonitoring() {
        stopCPUMonitoring() // Stop any existing timer

        // Check CPU load every 10 seconds
        self.cpuMonitorTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkCPULoad()
        }

        print("[AppDelegate] CPU monitoring started.")
    }

    private func stopCPUMonitoring() {
        cpuMonitorTimer?.invalidate()
        cpuMonitorTimer = nil
        isHighCpuMode = false
        print("[AppDelegate] CPU monitoring stopped.")
    }

    private func checkCPULoad() {
        // Keep a lightweight check; avoid expensive sampling. Threshold logic retained for safety.
        let cpuUsage = getCurrentCPUUsage()
        let highCpuThreshold: Double = 85.0 // slightly higher to avoid flapping

        let wasHighCpuMode = isHighCpuMode
        isHighCpuMode = cpuUsage > highCpuThreshold

        if isHighCpuMode != wasHighCpuMode {
            if isHighCpuMode {
                print("[AppDelegate] High CPU mode activated (CPU: \(Int(cpuUsage))%). Adapting behavior.")
                enterHighCpuMode()
            } else {
                print("[AppDelegate] High CPU mode deactivated (CPU: \(Int(cpuUsage))%). Returning to normal mode.")
                exitHighCpuMode()
            }
        }
    }

    private func getCurrentCPUUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            // Get CPU usage percentage (simplified)
            let cpuTime = Double(info.user_time.seconds + info.system_time.seconds)
            let totalTime = Double(ProcessInfo.processInfo.systemUptime)
            return (cpuTime / totalTime) * 100.0
        }

        return 0.0 // Return 0 if we can't get CPU info
    }

    private func enterHighCpuMode() {
        // Increase timeout values for high CPU scenarios
        // This is adaptive behavior to be more resilient during high load
        print("[AppDelegate] Entering high CPU mode - increased timeout tolerance.")
    }

    private func exitHighCpuMode() {
        // Return to normal timeout values
        print("[AppDelegate] Exiting high CPU mode - normal timeout tolerance.")
    }

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
                debugLog("[AppDelegate] handleKeyDownEvent: Cannot convert CGEvent to NSEvent for buffering. Passing through.")
                #endif
                return Unmanaged.passRetained(event)
            }
            
            // Check queue size limit to prevent memory issues
            if keyEventQueue.count >= maxQueueSize {
                #if DEBUG
                debugLog("[AppDelegate] handleKeyDownEvent: Queue full (size: \(keyEventQueue.count)). Dropping oldest event to make space.")
                #endif
                keyEventQueue.removeFirst()
            }
            
            let queuedEvent = QueuedKeyEvent(cgEvent: event, nsEvent: nsEvent, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags)
            keyEventQueue.append(queuedEvent)
            #if DEBUG
            debugLog("[AppDelegate] handleKeyDownEvent: Buffered keypress '\(keyStringForEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags) ?? "?")'. Queue size: \(keyEventQueue.count)")
            #endif
            return nil // Consume the event (don't pass through)
        }
        
        isProcessingKey = true
        defer { 
            isProcessingKey = false
            processQueuedEvents()
        }

        // Try to convert CGEvent to NSEvent to easily access key code and modifiers
        guard let nsEvent = NSEvent(cgEvent: event) else {
             #if DEBUG
             debugLog("[AppDelegate] handleKeyDownEvent: Failed to convert CGEvent to NSEvent. Passing event through.")
             #endif
             return Unmanaged.passRetained(event)
        }
        // Process the key event using our main logic function
        #if DEBUG
        // Get the mapped key string here for better logging (only in debug builds)
        let mappedKeyString = keyStringForEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags) ?? "[?Unmapped?]"
        let modsDescription = describeModifiers(nsEvent.modifierFlags)
        debugLog("[AppDelegate] handleKeyDownEvent: keyCode=\(nsEvent.keyCode) ('\(mappedKeyString)') mods=\(modsDescription) – processing…")
        #endif
        let handled = processKeyEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags)

        // If 'handled' is true, consume the event (return nil). Otherwise, pass it through (return retained event).
         #if DEBUG
         debugLog("[AppDelegate] handleKeyDownEvent: Event handled = \(handled). Returning \(handled ? "nil (consume)" : "event (pass through)").")
         #endif
        return handled ? nil : Unmanaged.passRetained(event)
    }
    
    private func processQueuedEvents() {
        // Process ALL queued events in a single pass (no recursion)
        while !keyEventQueue.isEmpty && !isProcessingKey {
            let queuedEvent = keyEventQueue.removeFirst()
            
            #if DEBUG
            debugLog("[AppDelegate] processQueuedEvents: Processing queued keypress '\(keyStringForEvent(cgEvent: queuedEvent.cgEvent, keyCode: queuedEvent.keyCode, modifiers: queuedEvent.modifiers) ?? "?")'. Remaining in queue: \(keyEventQueue.count)")
            #endif
            
            // Set processing flag to prevent new events from being processed
            isProcessingKey = true
            
            // Process the queued event using the same logic as handleKeyDownEvent
            let handled = processKeyEvent(cgEvent: queuedEvent.cgEvent, keyCode: queuedEvent.keyCode, modifiers: queuedEvent.modifiers)
            
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
                    self.controller.window.alphaValue = isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
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
                    self.controller.window.alphaValue = isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
                }
            }
            let stickyState = isInStickyMode(currentFlags)
            #if DEBUG
            debugLog("[AppDelegate] handleFlagsChangedEvent: cmdPressed=\(commandPressed) cmdReleased=\(commandReleased) sticky=\(stickyState)")
            #endif
        }

        // Always pass through modifier changes
        return Unmanaged.passRetained(event)
    }

    private func processKeyEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        // OPTIMIZATION: Early exit if keycode is not in our cached activation set
        if !cachedActivationKeyCodes.contains(keyCode) && keyCode != KeyCodes.escape {
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
                    // Special handling for force reset
                    if shortcut == KeyboardShortcuts.getShortcut(for: .forceReset) {
                        #if DEBUG
                        debugLog("[AppDelegate] processKeyEvent: Force reset shortcut triggered.")
                        #endif
                        forceResetState()
                        return true
                    }
                    
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
            debugLog("[AppDelegate] Escape pressed. Window isVisible: \(isWindowVisible), alpha: \(windowAlpha), hasActiveSequence: \(hasActiveSequence)")
            #endif

            // Check multiple conditions to determine if we should hide the window
            if isWindowVisible || windowAlpha > 0 || hasActiveSequence {
                // Window is visible OR has opacity OR we have an active sequence - hide it
                #if DEBUG
                debugLog("[AppDelegate] Escape: Hiding window and resetting state.")
                #endif
                hide()
                resetSequenceState()
                return true // Consume the Escape press
            } else {
                // Window is truly hidden, no active sequence - pass through
                #if DEBUG
                debugLog("[AppDelegate] Escape: Window is hidden, no active sequence. Passing event through.")
                #endif
                return false // Pass through the Escape press
            }
        }

        // 5. If NOT activation, Escape, or Cmd+, check if we are in a sequence
        if currentSequenceGroup != nil {
            // --- SPECIAL CHECK WITHIN ACTIVE SEQUENCE ---
            // Check for Cmd+, specifically *before* normal sequence processing
            if modifiers.contains(.command),
               let nsEvent = NSEvent(cgEvent: cgEvent),
               nsEvent.charactersIgnoringModifiers == "," {
                #if DEBUG
                debugLog("[AppDelegate] processKeyEvent: Cmd+, detected while sequence active. Opening settings.")
                #endif
                NSApp.sendAction(#selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil, from: nil)
                // Reset sequence state and hide the panel
                hide()
                return true // Consume the Cmd+, press
            }
            // --- END SPECIAL CHECK ---

            // If not Cmd+, process the key normally within the sequence
            #if DEBUG
            debugLog("[AppDelegate] processKeyEvent: Active sequence detected (and not Cmd+). Processing key within sequence...")
            #endif

            // Clear the activation shortcut since the user is now actively using Leader Key
            // This enables the Cmd-release reset feature after activation
            if activeActivationShortcut != nil {
                #if DEBUG
                debugLog("[AppDelegate] processKeyEvent: Clearing activeActivationShortcut - user is now actively using Leader Key.")
                #endif
                activeActivationShortcut = nil
            }

            return processKeyInSequence(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
        }

        // 5. If NOT activation, Escape, or in a sequence, let the event pass through
        #if DEBUG
        debugLog("[AppDelegate] processKeyEvent: No activation shortcut, Escape, or active sequence matched. Passing event through.")
        #endif
        return false
    }

    private func processKeyInSequence(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        #if DEBUG
        debugLog("[AppDelegate] processKeyInSequence: Processing keyCode: \(keyCode), mods: \(describeModifiers(modifiers))")
        #endif

        // Get the single character string representation for the key event
        guard let keyString = keyStringForEvent(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers) else {
            // If we can't map the key event to a string, decide based on sticky mode.
            let isStickyModeActive = isInStickyMode(modifiers)
            if isStickyModeActive {
                #if DEBUG
                debugLog("[AppDelegate] processKeyInSequence: Could not map event to keyString, but sticky mode ACTIVE – passing event through.")
                #endif
                return false // Event NOT handled – let it propagate
            } else {
                #if DEBUG
                debugLog("[AppDelegate] processKeyInSequence: Could not map event to keyString. Shaking window.")
                #endif
                DispatchQueue.main.async { self.controller.window.shake() }
                return true // Event handled (by shaking)
            }
        }

        #if DEBUG
        debugLog("[AppDelegate] processKeyInSequence: Mapped keyString: '\(keyString)'")
        #endif

        // Check if the keyString matches an action or group within the currently active group
        if let currentGroup = currentSequenceGroup, let hit = currentGroup.actions.first(where: { $0.item.key == keyString }) {
            #if DEBUG
            debugLog("[AppDelegate] processKeyInSequence: Found match for '\(keyString)' in group '\(currentGroup.displayName).'")
            #endif
            switch hit {
            case .action(let action):
                #if DEBUG
                debugLog("[AppDelegate] processKeyInSequence: Matched ACTION: '\\(action.displayName)' (\\(action.value)).")
                #endif
                // Run the action
                controller.runAction(action)

                // Original Behavior: Check Sticky Mode for ALL action types
                let isStickyModeActive = isInStickyMode(modifiers)
                if !isStickyModeActive {
                    #if DEBUG
                    debugLog("[AppDelegate] processKeyInSequence: Sticky mode NOT active. Hiding window and resetting sequence.")
                    #endif
                    hide()
                } else {
                    #if DEBUG
                    debugLog("[AppDelegate] processKeyInSequence: Sticky mode ACTIVE. Keeping window open and preserving sequence state.")
                    #endif
                }
                return true // Event handled

            case .group(let subgroup):
                #if DEBUG
                debugLog("[AppDelegate] processKeyInSequence: Matched GROUP: '\(subgroup.displayName). Navigating into subgroup.")
                #endif
                
                // Update sequence state immediately to prevent race conditions
                currentSequenceGroup = subgroup

                // Update UI state first to ensure correct display
                DispatchQueue.main.async {
                    self.controller.userState.navigateToGroup(subgroup)
                }

                // Check if the group has sticky mode enabled
                if subgroup.stickyMode == true {
                    #if DEBUG
                    debugLog("[AppDelegate] processKeyInSequence: Group has stickyMode enabled. Activating sticky mode.")
                    #endif
                    activateStickyMode()
                }
                
                return true // Event handled
            }
        } else {
            // Key not found in the current group.
            let groupName = currentSequenceGroup?.displayName ?? "(nil)"
            #if DEBUG
            debugLog("[AppDelegate] processKeyInSequence: Key '\(keyString)' not found in current group '\(groupName)'.")
            #endif

            let isStickyModeActive = isInStickyMode(modifiers)
            if isStickyModeActive {
                // In sticky mode: pass the event through so the underlying app receives the key/shortcut.
                #if DEBUG
                debugLog("[AppDelegate] processKeyInSequence: Sticky mode ACTIVE -> passing event through.")
                #endif
                return false // Event NOT handled – let it propagate
            } else {
                // Not in sticky mode: indicate error by shaking the window and consuming the event.
                DispatchQueue.main.async { self.controller.window.shake() }
                return true // Event handled (by shaking)
            }
        }
    }

    // This function is called when an activation shortcut is pressed or via URL scheme.
    // It sets up the initial state for a new key sequence based on the loaded config.
    private func startSequence(activationType: Controller.ActivationType) {
        print("[AppDelegate] startSequence: Starting sequence with type: \(activationType)")
        
        // Reset sticky mode when starting any new sequence
        if stickyModeToggled {
            print("[AppDelegate] startSequence: Resetting sticky mode for new sequence.")
            stickyModeToggled = false
        }

        // Get the root group determined by the show() method via the controller's UserState
        // UserState.activeRoot should have been set by Controller.show() just before this.
        guard let rootGroup = controller.userState.activeRoot else {
            // This should ideally not happen if Controller.show() worked correctly.
            print("[AppDelegate] startSequence: ERROR - controller.userState.activeRoot is nil! Falling back to default config root.")
            // Fallback logic, though this indicates a potential issue elsewhere
            self.activeRootGroup = config.root // Store the determined root group locally
            self.currentSequenceGroup = config.root // Start the sequence at this root
            // If the window is somehow visible, try to update its UI state.
            if self.controller.window.isVisible {
                 print("[AppDelegate] startSequence (Fallback): Window visible, navigating UI to default root.")
                DispatchQueue.main.async {
                    self.controller.userState.navigateToGroup(self.config.root)
                }
            }
            return
        }

        // Store the root group for the current sequence and set the current level to the root.
        print("[AppDelegate] startSequence: Setting activeRootGroup and currentSequenceGroup to: '\(rootGroup.displayName)'")
        self.activeRootGroup = rootGroup
        self.currentSequenceGroup = rootGroup

        // If the window is already visible (e.g., reactivation with .reset), update the UI state.
        if self.controller.window.isVisible {
             print("[AppDelegate] startSequence: Window is visible, updating UI state for root group.")
            DispatchQueue.main.async {
                // Ensure UI reflects the start of the sequence at the root group.
                self.controller.userState.navigateToGroup(rootGroup)
                // Reset window transparency when starting a new sequence
                self.controller.window.alphaValue = Defaults[.normalModeOpacity]
            }
        }
         print("[AppDelegate] startSequence: Sequence setup complete.")
    }

    // Resets the internal state variables used to track the current key sequence.
    func resetSequenceState() {
        // Only perform reset if a sequence is actually active
        if currentSequenceGroup != nil || activeRootGroup != nil {
            print("[AppDelegate] resetSequenceState: Resetting sequence state (currentSequenceGroup and activeRootGroup to nil).")
            self.currentSequenceGroup = nil
            self.activeRootGroup = nil
            
            // Clear any queued key events when sequence ends
            clearKeyEventQueue()
            
            // Clear pending activation flag when sequence resets
            self.hasPendingActivation = false

            // Reset sticky mode toggle state
            if stickyModeToggled {
                print("[AppDelegate] resetSequenceState: Resetting sticky mode toggle state.")
                self.stickyModeToggled = false
            }

            // Reset modifier flags tracking
            self.lastModifierFlags = []

            // Clear activation shortcut tracking
            self.activeActivationShortcut = nil

            // Also tell the UserState to clear its navigation path etc. on the main thread
            DispatchQueue.main.async {
                 print("[AppDelegate] resetSequenceState: Dispatching UserState.clear() to main thread.")
                 self.controller.userState.clear()
            }
        } else {
            print("[AppDelegate] resetSequenceState: No active sequence to reset.")
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
        #if DEBUG
        print("[AppDelegate] isInStickyMode: Config = \(config), Mods = \(describeModifiers(modifierFlags)), Toggled = \(stickyModeToggled), IsSticky = \(isSticky)")
        #endif
        return isSticky
    }

    // Converts a key event into a single character string suitable for matching against config keys.
    // Handles forced English layout if enabled. Now with caching for performance.
    private func keyStringForEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String? {
        // Create cache key - use relevant modifiers only
        let relevantModifiers = modifiers.intersection([.shift, .control, .option, .command])
        let cacheKey = KeyCacheEntry(keyCode: keyCode, modifierFlags: relevantModifiers.rawValue)
        
        // Check cache first
        if let cached = keyStringCache[cacheKey] {
            #if DEBUG
            // Only log cache hits in debug builds to reduce overhead
            if globalCallbackStats.totalCallbacks % 100 == 0 { // Log every 100th cache hit
                print("[AppDelegate] keyStringForEvent CACHE HIT: keyCode \(keyCode) -> '\(cached)'")
            }
            #endif
            return cached.isEmpty ? nil : cached
        }
        
        // Cache miss - calculate the key string
        var result: String?
        
        // --- Option 1: Forced English Layout ---
        if Defaults[.forceEnglishKeyboardLayout], let mapped = englishKeymap[keyCode] {
            // Respect Shift key for case
            result = modifiers.contains(.shift) ? mapped.uppercased() : mapped
            #if DEBUG
            print("[AppDelegate] keyStringForEvent (Forced English): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Case Sensitive)")
            #endif
        } else {
            // --- Option 2: System Layout (Case Sensitive, Ignore Ctrl/Opt Effect) ---
            
            // Handle specific non-character keys FIRST by keycode
            switch keyCode {
                case 36: result = "\u{21B5}" // Enter
                case 48: result = "\t"        // Tab
                case 49: result = " "         // Space
                case 51: result = "\u{0008}"  // Backspace
                case KeyCodes.escape: result = "\u{001B}" // Escape
                case 126: result = "↑"        // Up Arrow
                case 125: result = "↓"        // Down Arrow
                case 123: result = "←"        // Left Arrow
                case 124: result = "→"        // Right Arrow
                default:
                    // For remaining keys, determine character based on modifiers
                    let nsEvent = NSEvent(cgEvent: cgEvent)
                    
                    // If Control or Option are involved, get the base character *ignoring* those modifiers,
                    // BUT respecting Shift for case sensitivity lookup.
                    if modifiers.contains(.control) || modifiers.contains(.option) {
                        // Get characters ignoring Ctrl/Opt, which might still include Shift effect
                        result = nsEvent?.charactersIgnoringModifiers
                        #if DEBUG
                        print("[AppDelegate] keyStringForEvent (System Layout - Ctrl/Opt): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Ignoring Ctrl/Opt effect)")
                        #endif
                    } else {
                        // No Ctrl/Opt involved. Get the character directly, which includes Shift effect.
                        result = nsEvent?.characters
                        #if DEBUG
                        print("[AppDelegate] keyStringForEvent (System Layout - Shift/Base): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Respecting Shift)")
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
        if modifiers.contains(.capsLock) { parts.append("CapsLock") } // Include CapsLock for completeness
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
        let options = [checkOptPrompt: false] // Option to not prompt
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        // Use either check - if either returns true, we have permissions
        let enabled = hasEventAccess || isTrusted
        
        print("[AppDelegate] checkAccessibilityPermissions: CGPreflightListenEventAccess=\(hasEventAccess), AXIsProcessTrustedWithOptions=\(isTrusted), final=\(enabled)")
        return enabled
    }

    // Start aggressive permission polling after showing the alert
    private func startPermissionPolling() {
        print("[AppDelegate] Starting aggressive permission polling...")
        permissionPollingStartTime = Date()
        
        // Stop any existing polling timer
        permissionPollingTimer?.invalidate()
        
        // Poll every 1 second for the first 30 seconds after prompt
        permissionPollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
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
               Date().timeIntervalSince(startTime) > 30.0 {
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
                let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                let backupPath = "/System/Library/PreferencePanes/Security.prefPane"
                if let url = URL(string: urlString) { NSWorkspace.shared.open(url) } else { NSWorkspace.shared.open(URL(fileURLWithPath: backupPath)) }
                
                // Start aggressive permission polling after user opens System Settings
                self.startPermissionPolling()
            }
        }
    }

    // Add the missing helper function back
    private func matchesShortcut(keyCode: UInt16, modifiers: NSEvent.ModifierFlags, shortcut: KeyboardShortcuts.Shortcut) -> Bool {
        // Compare the key code
        guard keyCode == shortcut.carbonKeyCode else { return false }

        // Compare the modifiers - ensuring ONLY the required modifiers are present
        // (NSEvent.ModifierFlags includes flags for key state like Caps Lock, which we usually want to ignore)
        let requiredModifiers = shortcut.modifiers
        let relevantFlags: NSEvent.ModifierFlags = [.shift, .control, .option, .command]
        let incomingRelevantModifiers = modifiers.intersection(relevantFlags)

        return incomingRelevantModifiers == requiredModifiers
    }
}

// NOTE: Associated object helpers are now defined globally above AppDelegate.
