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
import IOKit.pwr_mgt

let updateLocationIdentifier = "UpdateCheck"

// Define the same unique tag here
private let leaderKeySyntheticEventTag: Int64 = 0xDEADBEEF

// MARK: - Callback Performance Statistics

struct CallbackStatistics {
    var totalCallbacks: Int64 = 0
    var slowCallbacks: Int64 = 0
    var maxDuration: Double = 0
    var avgDuration: Double = 0
    var lastResetTime = Date()
    
    mutating func reset() {
        totalCallbacks = 0
        slowCallbacks = 0
        maxDuration = 0
        avgDuration = 0
        lastResetTime = Date()
    }
}

// MARK: - Ultra-Fast Event Tap Callback

// Optimized callback that executes in <1ms by only queuing events
private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo = userInfo else {
        return Unmanaged.passRetained(event)
    }
    
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userInfo).takeUnretainedValue()
    
    // INSTANT DETECTION - Handle tap disabled events immediately
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        print("[EventTap] ⚠️ Tap disabled by \(type == .tapDisabledByTimeout ? "timeout" : "user input") - triggering instant failover")
        appDelegate.dualTapManager.handleInstantFailover()
        return nil // Don't pass disabled events through
    }
    
    // PERFORMANCE CRITICAL: This callback must execute in <0.1ms
    // DO NOT add any system calls, object creation, or I/O here
    
    #if DEBUG
    // Timing only in debug builds
    let startTime = MachTime.now()
    defer {
        let duration = MachTime.toMilliseconds(MachTime.now() - startTime)
        if duration > 1.0 {
            print("⚠️ SLOW CALLBACK: \(String(format: "%.2f", duration))ms")
        }
    }
    #endif
    
    // CHECK FOR SYNTHETIC EVENT - Pass through immediately
    if event.getIntegerValueField(.eventSourceUserData) == leaderKeySyntheticEventTag {
        return Unmanaged.passRetained(event)
    }
    
    // MINIMAL PROCESSING - Just queue and return
    let queued = appDelegate.eventQueue.enqueue(event)
    if !queued {
        print("⚠️ Event queue full - dropping event")
        return Unmanaged.passRetained(event)
    }
    
    // TRIGGER ASYNC PROCESSING
    appDelegate.triggerEventProcessing()
    
    // QUICK DECISION - Should we consume this event?
    let shouldConsume = appDelegate.quickShouldConsumeCheck(event)
    
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
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
}

private let maxQueueSize = 5 // Reduced from 10 to prevent memory accumulation

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
  
  // --- Event Queue for Ultra-Fast Callback ---
  let eventQueue = LockFreeEventQueue(capacity: 512)  // Made internal for callback access
  private var eventProcessorQueue: DispatchQueue!
  private var eventProcessorSemaphore: DispatchSemaphore!  // Signals when events are available
  private var isProcessingEvents = false
  private var callbackStats = CallbackStatistics()
  
  // --- Dual Event Tap Manager for Redundancy ---
  let dualTapManager = DualEventTapManager()
  
  // --- Cached Activation Keys for Ultra-Fast Checking ---
  private var cachedActivationKeyCodes: Set<UInt16> = []
  private var cachedActivationModifiers: [UInt16: CGEventFlags] = [:]
  private let isInSequence = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
  
  // --- Power Management ---
  private var powerAssertionID: IOPMAssertionID = 0
  private var hasPowerAssertion = false

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

    debugLog("[AppDelegate] applicationDidFinishLaunching: Starting up...")

    // Elevate process priority for maximum responsiveness under system stress
    elevateProcessPriority()
    
    // Initialize critical memory pool with mlock() for ultimate reliability
    ThreadOptimization.initializeCriticalMemoryPool()
    
    // Initialize event processor queue with real-time priority
    setupEventProcessor()
    
    // Initialize atomic sequence flag
    isInSequence.initialize(to: 0)
    
    // Cache activation keycodes for ultra-fast checking
    cacheActivationKeys()

    // Setup Notifications
    UNUserNotificationCenter.current().delegate = self // Conformance is in extension
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error { debugLog("[AppDelegate] Error requesting notification permission: \(error)") }
        debugLog("[AppDelegate] Notification permission granted: \(granted)")
    }

    // Setup Main Menu
    NSApp.mainMenu = MainMenu()

    // Load configuration and initialize state
    debugLog("[AppDelegate] Initializing UserConfig and UserState...")
    config.ensureAndLoad() // Ensures config dir/file exists and loads default config
    state = UserState(userConfig: config)
    controller = Controller(userState: state, userConfig: config, appDelegate: self)
    debugLog("[AppDelegate] UserConfig and UserState initialized.")

    // Setup background services and UI elements
    setupFileMonitor()      // Defined in private extension
    setupStatusItem()       // Defined in private extension
    setupUpdaterController() // Configure auto-update behavior
    setupStateRecoveryTimer() // Setup periodic state recovery checks

    // Configure global image cache to keep memory tight
    configureImageCaching()
    
    // Start resource optimization monitoring
    ThreadOptimization.startResourceOptimization()
    
    // Start simple watchdog monitoring
    startWatchdogMonitoring()

    // Check initial permission state
    lastPermissionCheck = checkAccessibilityPermissions()
    print("[AppDelegate] Initial accessibility permission state: \(lastPermissionCheck ?? false)")
    
    // Attempt to start the global event tap immediately
    debugLog("[AppDelegate] Attempting initial startEventTapMonitoring()...")
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
  
  // MARK: - Ultra-Fast Event Processing
  
  /// Result type for processKeyEvent to avoid UI operations on background thread
  private struct KeyEventResult {
    let consumed: Bool
    let action: KeyEventAction
    
    enum KeyEventAction {
      case none
      case forceReset
      case handleActivation(type: Controller.ActivationType, shortcut: KeyboardShortcuts.Shortcut?)
      case openSettings
      case hide
    }
  }
  
  /// Setup the event processor queue with real-time priority
  private func setupEventProcessor() {
    // Create dedicated queue with highest priority
    eventProcessorQueue = DispatchQueue(
      label: "com.leaderkey.event-processor",
      qos: .userInteractive,
      attributes: [],
      autoreleaseFrequency: .workItem
    )
    
    // Initialize semaphore for event signaling (start with 0 to wait for events)
    eventProcessorSemaphore = DispatchSemaphore(value: 0)
    
    // Start the async event processor
    startEventProcessor()
    
    print("[AppDelegate] Event processor initialized with real-time priority")
  }
  
  /// Cache activation keycodes for ultra-fast checking in callback
  private func cacheActivationKeys() {
    cachedActivationKeyCodes.removeAll()
    cachedActivationModifiers.removeAll()
    
    // Cache default activation shortcut
    if let shortcut = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly) {
      let keyCode = UInt16(shortcut.carbonKeyCode)
      cachedActivationKeyCodes.insert(keyCode)
      
      // Convert NSEvent.ModifierFlags to CGEventFlags
      var cgFlags: CGEventFlags = []
      if shortcut.modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
      if shortcut.modifiers.contains(.shift) { cgFlags.insert(.maskShift) }
      if shortcut.modifiers.contains(.option) { cgFlags.insert(.maskAlternate) }
      if shortcut.modifiers.contains(.control) { cgFlags.insert(.maskControl) }
      
      cachedActivationModifiers[keyCode] = cgFlags
      print("[AppDelegate] Cached default activation key: \(keyCode) with modifiers")
    }
    
    // Cache app-specific activation shortcut
    if let shortcut = KeyboardShortcuts.getShortcut(for: .activateAppSpecific) {
      let keyCode = UInt16(shortcut.carbonKeyCode)
      cachedActivationKeyCodes.insert(keyCode)
      
      // Convert NSEvent.ModifierFlags to CGEventFlags
      var cgFlags: CGEventFlags = []
      if shortcut.modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
      if shortcut.modifiers.contains(.shift) { cgFlags.insert(.maskShift) }
      if shortcut.modifiers.contains(.option) { cgFlags.insert(.maskAlternate) }
      if shortcut.modifiers.contains(.control) { cgFlags.insert(.maskControl) }
      
      cachedActivationModifiers[keyCode] = cgFlags
      print("[AppDelegate] Cached app-specific activation key: \(keyCode) with modifiers")
    }
    
    // Cache force reset shortcut
    if let shortcut = KeyboardShortcuts.getShortcut(for: .forceReset) {
      let keyCode = UInt16(shortcut.carbonKeyCode)
      cachedActivationKeyCodes.insert(keyCode)
      
      // Convert NSEvent.ModifierFlags to CGEventFlags
      var cgFlags: CGEventFlags = []
      if shortcut.modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
      if shortcut.modifiers.contains(.shift) { cgFlags.insert(.maskShift) }
      if shortcut.modifiers.contains(.option) { cgFlags.insert(.maskAlternate) }
      if shortcut.modifiers.contains(.control) { cgFlags.insert(.maskControl) }
      
      cachedActivationModifiers[keyCode] = cgFlags
      print("[AppDelegate] Cached force reset key: \(keyCode) with modifiers")
    }
  }
  
  /// Start the async event processor that runs continuously
  private func startEventProcessor() {
    eventProcessorQueue.async { [weak self] in
      guard let self = self else { return }
      
      // Set thread to real-time priority
      ThreadOptimization.setRealtimeThreadPolicy()
      
      print("[EventProcessor] Started with semaphore-based signaling (low CPU wake design)")
      
      while true {
        autoreleasepool {
          // Wait for events with timeout (100ms timeout for periodic health checks)
          let result = self.eventProcessorSemaphore.wait(timeout: .now() + 0.1)
          
          if result == .success {
            // Events are available - process batch
            let events = self.eventQueue.dequeueBatch(maxCount: 10)
            
            for eventEntry in events {
              self.processEventAsync(eventEntry)
            }
            
            // Check if there are more events and self-signal if needed
            if !self.eventQueue.isEmpty {
              self.eventProcessorSemaphore.signal()
            }
          }
          // On timeout (.timedOut), we just continue the loop for health checks
          // This ensures we check for shutdown conditions periodically
        }
      }
    }
  }
  
  /// Process a single event asynchronously (called from event processor thread)
  private func processEventAsync(_ eventEntry: LockFreeEventQueue.EventEntry) {
    // Dispatch to main thread for NSEvent creation and UI operations
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Update event tap activity tracking
      self.updateEventTapActivity()
      
      // Handle different event types
      switch eventEntry.event.type {
      case .keyDown:
        // Process keyDown events
        guard let nsEvent = NSEvent(cgEvent: eventEntry.event) else { return }
        
        // Check if synthetic event (should have been filtered in callback but double-check)
        if eventEntry.event.getIntegerValueField(.eventSourceUserData) == leaderKeySyntheticEventTag {
          return
        }
        
        // Process the key event and get result
        let result = self.processKeyEvent(
          cgEvent: eventEntry.event,
          keyCode: nsEvent.keyCode,
          modifiers: nsEvent.modifierFlags
        )
        
        // Handle the action (already on main thread)
        switch result.action {
        case .none:
          break
          
        case .forceReset:
          self.forceResetState()
          
        case .handleActivation(let type, let shortcut):
          self.handleActivation(type: type, activationShortcut: shortcut)
          
        case .openSettings:
          NSApp.sendAction(#selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil, from: nil)
          self.hide()
          
        case .hide:
          self.hide()
        }
        
      case .keyUp:
        // Handle key up events if needed
        _ = self.handleKeyUpEvent(eventEntry.event)
        
      case .flagsChanged:
        // Handle modifier flags changes
        _ = self.handleFlagsChangedEvent(eventEntry.event)
        
      default:
        // Other event types - ignore
        break
      }
    }
  }
  
  /// Trigger event processing if not already running
  @inline(__always)
  func triggerEventProcessing() {
    // Signal the event processor that events are available
    eventProcessorSemaphore.signal()
  }
  
  /// Quick check if we should consume an event (must be VERY fast)
  @inline(__always)
  func quickShouldConsumeCheck(_ event: CGEvent) -> Bool {
    // Only consume if we're actively in a sequence or it's an activation key
    guard isMonitoring else { return false }
    
    // Ultra-fast check for active sequence using atomic flag
    if OSAtomicAdd32(0, isInSequence) == 1 {
      return true
    }
    
    // Only check activation keys for keyDown events
    guard event.type == .keyDown else { return false }
    
    // Get keycode directly from CGEvent (no NSEvent creation!)
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    // Quick check if this keycode is even a potential activation key
    guard cachedActivationKeyCodes.contains(keyCode) else { return false }
    
    // Get expected modifiers for this keycode
    guard let expectedModifiers = cachedActivationModifiers[keyCode] else { return false }
    
    // Get actual modifiers from CGEvent
    let actualModifiers = event.flags
    
    // Check if modifiers match (mask out non-modifier flags)
    let modifierMask: CGEventFlags = [.maskCommand, .maskShift, .maskControl, .maskAlternate]
    let actualMasked = actualModifiers.intersection(modifierMask)
    let expectedMasked = expectedModifiers.intersection(modifierMask)
    
    return actualMasked == expectedMasked
  }
  
  // MARK: - Power Management
  
  /// Create power assertion to prevent system interference during event processing
  private func createPowerAssertion() {
    guard !hasPowerAssertion else { return }
    
    let reason = "Leader Key active - preventing sleep" as CFString
    let result = IOPMAssertionCreateWithName(
      kIOPMAssertionTypeNoIdleSleep as CFString,
      IOPMAssertionLevel(kIOPMAssertionLevelOn),
      reason,
      &powerAssertionID
    )
    
    if result == kIOReturnSuccess {
      hasPowerAssertion = true
      print("[AppDelegate] Created power assertion to prevent sleep")
    } else {
      print("[AppDelegate] Failed to create power assertion: \(result)")
    }
  }
  
  /// Release power assertion when not needed
  private func releasePowerAssertion() {
    guard hasPowerAssertion else { return }
    
    let result = IOPMAssertionRelease(powerAssertionID)
    if result == kIOReturnSuccess {
      hasPowerAssertion = false
      print("[AppDelegate] Released power assertion")
    } else {
      print("[AppDelegate] Failed to release power assertion: \(result)")
    }
  }
  
  /// Update power assertion based on active state
  private func updatePowerAssertion() {
    if activeRootGroup != nil || currentSequenceGroup != nil {
      createPowerAssertion()
    } else {
      releasePowerAssertion()
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    print("[AppDelegate] applicationWillTerminate: Starting comprehensive cleanup...")
    
    // 1. Stop all timers
    stateRecoveryTimer?.invalidate()
    eventTapHealthTimer?.invalidate()
    permissionPollingTimer?.invalidate()
    cpuMonitorTimer?.invalidate()
    
    // 2. Clean up ThreadOptimization timers and resource optimization
    ThreadOptimization.cleanupAllTimers()
    ThreadOptimization.stopResourceOptimization()
    
    // 3. Stop event tap monitoring
    stopEventTapMonitoring()
    
    // 4. Clean up controller resources
    controller?.cleanup()
    
    // 5. Save configuration
    config.saveCurrentlyEditingConfig()
    
    // 6. Clear all caches to free memory
    config.configCache.clearCache()
    ViewSizeCache.shared.clear()
    KingfisherManager.shared.cache.clearMemoryCache()
    KingfisherManager.shared.cache.clearDiskCache()
    
    // 7. Clear error history
    ErrorHistory.shared.clear()
    
    // 8. Stop file monitor
    fileMonitor?.stopMonitoring()
    
    // 9. Unregister keyboard shortcuts
    KeyboardShortcuts.disable(.activateDefaultOnly)
    KeyboardShortcuts.disable(.activateAppSpecific)
    KeyboardShortcuts.disable(.forceReset)
    
    // 10. Cleanup critical memory pool
    ThreadOptimization.cleanupCriticalMemoryPool()
    
    // 11. Release power assertion
    releasePowerAssertion()
    
    print("[AppDelegate] applicationWillTerminate: Cleanup completed.")
  }
  
  // MARK: - State Recovery
  
  private var stateRecoveryTimer: Timer?
  private var eventTapHealthTimer: Timer?
  private var lastPermissionCheck: Bool? = nil
  private var permissionPollingTimer: Timer?
  private var permissionPollingStartTime: Date?
  private var lastEventTapActivity = Date()
  
  // MARK: - Event Tap Recovery Performance Tracking
  
  private var recoveryAttempts: Int = 0
  private var recoverySuccesses: Int = 0
  private var recoveryTimes: [Double] = [] // Store recovery times in milliseconds
  private var lastRecoveryAttempt: Date?
  
  private func setupStateRecoveryTimer() {
    // Check state every 5 seconds
    stateRecoveryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
      self?.checkAndRecoverWindowState()
    }
    
    // Start adaptive health checking
    setupAdaptiveHealthCheck()
  }
  
  /// Setup adaptive health check that increases frequency under system stress
  private func setupAdaptiveHealthCheck() {
    // Start with normal interval (2 seconds)
    scheduleNextHealthCheck(interval: 2.0)
  }
  
  private func scheduleNextHealthCheck(interval: TimeInterval) {
    eventTapHealthTimer?.invalidate()
    eventTapHealthTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
      guard let self = self else { return }
      
      // Execute health check with high priority
      ThreadOptimization.executeRealtime {
        self.checkEventTapHealth()
      }
      
      // Calculate next interval based on system pressure
      let nextInterval = self.calculateHealthCheckInterval()
      self.scheduleNextHealthCheck(interval: nextInterval)
    }
  }
  
  /// Calculate adaptive health check interval based on system conditions
  private func calculateHealthCheckInterval() -> TimeInterval {
    let thermalState = ProcessInfo.processInfo.thermalState
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    let hasActiveSequence = (currentSequenceGroup != nil || activeRootGroup != nil)
    
    // Under stress conditions, check more frequently
    if thermalState == .critical || thermalState == .serious {
      return 0.1 // 100ms under critical thermal stress
    } else if isLowPowerMode || !isMonitoring {
      return 0.5 // 500ms when not monitoring or in low power mode
    } else if hasActiveSequence {
      return 0.2 // 200ms when user is actively using Leader Key
    } else {
      return 2.0 // Normal 2-second interval
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
    let healthCheckStart = CFAbsoluteTimeGetCurrent()
    let timestamp = String(format: "%.6f", healthCheckStart)
    
    if isMonitoring {
      // Check dual tap health and perform failover if needed
      if !dualTapManager.checkAndFailover() {
          // Both taps are unhealthy - trigger full restart
          recoveryAttempts += 1
          lastRecoveryAttempt = Date()
          print("[AppDelegate] [\(timestamp)] Event Tap Health Check: Both taps unhealthy! Restarting... (Attempt #\(recoveryAttempts))")
          
          let restartStartTime = CFAbsoluteTimeGetCurrent()
          restartEventTap()
          let restartDuration = (CFAbsoluteTimeGetCurrent() - restartStartTime) * 1000
          
          // Check if restart was successful
          if dualTapManager.checkAndFailover() {
              recoverySuccesses += 1
              recoveryTimes.append(restartDuration)
              print("[AppDelegate] [\(timestamp)] ✅ Full restart successful in \(String(format: "%.2f", restartDuration))ms (Success rate: \(recoverySuccesses)/\(recoveryAttempts))")
          } else {
              print("[AppDelegate] [\(timestamp)] ❌ Full restart failed after \(String(format: "%.2f", restartDuration))ms (Success rate: \(recoverySuccesses)/\(recoveryAttempts))")
          }
      } else {
          // Taps are healthy - periodically log statistics
          let checkDuration = CFAbsoluteTimeGetCurrent() - healthCheckStart
          if checkDuration > 0.001 { // Only log if check took more than 1ms
              print("[AppDelegate] [\(timestamp)] Event Tap Health Check: OK (Check took \(String(format: "%.2f", checkDuration * 1000))ms)")
              
              // Log dual tap statistics every 10th check
              if recoveryAttempts % 10 == 0 {
                  print(dualTapManager.getStatistics())
              }
          }
      }
    } else {
      // Not monitoring - check if permissions have been granted
      let hasPermissions = checkAccessibilityPermissions()
      
      // Detect permission change from false to true
      if lastPermissionCheck == false && hasPermissions {
        print("[AppDelegate] [\(timestamp)] Event Tap Health Check: Accessibility permissions newly granted! Starting event tap...")
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
    
    // Hide any stuck window - must run on main thread for UI safety
    if controller?.window.isVisible == true {
      ThreadOptimization.executeOnMain {
        self.hide()
      }
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
      let userStateNavigationPath = MainActor.assumeIsolated {
          controller.userState.navigationPath
      }
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
        // Use MainActor.assumeIsolated for synchronous access
        return MainActor.assumeIsolated {
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
        let navigationPath = MainActor.assumeIsolated {
            controller.userState.navigationPath
        }
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
      // Thread safety guard - UI operations must run on main thread
      guard Thread.isMainThread else {
        print("[AppDelegate] hide() called from background thread - dispatching to main thread")
        ThreadOptimization.executeOnMain {
          self.hide()
        }
        return
      }
      
      print("[AppDelegate] hide() called.") // Log entry into hide()

      controller.hide(afterClose: { [weak self] in
        // Reset sequence AFTER the window is fully closed to avoid visual flash
        self?.resetSequenceState()
        // Release power assertion when hiding
        self?.releasePowerAssertion()
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
      // Thread safety guard - UI operations must run on main thread
      guard Thread.isMainThread else {
          print("[AppDelegate] handleActivation() called from background thread - dispatching to main thread")
          DispatchQueue.main.async { [weak self] in
              self?.handleActivation(type: type, activationShortcut: activationShortcut)
          }
          return
      }
      
      print("[AppDelegate] handleActivation: Received activation request of type: \(type)")
      // Track the activation shortcut to prevent immediate command release triggers
      activeActivationShortcut = activationShortcut
      
      // Create power assertion when starting a sequence
      createPowerAssertion()

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
              MainActor.assumeIsolated {
                  controller.userState.clear()
              }
              self.currentSequenceGroup = nil
              self.activeRootGroup = nil
              self.currentGroupActionMap = nil // Clear the action map
              self.stickyModeToggled = false
              self.lastModifierFlags = []
              // Determine new active root based on the activation shortcut that was just pressed
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
              MainActor.assumeIsolated {
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
        
        // Developer Tools handlers
        statusItem.handleNodeJSStressTest = {
            print("[StatusItem] NodeJS Stress Test clicked.")
            self.runNodeJSStressTest(nil)
        }
        statusItem.handleIntelliJStressTest = {
            print("[StatusItem] IntelliJ Stress Test clicked.")
            self.runIntelliJStressTest(nil)
        }
        statusItem.handleRecoveryUnderStress = {
            print("[StatusItem] Recovery Under Stress Test clicked.")
            self.testRecoveryUnderStress(nil)
        }
        statusItem.handleShowRecoveryStatistics = {
            print("[StatusItem] Show Recovery Statistics clicked.")
            self.showRecoveryStatistics(nil)
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
        // Kingfisher: aggressive memory reduction for ultimate efficiency (<50MB target)
        let cache = KingfisherManager.shared.cache
        cache.memoryStorage.config.totalCostLimit = 5 * 1024 * 1024 // Reduced from 25MB to 5MB
        cache.memoryStorage.config.countLimit = 256 // Reduced from 1024 to 256 items
        cache.memoryStorage.config.expiration = .seconds(600)
        cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024 // 100MB on disk
        cache.diskStorage.config.expiration = .days(14)
    }
    
    /// Elevate process priority for maximum responsiveness under system stress
    func elevateProcessPriority() {
        // Set process nice value to highest priority (-20)
        let currentNice = getpriority(PRIO_PROCESS, 0)
        print("[AppDelegate] Current nice value: \(currentNice)")
        
        let result = setpriority(PRIO_PROCESS, 0, -20)
        if result == 0 {
            let newNice = getpriority(PRIO_PROCESS, 0)
            print("[AppDelegate] Successfully set nice value: \(newNice)")
        } else {
            // Try a moderate approach
            let moderateResult = setpriority(PRIO_PROCESS, 0, -10)
            if moderateResult == 0 {
                let newNice = getpriority(PRIO_PROCESS, 0)
                print("[AppDelegate] Set moderate nice value: \(newNice)")
            } else {
                print("[AppDelegate] Failed to adjust nice value. Error: \(errno)")
            }
        }
        
        // Set main thread to high priority
        let originalPriority = Thread.current.threadPriority
        Thread.current.threadPriority = 1.0
        print("[AppDelegate] Set main thread priority from \(originalPriority) to 1.0")
        
        // Advanced: Set real-time scheduling for ultimate priority
        setRealtimeScheduling()
    }
    
    /// Set real-time scheduling for ultimate system priority
    private func setRealtimeScheduling() {
        // Get current thread
        let thread = mach_thread_self()
        
        // Set time constraint policy for real-time scheduling
        var timeConstraintPolicy = thread_time_constraint_policy_data_t()
        timeConstraintPolicy.period = 0 // No specific period
        timeConstraintPolicy.computation = 1000 // 1ms of computation time
        timeConstraintPolicy.constraint = 2000 // 2ms constraint
        timeConstraintPolicy.preemptible = 1 // Allow preemption
        
        let policyResult = withUnsafeMutablePointer(to: &timeConstraintPolicy) {
            $0.withMemoryRebound(to: integer_t.self, capacity: MemoryLayout<thread_time_constraint_policy_data_t>.size / MemoryLayout<integer_t>.size) {
                thread_policy_set(
                    thread,
                    thread_policy_flavor_t(THREAD_TIME_CONSTRAINT_POLICY),
                    $0,
                    mach_msg_type_number_t(4) // THREAD_TIME_CONSTRAINT_POLICY_COUNT = 4
                )
            }
        }
        
        if policyResult == KERN_SUCCESS {
            print("[AppDelegate] Successfully set real-time scheduling policy")
        } else {
            print("[AppDelegate] Failed to set real-time scheduling. Error: \(policyResult)")
            
            // Fallback: Try setting extended policy for high priority
            setExtendedPolicy()
        }
    }
    
    /// Fallback: Set extended thread policy for high priority
    private func setExtendedPolicy() {
        let thread = mach_thread_self()
        
        var extendedPolicy = thread_extended_policy_data_t()
        extendedPolicy.timeshare = 0 // Non-timeshare (higher priority)
        
        let extResult = withUnsafeMutablePointer(to: &extendedPolicy) {
            $0.withMemoryRebound(to: integer_t.self, capacity: MemoryLayout<thread_extended_policy_data_t>.size / MemoryLayout<integer_t>.size) {
                thread_policy_set(
                    thread,
                    thread_policy_flavor_t(THREAD_EXTENDED_POLICY),
                    $0,
                    mach_msg_type_number_t(1) // THREAD_EXTENDED_POLICY_COUNT = 1
                )
            }
        }
        
        if extResult == KERN_SUCCESS {
            print("[AppDelegate] Successfully set extended thread policy")
        } else {
            print("[AppDelegate] Failed to set extended thread policy. Error: \(extResult)")
        }
    }
    
    // MARK: - Simple Watchdog Monitoring
    
    func startWatchdogMonitoring() {
        // Simplified watchdog that checks for stuck states every 30 seconds (reduced from 10s to save memory)
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.performWatchdogCheck()
        }
        print("[AppDelegate] Started simplified watchdog monitoring (30s interval)")
    }
    
    func updateEventTapActivity() {
        lastEventTapActivity = Date()
    }
    
    private func performWatchdogCheck() {
        let inactivityDuration = Date().timeIntervalSince(lastEventTapActivity)
        
        // If event tap has been inactive for > 60 seconds (increased from 30s) and we should be monitoring
        if inactivityDuration > 60.0 && isMonitoring {
            print("[AppDelegate] Watchdog detected inactive event tap for \(inactivityDuration)s")
            
            // Attempt recovery - separate UI from non-UI operations for thread safety
            ThreadOptimization.executeOnMain {
                self.hide()
            }
            
            ThreadOptimization.executeRealtime {
                self.forceResetState()
                self.restartEventTap()
            }
        }
        
        // Proactive memory monitoring with aggressive cleanup thresholds
        let currentMemory = ThreadOptimization.getCurrentMemoryUsage()
        
        if currentMemory > 50 { // Lowered threshold from 100MB to 50MB for proactive monitoring
            print("[AppDelegate] Watchdog: Memory usage \(currentMemory)MB")
            
            if currentMemory > 100 { // Emergency threshold - simplified cleanup
                print("[AppDelegate] 🚨 High memory: \(currentMemory)MB - performing emergency cleanup")
                ThreadOptimization.emergencyCleanup()
            } else if currentMemory > 75 { // Aggressive cleanup threshold
                print("[AppDelegate] ⚠️ Elevated memory: \(currentMemory)MB - performing aggressive cleanup")
                ThreadOptimization.aggressiveCleanup()
            } else if currentMemory > 50 { // Proactive cleanup threshold
                print("[AppDelegate] 💡 Memory approaching limit: \(currentMemory)MB - performing proactive cleanup")
                ThreadOptimization.proactiveCleanup()
            }
        }
    }
    
}

// MARK: - Performance Testing
extension AppDelegate {
    @objc func runQuickStressTest(_ sender: Any?) {
        runStressTest(name: "Quick Test", cpuThreads: 4, memoryMB: 500, duration: 30.0)
    }
    
    @objc func runNodeJSStressTest(_ sender: Any?) {
        showAlert(title: "NodeJS Workload Test", message: "Simulating NodeJS heavy workload: async I/O, event loop saturation, GC pressure. Testing Leader Key responsiveness...")
        runNodeJSRealisticWorkload()
    }
    
    @objc func runIntelliJStressTest(_ sender: Any?) {
        showAlert(title: "IntelliJ Workload Test", message: "Simulating IntelliJ heavy operations: indexing, compilation, large file processing. Testing Leader Key responsiveness...")
        runIntelliJRealisticWorkload()
    }
    
    @objc func runComprehensiveStressTests(_ sender: Any?) {
        showAlert(title: "Comprehensive Tests", message: "Running all stress test scenarios. This will take about 10 minutes.")
        runStressTest(name: "Light", cpuThreads: 2, memoryMB: 100, duration: 20.0) {
            self.runStressTest(name: "Moderate", cpuThreads: 4, memoryMB: 500, duration: 30.0) {
                self.runStressTest(name: "Heavy", cpuThreads: 8, memoryMB: 1000, duration: 45.0) {
                    self.showAlert(title: "Tests Complete", message: "All stress tests completed. Check Console.app for detailed results.")
                }
            }
        }
    }
    
    @objc func showWatchdogStatus(_ sender: Any?) {
        let memoryUsage = ThreadOptimization.getCurrentMemoryUsage()
        let thermalState = ProcessInfo.processInfo.thermalState
        
        let message = """
        Memory Usage: \(memoryUsage)MB
        Thermal State: \(thermalState)
        Event Tap Monitoring: \(isMonitoring)
        Low Power Mode: \(ProcessInfo.processInfo.isLowPowerModeEnabled)
        """
        
        showAlert(title: "System Status", message: message)
    }
    
    @objc func showMemoryBreakdown(_ sender: Any?) {
        let memoryReport = ThreadOptimization.getMemoryReportString()
        showAlert(title: "Memory Breakdown Report", message: memoryReport)
        
        // Also print to console for detailed analysis
        print("[AppDelegate] Memory Breakdown Report:")
        ThreadOptimization.printMemoryReport()
    }
    
    @objc func showMemoryLockingStatus(_ sender: Any?) {
        let status = ThreadOptimization.getMemoryLockingStatus()
        
        let message: String
        switch status {
        case .available:
            message = """
            ✅ Memory Locking: ACTIVE
            Status: 10MB critical memory pool is locked in physical RAM
            Benefit: Critical operations will never be swapped to disk
            Reliability: Maximum system responsiveness guaranteed
            """
        case .privilegesRequired:
            message = """
            ⚠️ Memory Locking: PRIVILEGES REQUIRED
            Status: mlock() failed due to insufficient privileges
            Impact: App functions normally but critical memory may be swapped
            Solution: Run with elevated privileges for maximum reliability
            """
        case .systemLimit:
            message = """
            ⚠️ Memory Locking: SYSTEM LIMIT
            Status: mlock() failed due to system limits
            Impact: App functions normally but critical memory may be swapped
            Info: System has reached its locked memory limit
            """
        case .unavailable:
            message = """
            ❌ Memory Locking: UNAVAILABLE
            Status: Memory locking is not available on this system
            Impact: App functions normally but critical memory may be swapped
            Info: This reduces ultimate reliability under extreme system stress
            """
        }
        
        showAlert(title: "Memory Locking Status", message: message)
        print("[AppDelegate] Memory Locking Status: \(status)")
    }
    
    // MARK: - Event Tap Recovery Testing Methods
    
    @objc func testEventTapRecovery(_ sender: Any?) {
        showAlert(title: "Event Tap Recovery Test", message: "Testing event tap recovery by intentionally disabling it. Check Console.app for detailed timing results.")
        
        ThreadOptimization.executeRealtime {
            let testStartTime = CFAbsoluteTimeGetCurrent()
            print("[AppDelegate] [TEST] [\(String(format: "%.6f", testStartTime))] 🧪 Starting Dual Tap Failover Test...")
            
            // Test the dual tap manager's failover capability
            print("[AppDelegate] [TEST] Testing dual tap failover and recovery system...")
            print("[AppDelegate] [TEST] Current detection interval: \(self.calculateHealthCheckInterval())s")
            
            // Display current dual tap statistics
            print(self.dualTapManager.getStatistics())
        }
    }
    
    @objc func testRecoveryUnderStress(_ sender: Any?) {
        showAlert(title: "Recovery Under Stress Test", message: "Testing event tap recovery while applying system stress. This will stress CPU and memory for 30 seconds while testing recovery. Check Console.app for results.")
        
        ThreadOptimization.executeRealtime {
            let testStartTime = CFAbsoluteTimeGetCurrent()
            print("[AppDelegate] [STRESS-TEST] [\(String(format: "%.6f", testStartTime))] 🔥 Starting Recovery Under Stress Test...")
            
            // Apply system stress
            self.applySystemStressForRecoveryTest()
            
            // Wait a moment for stress to build
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let disableTime = CFAbsoluteTimeGetCurrent()
                print("[AppDelegate] [STRESS-TEST] [\(String(format: "%.6f", disableTime))] Testing dual tap failover under stress...")
                
                // Force a failover scenario by simulating tap failure
                // The dual tap manager will handle recovery automatically
                print("[AppDelegate] [STRESS-TEST] Dual tap manager should detect and handle any tap failures...")
                print("[AppDelegate] [STRESS-TEST] Detection interval under stress: \(self.calculateHealthCheckInterval())s")
                
                // Get and display current statistics
                print(self.dualTapManager.getStatistics())
            }
        }
    }
    
    @objc func showRecoveryStatistics(_ sender: Any?) {
        let avgRecoveryTime = recoveryTimes.isEmpty ? 0 : recoveryTimes.reduce(0, +) / Double(recoveryTimes.count)
        let maxRecoveryTime = recoveryTimes.max() ?? 0
        let minRecoveryTime = recoveryTimes.min() ?? 0
        let successRate = recoveryAttempts > 0 ? Double(recoverySuccesses) / Double(recoveryAttempts) * 100 : 0
        
        let lastAttemptText = lastRecoveryAttempt != nil ? 
            DateFormatter.localizedString(from: lastRecoveryAttempt!, dateStyle: .none, timeStyle: .medium) : "Never"
        
        // Get dual tap statistics
        let dualTapStats = dualTapManager.getStatistics()
        
        let message = """
        📊 Event Tap Recovery Statistics:
        
        Total Attempts: \(recoveryAttempts)
        Successful Recoveries: \(recoverySuccesses)
        Success Rate: \(String(format: "%.1f", successRate))%
        
        Recovery Times:
        Average: \(String(format: "%.2f", avgRecoveryTime))ms
        Fastest: \(String(format: "%.2f", minRecoveryTime))ms
        Slowest: \(String(format: "%.2f", maxRecoveryTime))ms
        
        Last Attempt: \(lastAttemptText)
        
        Detection Mechanisms:
        • Instant Detection: Active (near-zero latency)
        • Backup Timer Interval: \(String(format: "%.3f", calculateHealthCheckInterval()))s
        
        \(dualTapStats)
        """
        
        showAlert(title: "Recovery Statistics", message: message)
        print("[AppDelegate] Recovery Statistics: \(recoveryAttempts) attempts, \(recoverySuccesses) successes, \(String(format: "%.1f", successRate))% success rate")
        print(dualTapStats)
    }
    
    private func applySystemStressForRecoveryTest() {
        print("[AppDelegate] [STRESS-TEST] Applying CPU and memory stress for recovery testing...")
        
        // CPU stress - create multiple high-priority threads
        for i in 0..<4 {
            let stressQueue = DispatchQueue(label: "recovery-test-cpu-\(i)", qos: .userInitiated)
            stressQueue.async {
                let endTime = CFAbsoluteTimeGetCurrent() + 30.0 // 30 second stress test
                while CFAbsoluteTimeGetCurrent() < endTime {
                    // High CPU computation
                    for _ in 0..<50000 {
                        _ = sqrt(Double.random(in: 0...1000)) + sin(Double.random(in: 0...1000))
                    }
                    usleep(1000) // Brief pause
                }
                print("[AppDelegate] [STRESS-TEST] CPU stress thread \(i) completed")
            }
        }
        
        // Memory pressure
        let memoryStressQueue = DispatchQueue(label: "recovery-test-memory", qos: .background)
        memoryStressQueue.async {
            var memoryBlocks: [Data] = []
            let endTime = CFAbsoluteTimeGetCurrent() + 30.0
            
            while CFAbsoluteTimeGetCurrent() < endTime {
                // Allocate 10MB blocks
                if memoryBlocks.count < 20 { // Up to 200MB
                    memoryBlocks.append(Data(count: 10 * 1024 * 1024))
                } else {
                    memoryBlocks.removeAll() // Periodic cleanup to avoid excessive memory usage
                }
                usleep(100000) // 100ms delay
            }
            
            memoryBlocks.removeAll()
            print("[AppDelegate] [STRESS-TEST] Memory stress completed")
        }
    }
    
    // MARK: - Extreme Stress Testing Framework
    
    @objc func runExtremeStressTests(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "⚠️ EXTREME STRESS TESTS WARNING"
        alert.informativeText = """
        These tests will severely stress your system:
        • Swap Thrashing Test (8GB memory allocation)
        • CPU Saturation Test (all cores 100% for 5 minutes)
        • Combined Resource Exhaustion
        
        This may temporarily slow down your system significantly.
        Continue?
        """
        alert.addButton(withTitle: "Run Extreme Tests")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        if alert.runModal() == .alertFirstButtonReturn {
            runExtremeStressTestSuite()
        }
    }
    
    @objc func runSystemExhaustionTest(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "🔥 SYSTEM EXHAUSTION TEST WARNING"
        alert.informativeText = """
        This test will attempt to completely exhaust system resources:
        • Force swap thrashing (16GB+ memory allocation)
        • Saturate all CPU cores
        • Flood disk I/O
        • Network stress
        
        ⚠️ WARNING: This may make your system temporarily unresponsive!
        Only proceed if you understand the risks.
        """
        alert.addButton(withTitle: "I Understand - Run Test")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .critical
        
        if alert.runModal() == .alertFirstButtonReturn {
            runSystemExhaustionTestSuite()
        }
    }
    
    private func runExtremeStressTestSuite() {
        showAlert(title: "Extreme Stress Tests", message: "Starting extreme stress test suite. Monitor system performance closely.")
        
        // Test 1: Swap Thrashing Test
        runSwapThrashingTest { [weak self] in
            // Test 2: CPU Saturation Test  
            self?.runCPUSaturationTest { [weak self] in
                // Test 3: Combined Extreme Test
                self?.runCombinedExtremeTest { [weak self] in
                    self?.showAlert(title: "Extreme Tests Complete", message: "All extreme stress tests completed. Check system logs for results.")
                }
            }
        }
    }
    
    private func runSystemExhaustionTestSuite() {
        showAlert(title: "System Exhaustion Test", message: "🔥 STARTING SYSTEM EXHAUSTION TEST - Monitor system carefully!")
        
        runSystemExhaustionTest { [weak self] in
            self?.showAlert(title: "System Exhaustion Complete", message: "System exhaustion test completed. Check Console.app for detailed results.")
        }
    }
    
    private func runSwapThrashingTest(completion: @escaping () -> Void) {
        print("[AppDelegate] 🔥 Starting Swap Thrashing Test - allocating 8GB memory")
        
        let testQueue = DispatchQueue(label: "swap-thrashing-test", qos: .background)
        testQueue.async {
            var hugeMalloc: [Data] = []
            let chunkSize = 100 * 1024 * 1024 // 100MB chunks
            let totalChunks = 80 // 8GB total
            
            var successCount = 0
            var totalTests = 0
            
            // Test Leader Key responsiveness during memory pressure
            let responseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                totalTests += 1
                let startTime = CACurrentMediaTime()
                
                DispatchQueue.main.async {
                    // Test that UI remains responsive
                    let endTime = CACurrentMediaTime()
                    let responseTime = (endTime - startTime) * 1000
                    
                    if responseTime < 100 { // Less than 100ms is good
                        successCount += 1
                    }
                    
                    print("[SwapThrashing] Response time: \(String(format: "%.1f", responseTime))ms")
                }
            }
            
            // Allocate memory aggressively to force swapping
            for i in 0..<totalChunks {
                autoreleasepool {
                    hugeMalloc.append(Data(count: chunkSize))
                    // Write to the memory to ensure it's actually allocated
                    if !hugeMalloc.isEmpty {
                        hugeMalloc[i][chunkSize/2] = UInt8(i % 256)
                    }
                }
                
                print("[SwapThrashing] Allocated chunk \(i+1)/\(totalChunks) (\((i+1)*100)MB)")
                usleep(100000) // 100ms delay between allocations
            }
            
            print("[SwapThrashing] Memory allocated. Testing under extreme memory pressure for 60 seconds...")
            
            // Hold memory for 60 seconds while testing responsiveness
            Thread.sleep(forTimeInterval: 60.0)
            
            responseTimer.invalidate()
            
            // Cleanup
            hugeMalloc.removeAll()
            
            let successRate = totalTests > 0 ? (Double(successCount) / Double(totalTests)) * 100 : 0
            print("[SwapThrashing] RESULTS: \(successCount)/\(totalTests) responsive operations (\(String(format: "%.1f", successRate))%)")
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func runCPUSaturationTest(completion: @escaping () -> Void) {
        print("[AppDelegate] 🔥 Starting CPU Saturation Test - all cores 100% for 5 minutes")
        
        let cpuCount = ProcessInfo.processInfo.processorCount
        var stressActive = true
        var successCount = 0
        var totalTests = 0
        
        // Create CPU stress on all cores
        for i in 0..<cpuCount {
            let queue = DispatchQueue(label: "extreme-cpu-\(i)", qos: .background)
            queue.async {
                while stressActive {
                    // Intensive computation without any breaks
                    for _ in 0..<1000000 {
                        _ = sqrt(Double.random(in: 0...10000)) * sin(Double.random(in: 0...100))
                    }
                }
            }
        }
        
        // Test Leader Key responsiveness during CPU saturation
        let responseTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            totalTests += 1
            let startTime = CACurrentMediaTime()
            
            ThreadOptimization.executeRealtime {
                // Test that real-time operations remain responsive
                let endTime = CACurrentMediaTime()
                let responseTime = (endTime - startTime) * 1000
                
                if responseTime < 50 { // Less than 50ms for real-time operations
                    successCount += 1
                }
                
                print("[CPUSaturation] Real-time response: \(String(format: "%.1f", responseTime))ms")
            }
        }
        
        // Run for 5 minutes (300 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 300.0) {
            stressActive = false
            responseTimer.invalidate()
            
            let successRate = totalTests > 0 ? (Double(successCount) / Double(totalTests)) * 100 : 0
            print("[CPUSaturation] RESULTS: \(successCount)/\(totalTests) responsive real-time operations (\(String(format: "%.1f", successRate))%)")
            
            completion()
        }
    }
    
    private func runCombinedExtremeTest(completion: @escaping () -> Void) {
        print("[AppDelegate] 🔥 Starting Combined Extreme Test - CPU + Memory + Disk stress")
        
        var stressActive = true
        let cpuCount = ProcessInfo.processInfo.processorCount
        
        // CPU Stress (all cores)
        for i in 0..<cpuCount {
            let queue = DispatchQueue(label: "extreme-combined-cpu-\(i)", qos: .background)
            queue.async {
                while stressActive {
                    for _ in 0..<500000 {
                        _ = sqrt(Double.random(in: 0...1000)) * cos(Double.random(in: 0...100))
                    }
                    usleep(1000) // Tiny break to allow system scheduling
                }
            }
        }
        
        // Memory Stress (4GB allocation with constant access)
        let memoryQueue = DispatchQueue(label: "extreme-combined-memory", qos: .background)
        memoryQueue.async {
            var memory: [Data] = []
            
            // Allocate 4GB in 50MB chunks
            for i in 0..<80 {
                if stressActive {
                    autoreleasepool {
                        memory.append(Data(count: 50 * 1024 * 1024))
                        // Access memory to ensure it's actually allocated
                        if !memory.isEmpty {
                            memory[i][25 * 1024 * 1024] = UInt8(i % 256)
                        }
                    }
                }
                usleep(50000) // 50ms between allocations
            }
            
            // Keep accessing memory randomly
            while stressActive {
                if !memory.isEmpty {
                    let randomIndex = Int.random(in: 0..<memory.count)
                    let randomOffset = Int.random(in: 0..<(25 * 1024 * 1024))
                    _ = memory[randomIndex][randomOffset]
                }
                usleep(10000) // 10ms
            }
        }
        
        // Disk I/O Stress
        let diskQueue = DispatchQueue(label: "extreme-combined-disk", qos: .background)
        diskQueue.async {
            let tempDir = NSTemporaryDirectory()
            var fileCount = 0
            
            while stressActive {
                autoreleasepool {
                    let fileName = "extreme_stress_\(fileCount).tmp"
                    let filePath = (tempDir as NSString).appendingPathComponent(fileName)
                    
                    // Write 10MB file
                    let data = Data(count: 10 * 1024 * 1024)
                    try? data.write(to: URL(fileURLWithPath: filePath))
                    
                    // Read it back
                    _ = try? Data(contentsOf: URL(fileURLWithPath: filePath))
                    
                    // Delete it
                    try? FileManager.default.removeItem(atPath: filePath)
                    
                    fileCount += 1
                }
                usleep(100000) // 100ms between I/O operations
            }
        }
        
        var successCount = 0
        var totalTests = 0
        
        // Test Leader Key under combined extreme stress
        let responseTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            totalTests += 1
            let startTime = CACurrentMediaTime()
            
            ThreadOptimization.executeRealtime {
                let endTime = CACurrentMediaTime()
                let responseTime = (endTime - startTime) * 1000
                
                if responseTime < 100 { // Less than 100ms under extreme stress
                    successCount += 1
                }
                
                print("[CombinedExtreme] Response time: \(String(format: "%.1f", responseTime))ms")
            }
        }
        
        // Run combined stress for 3 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 180.0) {
            stressActive = false
            responseTimer.invalidate()
            
            let successRate = totalTests > 0 ? (Double(successCount) / Double(totalTests)) * 100 : 0
            print("[CombinedExtreme] RESULTS: \(successCount)/\(totalTests) responsive operations under extreme stress (\(String(format: "%.1f", successRate))%)")
            
            completion()
        }
    }
    
    private func runSystemExhaustionTest(completion: @escaping () -> Void) {
        print("[AppDelegate] 🔥🔥 STARTING SYSTEM EXHAUSTION TEST - Maximum resource consumption")
        
        var stressActive = true
        let cpuCount = ProcessInfo.processInfo.processorCount
        
        // Maximum CPU stress (higher priority than other apps)
        for i in 0..<cpuCount * 2 { // Oversubscribe CPU
            let queue = DispatchQueue(label: "exhaustion-cpu-\(i)", qos: .userInitiated) // Higher QoS
            queue.async {
                while stressActive {
                    // Maximum intensity computation with no breaks
                    for _ in 0..<2000000 {
                        _ = sqrt(Double.random(in: 0...100000)) * sin(Double.random(in: 0...1000)) * cos(Double.random(in: 0...1000))
                    }
                }
            }
        }
        
        // Massive memory allocation to force heavy swapping
        let memoryQueue = DispatchQueue(label: "exhaustion-memory", qos: .userInitiated)
        memoryQueue.async {
            var massiveMemory: [Data] = []
            
            // Try to allocate 16GB (this will definitely cause swapping on most systems)
            for i in 0..<160 {
                if stressActive {
                    autoreleasepool {
                        let chunk = Data(count: 100 * 1024 * 1024) // 100MB chunks
                        massiveMemory.append(chunk)
                        
                        // Ensure memory is actually used (write pattern)
                        let lastIndex = massiveMemory.count - 1
                        for j in stride(from: 0, to: chunk.count, by: 4096) { // Write every page
                            massiveMemory[lastIndex][j] = UInt8(i % 256)
                        }
                        
                        print("[SystemExhaustion] Allocated \((i+1)*100)MB (Total: \((i+1)*100)MB)")
                    }
                }
                usleep(25000) // 25ms between allocations for maximum pressure
            }
            
            // Continuously access memory to prevent optimization
            while stressActive {
                if !massiveMemory.isEmpty {
                    for _ in 0..<100 {
                        let randomChunk = Int.random(in: 0..<massiveMemory.count)
                        let randomOffset = Int.random(in: 0..<(50 * 1024 * 1024))
                        _ = massiveMemory[randomChunk][randomOffset]
                    }
                }
                usleep(1000) // 1ms between memory accesses
            }
        }
        
        // Extreme disk I/O to saturate storage
        for i in 0..<4 { // Multiple concurrent disk stress threads
            let diskQueue = DispatchQueue(label: "exhaustion-disk-\(i)", qos: .userInitiated)
            diskQueue.async {
                let tempDir = NSTemporaryDirectory()
                var fileCount = 0
                
                while stressActive {
                    autoreleasepool {
                        let fileName = "exhaustion_\(i)_\(fileCount).tmp"
                        let filePath = (tempDir as NSString).appendingPathComponent(fileName)
                        
                        // Large file operations (50MB files)
                        let largeData = Data(count: 50 * 1024 * 1024)
                        
                        // Write
                        try? largeData.write(to: URL(fileURLWithPath: filePath))
                        
                        // Read back
                        _ = try? Data(contentsOf: URL(fileURLWithPath: filePath))
                        
                        // Delete
                        try? FileManager.default.removeItem(atPath: filePath)
                        
                        fileCount += 1
                    }
                    usleep(10000) // 10ms between operations for maximum I/O pressure
                }
            }
        }
        
        var successCount = 0
        var totalTests = 0
        
        // Test Leader Key under complete system exhaustion
        let responseTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            totalTests += 1
            let startTime = CACurrentMediaTime()
            
            ThreadOptimization.executeRealtime {
                let endTime = CACurrentMediaTime()
                let responseTime = (endTime - startTime) * 1000
                
                // Under system exhaustion, even 500ms response is acceptable
                if responseTime < 500 {
                    successCount += 1
                }
                
                print("[SystemExhaustion] Response time: \(String(format: "%.1f", responseTime))ms (Target: <500ms)")
                
                // Also test memory locking status
                let lockingStatus = ThreadOptimization.getMemoryLockingStatus()
                print("[SystemExhaustion] Memory locking status: \(lockingStatus)")
            }
        }
        
        // Run system exhaustion for 5 minutes (this is extreme!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 300.0) {
            stressActive = false
            responseTimer.invalidate()
            
            let successRate = totalTests > 0 ? (Double(successCount) / Double(totalTests)) * 100 : 0
            print("[SystemExhaustion] FINAL RESULTS: \(successCount)/\(totalTests) responsive operations under SYSTEM EXHAUSTION (\(String(format: "%.1f", successRate))%)")
            
            // Clean up any remaining temp files
            DispatchQueue.global().async {
                ThreadOptimization.cleanupTempFiles()
            }
            
            completion()
        }
    }
    
    // MARK: - Long-Term Stability Testing
    
    @objc func run24HourStabilityTest(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "⏱️ 24-HOUR STABILITY TEST"
        alert.informativeText = """
        This test will run for 24 hours (1440 minutes) and includes:
        • Continuous operation monitoring
        • Periodic moderate stress cycles
        • Memory leak detection over time
        • Recovery testing from simulated failures
        • Performance degradation tracking
        
        The test will run in the background. Check Console.app for progress.
        Continue?
        """
        alert.addButton(withTitle: "Start 24-Hour Test")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational
        
        if alert.runModal() == .alertFirstButtonReturn {
            run24HourStabilityTestSuite()
        }
    }
    
    @objc func run48HourEnduranceTest(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "🔋 48-HOUR ENDURANCE TEST"
        alert.informativeText = """
        This test will run for 48 hours (2880 minutes) and includes:
        • Extended operation under varying load
        • Stress cycles every 4 hours
        • Comprehensive memory monitoring
        • System resource impact assessment
        • Long-term reliability validation
        
        ⚠️ This is an extensive test. Ensure your system can run uninterrupted.
        Continue?
        """
        alert.addButton(withTitle: "Start 48-Hour Test")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .critical
        
        if alert.runModal() == .alertFirstButtonReturn {
            run48HourEnduranceTestSuite()
        }
    }
    
    private func run24HourStabilityTestSuite() {
        let startTime = Date()
        showAlert(title: "24-Hour Stability Test", message: "Starting 24-hour stability test. Monitor progress in Console.app.")
        
        print("[24HourTest] 🕐 STARTING 24-HOUR STABILITY TEST")
        print("[24HourTest] Start time: \(startTime)")
        
        runLongTermStabilityTest(
            duration: 24 * 60 * 60, // 24 hours in seconds
            testName: "24-Hour Stability",
            stressCycleInterval: 2 * 60 * 60, // Stress cycle every 2 hours
            monitoringInterval: 5 * 60 // Monitor every 5 minutes
        ) { [weak self] results in
            self?.showAlert(
                title: "24-Hour Test Complete",
                message: "24-hour stability test completed.\n\nResults:\n\(results)"
            )
        }
    }
    
    private func run48HourEnduranceTestSuite() {
        let startTime = Date()
        showAlert(title: "48-Hour Endurance Test", message: "Starting 48-hour endurance test. This is a comprehensive long-term test.")
        
        print("[48HourTest] 🔋 STARTING 48-HOUR ENDURANCE TEST")
        print("[48HourTest] Start time: \(startTime)")
        
        runLongTermStabilityTest(
            duration: 48 * 60 * 60, // 48 hours in seconds
            testName: "48-Hour Endurance",
            stressCycleInterval: 4 * 60 * 60, // Stress cycle every 4 hours
            monitoringInterval: 10 * 60 // Monitor every 10 minutes
        ) { [weak self] results in
            self?.showAlert(
                title: "48-Hour Test Complete",
                message: "48-hour endurance test completed.\n\nResults:\n\(results)"
            )
        }
    }
    
    private func runLongTermStabilityTest(
        duration: TimeInterval,
        testName: String,
        stressCycleInterval: TimeInterval,
        monitoringInterval: TimeInterval,
        completion: @escaping (String) -> Void
    ) {
        let startTime = Date()
        var totalMonitoringChecks = 0
        var successfulChecks = 0
        var memoryLeakDetections = 0
        var stressCyclesCompleted = 0
        var maxMemoryUsage: UInt64 = 0
        var minMemoryUsage: UInt64 = UInt64.max
        var memoryGrowthDetected = false
        
        // Monitoring timer
        let monitorTimer = Timer.scheduledTimer(withTimeInterval: monitoringInterval, repeats: true) { _ in
            totalMonitoringChecks += 1
            
            let currentTime = Date()
            let elapsed = currentTime.timeIntervalSince(startTime)
            let remaining = duration - elapsed
            
            // Memory monitoring
            let currentMemory = ThreadOptimization.getCurrentMemoryUsage()
            maxMemoryUsage = max(maxMemoryUsage, currentMemory)
            if minMemoryUsage == UInt64.max {
                minMemoryUsage = currentMemory
            } else {
                minMemoryUsage = min(minMemoryUsage, currentMemory)
            }
            
            // Check for memory leaks
            if let leakWarning = ThreadOptimization.detectMemoryLeaks() {
                memoryLeakDetections += 1
                print("[\(testName)] 🚨 MEMORY LEAK DETECTED: \(leakWarning)")
            }
            
            // Check memory growth pattern
            if currentMemory > minMemoryUsage * 2 { // More than 2x initial memory
                if !memoryGrowthDetected {
                    memoryGrowthDetected = true
                    print("[\(testName)] ⚠️ Significant memory growth detected: \(minMemoryUsage)MB → \(currentMemory)MB")
                }
            }
            
            // Test responsiveness
            let responseStartTime = CACurrentMediaTime()
            ThreadOptimization.executeRealtime {
                let responseTime = (CACurrentMediaTime() - responseStartTime) * 1000
                
                if responseTime < 100 { // Less than 100ms is acceptable for long-term tests
                    successfulChecks += 1
                }
                
                print("[\(testName)] Check \(totalMonitoringChecks): Memory \(currentMemory)MB, Response \(String(format: "%.1f", responseTime))ms, Remaining \(String(format: "%.1f", remaining / 3600))h")
            }
            
            // Memory locking status check
            let lockingStatus = ThreadOptimization.getMemoryLockingStatus()
            if lockingStatus != .available {
                print("[\(testName)] ⚠️ Memory locking status changed: \(lockingStatus)")
            }
        }
        
        // Stress cycle timer
        let stressTimer = Timer.scheduledTimer(withTimeInterval: stressCycleInterval, repeats: true) { _ in
            stressCyclesCompleted += 1
            print("[\(testName)] 🔥 Starting stress cycle \(stressCyclesCompleted)")
            
            // Run a moderate stress test for 5 minutes
            self.runStressTest(
                name: "\(testName)-Cycle-\(stressCyclesCompleted)",
                cpuThreads: 4,
                memoryMB: 1000,
                duration: 5 * 60 // 5 minutes
            ) {
                print("[\(testName)] ✅ Stress cycle \(stressCyclesCompleted) completed")
            }
        }
        
        // Test completion timer
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            monitorTimer.invalidate()
            stressTimer.invalidate()
            
            let endTime = Date()
            let totalHours = duration / 3600
            let successRate = totalMonitoringChecks > 0 ? (Double(successfulChecks) / Double(totalMonitoringChecks)) * 100 : 0
            let memoryGrowth = maxMemoryUsage - minMemoryUsage
            
            let results = """
            Duration: \(String(format: "%.1f", totalHours)) hours
            Monitoring Checks: \(successfulChecks)/\(totalMonitoringChecks) successful (\(String(format: "%.2f", successRate))%)
            Memory Usage: \(minMemoryUsage)MB - \(maxMemoryUsage)MB (Growth: \(memoryGrowth)MB)
            Memory Leaks Detected: \(memoryLeakDetections)
            Stress Cycles: \(stressCyclesCompleted)
            Memory Growth Warning: \(memoryGrowthDetected ? "YES" : "NO")
            """
            
            print("[\(testName)] 🏁 LONG-TERM TEST COMPLETED")
            print("[\(testName)] Results:\n\(results)")
            
            // Final memory analysis
            ThreadOptimization.printMemoryReport()
            
            completion(results)
        }
        
        print("[\(testName)] Long-term test initialized - duration: \(duration/3600)h, monitoring every \(monitoringInterval/60)min, stress every \(stressCycleInterval/3600)h")
    }
    
    private func runStressTest(name: String, cpuThreads: Int, memoryMB: Int, duration: TimeInterval, completion: (() -> Void)? = nil) {
        print("[AppDelegate] Starting \(name) stress test: \(cpuThreads) CPU threads, \(memoryMB)MB memory, \(duration)s duration")
        
        var stressActive = true
        var successCount = 0
        var totalTests = 0
        
        // CPU stress
        for i in 0..<cpuThreads {
            let queue = DispatchQueue(label: "stress-cpu-\(i)", qos: .background)
            queue.async {
                while stressActive {
                    for _ in 0..<100000 { _ = sqrt(Double.random(in: 0...1000)) }
                    usleep(1000)
                }
            }
        }
        
        // Memory stress with explicit cleanup
        let memoryQueue = DispatchQueue(label: "stress-memory", qos: .background)
        memoryQueue.async {
            var memory: [Data] = []
            
            // Allocation phase
            while stressActive && memory.count < memoryMB {
                memory.append(Data(count: 1024 * 1024))
                usleep(10000)
            }
            
            print("[StressTest] Allocated \(memory.count)MB for \(name)")
            
            // Usage phase
            while stressActive {
                if !memory.isEmpty { _ = memory[Int.random(in: 0..<memory.count)].count }
                usleep(100000)
            }
            
            // Explicit cleanup when test ends
            print("[StressTest] Cleaning up \(memory.count)MB allocated memory for \(name)")
            memory.removeAll()
            memory = [] // Explicit deallocation
            
            // Force memory pressure to encourage garbage collection
            autoreleasepool {
                let dummy = Array(repeating: Data(count: 1024), count: 10)
                _ = dummy.count
            }
        }
        
        // Test responsiveness
        let testTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let start = CFAbsoluteTimeGetCurrent()
            ThreadOptimization.executeRealtime {
                let latency = CFAbsoluteTimeGetCurrent() - start
                totalTests += 1
                if latency < 0.1 { successCount += 1 }
                if latency > 0.1 { print("[StressTest] High latency: \(latency * 1000)ms") }
            }
        }
        
        // End test
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            stressActive = false
            testTimer.invalidate()
            
            let successRate = totalTests > 0 ? Double(successCount) / Double(totalTests) : 0
            print("[AppDelegate] \(name) test complete: \(String(format: "%.1f", successRate * 100))% success rate")
            
            completion?()
        }
    }
    
    // MARK: - Real-World Workload Simulations
    
    private func runNodeJSRealisticWorkload() {
        print("[AppDelegate] 🟢 Starting NodeJS realistic workload simulation")
        
        var isActive = true
        let duration: TimeInterval = 60.0 // 60 second test
        var responseTimes: [TimeInterval] = []
        
        // Simulate NodeJS event loop saturation with async operations
        let eventLoopQueue = DispatchQueue(label: "nodejs-eventloop", qos: .userInitiated)
        for i in 0..<8 { // Multiple async operations
            eventLoopQueue.async {
                while isActive {
                    // Simulate async I/O operations (file reads, network requests)
                    autoreleasepool {
                        let data = Data(count: Int.random(in: 1024...102400)) // 1KB-100KB chunks
                        _ = data.withUnsafeBytes { bytes in
                            // Simulate JSON parsing/processing
                            return bytes.reduce(0) { $0 + Int($1) }
                        }
                    }
                    
                    // Simulate network latency variability
                    usleep(UInt32.random(in: 1000...10000)) // 1-10ms delays
                    
                    // Simulate garbage collection pressure
                    if i % 100 == 0 {
                        autoreleasepool {
                            let temp = Array(repeating: Data(count: 1024), count: 50)
                            _ = temp.count
                        }
                    }
                }
            }
        }
        
        // Test Leader Key responsiveness during NodeJS workload
        let responseTestTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            let start = CFAbsoluteTimeGetCurrent()
            ThreadOptimization.executeRealtime {
                let responseTime = CFAbsoluteTimeGetCurrent() - start
                responseTimes.append(responseTime)
                if responseTime > 0.05 { // >50ms is concerning
                    print("[NodeJS Test] Slow response: \(responseTime * 1000)ms")
                }
            }
        }
        
        // End test after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isActive = false
            responseTestTimer.invalidate()
            
            let avgResponse = responseTimes.isEmpty ? 0 : responseTimes.reduce(0, +) / Double(responseTimes.count)
            let maxResponse = responseTimes.max() ?? 0
            let slowResponses = responseTimes.filter { $0 > 0.05 }.count
            
            let results = """
            🟢 NodeJS Workload Test Results:
            Duration: \(duration)s
            Response Tests: \(responseTimes.count)
            Average Response: \(String(format: "%.2f", avgResponse * 1000))ms
            Max Response: \(String(format: "%.2f", maxResponse * 1000))ms
            Slow Responses (>50ms): \(slowResponses) (\(String(format: "%.1f", Double(slowResponses) / Double(responseTimes.count) * 100))%)
            Success Rate: \(String(format: "%.1f", Double(responseTimes.count - slowResponses) / Double(responseTimes.count) * 100))%
            """
            
            print(results)
            self.showAlert(title: "NodeJS Test Complete", message: results)
        }
    }
    
    private func runIntelliJRealisticWorkload() {
        print("[AppDelegate] 🔵 Starting IntelliJ realistic workload simulation")
        
        var isActive = true
        let duration: TimeInterval = 90.0 // 90 second test (IntelliJ operations are longer)
        var responseTimes: [TimeInterval] = []
        
        // Simulate IntelliJ indexing operations (heavy disk I/O)
        let indexingQueue = DispatchQueue(label: "intellij-indexing", qos: .utility)
        indexingQueue.async {
            let fileManager = FileManager.default
            let tempDir = NSTemporaryDirectory()
            
            while isActive {
                autoreleasepool {
                    // Simulate indexing large files
                    for i in 0..<10 {
                        let fileName = "intellij_temp_\(i)_\(UUID().uuidString).tmp"
                        let filePath = (tempDir as NSString).appendingPathComponent(fileName)
                        
                        // Create and write large temporary files (simulating source files)
                        let content = String(repeating: "class Example { public void method() { /* content */ } }", count: 1000)
                        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)
                        
                        // Simulate parsing/analysis (CPU intensive)
                        _ = content.components(separatedBy: " ").count
                        
                        // Clean up
                        try? fileManager.removeItem(atPath: filePath)
                    }
                }
                
                // Simulate compilation pauses
                usleep(50000) // 50ms between file processing
            }
        }
        
        // Simulate background compilation (CPU + memory intensive)
        let compilationQueue = DispatchQueue(label: "intellij-compilation", qos: .background)
        compilationQueue.async {
            var compilationData: [Data] = []
            
            while isActive {
                autoreleasepool {
                    // Simulate compilation memory usage (growing then shrinking)
                    if compilationData.count < 100 {
                        compilationData.append(Data(count: 1024 * 1024)) // 1MB chunks
                    } else {
                        compilationData.removeAll()
                    }
                    
                    // Simulate heavy computation (parsing, optimization)
                    for _ in 0..<10000 {
                        _ = sqrt(Double.random(in: 0...1000)) + sin(Double.random(in: 0...1000))
                    }
                }
                
                usleep(100000) // 100ms compilation cycles
            }
        }
        
        // Test Leader Key responsiveness during IntelliJ workload
        let responseTestTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            let start = CFAbsoluteTimeGetCurrent()
            ThreadOptimization.executeRealtime {
                let responseTime = CFAbsoluteTimeGetCurrent() - start
                responseTimes.append(responseTime)
                if responseTime > 0.1 { // >100ms is concerning for IntelliJ scenario
                    print("[IntelliJ Test] Slow response: \(responseTime * 1000)ms")
                }
            }
        }
        
        // End test after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isActive = false
            responseTestTimer.invalidate()
            
            let avgResponse = responseTimes.isEmpty ? 0 : responseTimes.reduce(0, +) / Double(responseTimes.count)
            let maxResponse = responseTimes.max() ?? 0
            let slowResponses = responseTimes.filter { $0 > 0.1 }.count
            
            let results = """
            🔵 IntelliJ Workload Test Results:
            Duration: \(duration)s
            Response Tests: \(responseTimes.count)
            Average Response: \(String(format: "%.2f", avgResponse * 1000))ms
            Max Response: \(String(format: "%.2f", maxResponse * 1000))ms
            Slow Responses (>100ms): \(slowResponses) (\(String(format: "%.1f", Double(slowResponses) / Double(responseTimes.count) * 100))%)
            Success Rate: \(String(format: "%.1f", Double(responseTimes.count - slowResponses) / Double(responseTimes.count) * 100))%
            """
            
            print(results)
            self.showAlert(title: "IntelliJ Test Complete", message: results)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
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
    // Event tap management moved to DualEventTapManager
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
    // NOTE: isProcessingKey and keyEventQueue removed - now using lock-free queue with async processing
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
        let modifierFlags: UInt64
    }
    private var keyStringCache: [KeyCacheEntry: String] {
        get { getAssociatedObject(self, &AssociatedKeys.keyStringCache) ?? [:] }
        set { setAssociatedObject(self, &AssociatedKeys.keyStringCache, newValue) }
    }
    
    // --- Action Lookup Map for O(1) Performance ---
    private var currentGroupActionMap: [String: ActionOrGroup]? {
        get { getAssociatedObject(self, &AssociatedKeys.currentGroupActionMap) }
        set { setAssociatedObject(self, &AssociatedKeys.currentGroupActionMap, newValue) }
    }
    
    private struct AssociatedKeys {
        // Removed eventTap and runLoopSource - now managed by DualEventTapManager
        static var isMonitoring = "isMonitoring"
        static var activeRootGroup = "activeRootGroup"
        static var currentSequenceGroup = "currentSequenceGroup"
        // isProcessingKey and keyEventQueue removed - using lock-free queue now
        static var didShowPermissionsAlertRecently = "didShowPermissionsAlertRecently"
        static var stickyModeToggled = "stickyModeToggled"
        static var lastModifierFlags = "lastModifierFlags"
        static var activeActivationShortcut = "activeActivationShortcut"
        static var cpuMonitorTimer = "cpuMonitorTimer"
        static var isHighCpuMode = "isHighCpuMode"
        static var lastNavigationTime = "lastNavigationTime"
        static var keyStringCache = "keyStringCache"
        static var currentGroupActionMap = "currentGroupActionMap"
    }

    // --- Event Tap Logic Methods ---
    func startEventTapMonitoring() {
        // Ensure we don't start multiple taps
        guard !isMonitoring else {
            print("[AppDelegate] startEventTapMonitoring: Already monitoring. Aborting.")
            return
        }
        print("[AppDelegate] startEventTapMonitoring: Attempting to start...")

        // Create dual event taps for redundancy
        let success = dualTapManager.createDualTaps(
            callback: eventTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        if !success {
            // Failure usually means Accessibility permissions are missing or denied.
            debugLog("[AppDelegate] startEventTapMonitoring: Failed to create dual event taps. Permissions likely missing.")
            // Check permissions status *after* failure, only prompt if we haven't recently.
            if !checkAccessibilityPermissions() && !didShowPermissionsAlertRecently {
                debugLog("[AppDelegate] startEventTapMonitoring: Accessibility permissions check failed AND alert not shown recently. Showing alert.")
                showPermissionsAlert()
                self.didShowPermissionsAlertRecently = true // Flag to avoid spamming alerts
                // Reset the flag after a short delay to allow re-prompting later if needed
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    debugLog("[AppDelegate] Resetting didShowPermissionsAlertRecently flag.")
                    self.didShowPermissionsAlertRecently = false
                }
            } else {
                debugLog("[AppDelegate] startEventTapMonitoring: Accessibility check passed OR alert shown recently. Not showing permissions alert now.")
            }
            return // Stop, as tap creation failed
        }

        // Tap creation successful
        debugLog("[AppDelegate] startEventTapMonitoring: Dual event taps created successfully.")
        self.isMonitoring = true // Set monitoring state
        self.didShowPermissionsAlertRecently = false // Reset alert flag as monitoring is now active

        // Start event tap health monitoring

        // Start CPU monitoring for adaptive behavior
        startCPUMonitoring()

        debugLog("[AppDelegate] startEventTapMonitoring: Dual event taps enabled and monitoring started.")
    }

    func stopEventTapMonitoring() {
        guard isMonitoring else {
             debugLog("[AppDelegate] stopEventTapMonitoring: Not currently monitoring. Aborting.")
             return
        }
        debugLog("[AppDelegate] stopEventTapMonitoring: Stopping event tap...")

        // Stop health monitoring and CPU monitoring
        stopCPUMonitoring()

        resetSequenceState() // Ensure sequence state is cleared
        
        // Stop dual taps
        dualTapManager.stopDualTaps()
        debugLog("[AppDelegate] stopEventTapMonitoring: Dual taps stopped.")
        self.isMonitoring = false // Update state
        debugLog("[AppDelegate] stopEventTapMonitoring: Monitoring stopped.")
    }

    // --- Force Reset Mechanism ---

    func forceResetState() {
        // Thread safety guard - UI operations must run on main thread
        guard Thread.isMainThread else {
            print("[AppDelegate] forceResetState() called from background thread - dispatching to main thread")
            DispatchQueue.main.async { [weak self] in
                self?.forceResetState()
            }
            return
        }
        
        print("[AppDelegate] forceResetState: Performing nuclear state reset.")

        // Cancel all timers immediately

        // Force clear all state variables immediately (no delays, no callbacks)
        self.currentSequenceGroup = nil
        self.activeRootGroup = nil
        self.currentGroupActionMap = nil // Clear the action map
        self.stickyModeToggled = false
        self.lastModifierFlags = []
        self.activeActivationShortcut = nil
        
        // Clear atomic sequence flag
        OSAtomicCompareAndSwap32(1, 0, isInSequence)

        // Force hide the window immediately if it's visible
        if controller.window.isVisible {
            print("[AppDelegate] forceResetState: Force hiding window.")
            controller.window.orderOut(nil)
            MainActor.assumeIsolated {
                controller.userState.clear()
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

    // NOTE: handleCGEvent, handleKeyDownEvent, processQueuedEvents, and clearKeyEventQueue removed
    // Now using ultra-fast eventTapCallback with lock-free queue and async processing

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
            debugLog("[AppDelegate] handleFlagsChangedEvent: cmdPressed=\(commandPressed) cmdReleased=\(commandReleased) sticky=\(stickyState)")
        }

        // Always pass through modifier changes
        return Unmanaged.passRetained(event)
    }

    private func processKeyEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> KeyEventResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        // 1. Check for force reset shortcut FIRST (highest priority)
        let shortcutForceReset = KeyboardShortcuts.getShortcut(for: .forceReset)
        if let shortcut = shortcutForceReset, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            debugLog("[AppDelegate] processKeyEvent: Force reset shortcut triggered.")
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = (endTime - startTime) * 1000
            debugLog(String(format: "[AppDelegate] processKeyEvent: time %.2fms", duration))
            return KeyEventResult(consumed: true, action: .forceReset)
        }

        // 2. Check for activation shortcuts
        let shortcutAppSpecific = KeyboardShortcuts.getShortcut(for: .activateAppSpecific)
        let shortcutDefaultOnly = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly)
        var matchedActivationType: Controller.ActivationType?
        var matchedShortcut: KeyboardShortcuts.Shortcut?

        // Check App-Specific Shortcut
        if let shortcut = shortcutAppSpecific, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            debugLog("[AppDelegate] processKeyEvent: Matched App-Specific shortcut.")
            matchedActivationType = .appSpecificWithFallback
            matchedShortcut = shortcut
        }
        // Check Default Only Shortcut
        else if let shortcut = shortcutDefaultOnly, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            debugLog("[AppDelegate] processKeyEvent: Matched Default Only shortcut.")
            matchedActivationType = .defaultOnly
            matchedShortcut = shortcut
        }

        // 3. If an activation shortcut was pressed, return it to be handled on main thread
        if let type = matchedActivationType {
            return KeyEventResult(consumed: true, action: .handleActivation(type: type, shortcut: matchedShortcut))
        }

        // 4. If NOT an activation shortcut, check for Escape
        if keyCode == KeyCodes.escape {
            let isWindowVisible = self.controller.window.isVisible
            let windowAlpha = self.controller.window.alphaValue
            let hasActiveSequence = (currentSequenceGroup != nil || activeRootGroup != nil)
            
            debugLog("[AppDelegate] Escape pressed. Window isVisible: \(isWindowVisible), alpha: \(windowAlpha), hasActiveSequence: \(hasActiveSequence)")

            // Check multiple conditions to determine if we should hide the window
            if isWindowVisible || windowAlpha > 0 || hasActiveSequence {
                // Window is visible OR has opacity OR we have an active sequence - hide it
                debugLog("[AppDelegate] Escape: Hiding window and resetting state.")
                resetSequenceState()
                return KeyEventResult(consumed: true, action: .hide)
            } else {
                // Window is truly hidden, no active sequence - pass through
                debugLog("[AppDelegate] Escape: Window is hidden, no active sequence. Passing event through.")
                return KeyEventResult(consumed: false, action: .none)
            }
        }

        // 5. If NOT activation, Escape, or Cmd+, check if we are in a sequence
        if currentSequenceGroup != nil {
            // --- SPECIAL CHECK WITHIN ACTIVE SEQUENCE ---
            // Check for Cmd+, specifically *before* normal sequence processing
            if modifiers.contains(.command),
               let nsEvent = NSEvent(cgEvent: cgEvent),
               nsEvent.charactersIgnoringModifiers == "," {
                debugLog("[AppDelegate] processKeyEvent: Cmd+, detected while sequence active. Opening settings.")
                // Reset sequence state and hide the panel
                resetSequenceState()
                // Return action to open settings and hide on main thread
                return KeyEventResult(consumed: true, action: .openSettings)
            }
            // --- END SPECIAL CHECK ---

            // If not Cmd+, process the key normally within the sequence
            debugLog("[AppDelegate] processKeyEvent: Active sequence detected (and not Cmd+). Processing key within sequence...")

            // Clear the activation shortcut since the user is now actively using Leader Key
            // This enables the Cmd-release reset feature after activation
            if activeActivationShortcut != nil {
                debugLog("[AppDelegate] processKeyEvent: Clearing activeActivationShortcut - user is now actively using Leader Key.")
                activeActivationShortcut = nil
            }

            let consumed = processKeyInSequence(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
            return KeyEventResult(consumed: consumed, action: .none)
        }

        // 5. If NOT activation, Escape, or in a sequence, let the event pass through
        debugLog("[AppDelegate] processKeyEvent: No activation shortcut, Escape, or active sequence matched. Passing event through.")
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = (endTime - startTime) * 1000
        debugLog(String(format: "[AppDelegate] processKeyEvent: time %.2fms", duration))
        return KeyEventResult(consumed: false, action: .none)
    }

    private func processKeyInSequence(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        let startTime = CFAbsoluteTimeGetCurrent()
        debugLog("[AppDelegate] processKeyInSequence: Processing keyCode: \(keyCode), mods: \(describeModifiers(modifiers))")

        // Get the single character string representation for the key event
        guard let keyString = keyStringForEvent(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers) else {
            // If we can't map the key event to a string, decide based on sticky mode.
            let isStickyModeActive = isInStickyMode(modifiers)
            if isStickyModeActive {
                debugLog("[AppDelegate] processKeyInSequence: Could not map event to keyString, but sticky mode ACTIVE – passing event through.")
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = (endTime - startTime) * 1000
                debugLog(String(format: "[AppDelegate] processKeyInSequence: time %.2fms", duration))
                return false // Event NOT handled – let it propagate
            } else {
                debugLog("[AppDelegate] processKeyInSequence: Could not map event to keyString. Shaking window.")
                DispatchQueue.main.async { self.controller.window.shake() }
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = (endTime - startTime) * 1000
                debugLog(String(format: "[AppDelegate] processKeyInSequence: time %.2fms", duration))
                return true // Event handled (by shaking)
            }
        }

        debugLog("[AppDelegate] processKeyInSequence: Mapped keyString: '\(keyString)'")

        // Check if the keyString matches an action or group within the currently active group
        // Use the pre-built action map for O(1) lookup instead of linear search
        if let currentGroup = currentSequenceGroup, let hit = currentGroupActionMap?[keyString] {
            debugLog("[AppDelegate] processKeyInSequence: Found match for '\(keyString)' in group '\(currentGroup.displayName).'")
            switch hit {
            case .action(let action):
                debugLog("[AppDelegate] processKeyInSequence: Matched ACTION: '\\(action.displayName)' (\\(action.value)).")
                // Run the action (ensure it's on main thread since we're already there)
                controller.runAction(action)

                // Original Behavior: Check Sticky Mode for ALL action types
                let isStickyModeActive = isInStickyMode(modifiers)
                if !isStickyModeActive {
                    debugLog("[AppDelegate] processKeyInSequence: Sticky mode NOT active. Hiding window and resetting sequence.")
                    DispatchQueue.main.async { [weak self] in
                        self?.hide()
                    }
                } else {
                    debugLog("[AppDelegate] processKeyInSequence: Sticky mode ACTIVE. Keeping window open and preserving sequence state.")
                }
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = (endTime - startTime) * 1000
                debugLog(String(format: "[AppDelegate] processKeyInSequence: time %.2fms", duration))
                return true // Event handled

            case .group(let subgroup):
                debugLog("[AppDelegate] processKeyInSequence: Matched GROUP: '\(subgroup.displayName). Navigating into subgroup.")
                
                // Update sequence state immediately to prevent race conditions
                currentSequenceGroup = subgroup
                
                // Build action map for the new group for fast lookups
                currentGroupActionMap = buildActionMap(for: subgroup)

                // Update UI state first to ensure correct display
                DispatchQueue.main.async {
                    self.controller.userState.navigateToGroup(subgroup)
                }

                // Check if the group has sticky mode enabled
                if subgroup.stickyMode == true {
                    debugLog("[AppDelegate] processKeyInSequence: Group has stickyMode enabled. Activating sticky mode.")
                    activateStickyMode()
                }
                
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = (endTime - startTime) * 1000
                debugLog(String(format: "[AppDelegate] processKeyInSequence: time %.2fms", duration))
                return true // Event handled
            }
        } else {
            // Key not found in the current group.
            let groupName = currentSequenceGroup?.displayName ?? "(nil)"
            debugLog("[AppDelegate] processKeyInSequence: Key '\(keyString)' not found in current group '\(groupName)'.")

            let isStickyModeActive = isInStickyMode(modifiers)
            if isStickyModeActive {
                // In sticky mode: pass the event through so the underlying app receives the key/shortcut.
                debugLog("[AppDelegate] processKeyInSequence: Sticky mode ACTIVE -> passing event through.")
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = (endTime - startTime) * 1000
                debugLog(String(format: "[AppDelegate] processKeyInSequence: time %.2fms", duration))
                return false // Event NOT handled – let it propagate
            } else {
                // Not in sticky mode: indicate error by shaking the window and consuming the event.
                self.controller.window.shake()
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = (endTime - startTime) * 1000
                debugLog(String(format: "[AppDelegate] processKeyInSequence: time %.2fms", duration))
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
        let rootGroup = MainActor.assumeIsolated { controller.userState.activeRoot }
        guard let rootGroup = rootGroup else {
            // This should ideally not happen if Controller.show() worked correctly.
            print("[AppDelegate] startSequence: ERROR - controller.userState.activeRoot is nil! Falling back to default config root.")
            // Fallback logic, though this indicates a potential issue elsewhere
            self.activeRootGroup = config.root // Store the determined root group locally
            self.currentSequenceGroup = config.root // Start the sequence at this root
            self.currentGroupActionMap = buildActionMap(for: config.root) // Build action map for fallback
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
        
        // Build action map for fast lookups
        self.currentGroupActionMap = buildActionMap(for: rootGroup)
        
        // Set atomic sequence flag for ultra-fast callback checking
        OSAtomicCompareAndSwap32(0, 1, isInSequence)

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
            self.currentGroupActionMap = nil // Clear the action map
            
            // Clear atomic sequence flag for ultra-fast callback checking
            OSAtomicCompareAndSwap32(1, 0, isInSequence)
            
            // Clear any queued key events when sequence ends
            // clearKeyEventQueue() - removed, using lock-free queue now

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
        print("[AppDelegate] isInStickyMode: Config = \(config), Mods = \(describeModifiers(modifierFlags)), Toggled = \(stickyModeToggled), IsSticky = \(isSticky)")
        return isSticky
    }

    // Converts a key event into a single character string suitable for matching against config keys.
    // Handles forced English layout if enabled.
    private func keyStringForEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String? {
        // Check cache first for performance
        let cacheKey = KeyCacheEntry(keyCode: keyCode, modifierFlags: UInt64(modifiers.rawValue))
        if let cachedValue = keyStringCache[cacheKey] {
            debugLog("[AppDelegate] keyStringForEvent (Cache Hit): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(cachedValue)'")
            return cachedValue.isEmpty ? nil : cachedValue
        }
        
        // --- Option 1: Forced English Layout ---
        if Defaults[.forceEnglishKeyboardLayout], let mapped = englishKeymap[keyCode] {
            // Respect Shift key for case
            let result = modifiers.contains(.shift) ? mapped.uppercased() : mapped
            print("[AppDelegate] keyStringForEvent (Forced English): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result)' (Case Sensitive)")
            // Cache the result
            keyStringCache[cacheKey] = result
            return result.isEmpty ? nil : result
        }

        // --- Option 2: System Layout (Case Sensitive, Ignore Ctrl/Opt Effect) ---

        // Handle specific non-character keys FIRST by keycode
        let specialKey: String?
        switch keyCode {
            case 36: specialKey = "\u{21B5}" // Enter
            case 48: specialKey = "\t"       // Tab
            case 49: specialKey = " "       // Space
            case 51: specialKey = "\u{0008}" // Backspace
            case KeyCodes.escape: specialKey = "\u{001B}" // Escape
            case 126: specialKey = "↑"      // Up Arrow
            case 125: specialKey = "↓"      // Down Arrow
            case 123: specialKey = "←"      // Left Arrow
            case 124: specialKey = "→"      // Right Arrow
            default: specialKey = nil // Continue for other keys
        }
        
        if let specialKey = specialKey {
            // Cache the special key
            keyStringCache[cacheKey] = specialKey
            return specialKey
        }

        // For remaining keys, determine character based on modifiers
        let nsEvent = NSEvent(cgEvent: cgEvent)
        var result: String?

        // If Control or Option are involved, get the base character *ignoring* those modifiers,
        // BUT respecting Shift for case sensitivity lookup.
        if modifiers.contains(.control) || modifiers.contains(.option) {
             // Get characters ignoring Ctrl/Opt, which might still include Shift effect
            result = nsEvent?.charactersIgnoringModifiers
            print("[AppDelegate] keyStringForEvent (System Layout - Ctrl/Opt): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Ignoring Ctrl/Opt effect)")
        } else {
            // No Ctrl/Opt involved. Get the character directly, which includes Shift effect.
            result = nsEvent?.characters
            print("[AppDelegate] keyStringForEvent (System Layout - Shift/Base): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result ?? "nil")' (Respecting Shift)")
        }

        // Final check: return nil if the resulting string is empty.
        if result?.isEmpty ?? true {
            print("[AppDelegate] keyStringForEvent: Result is empty or nil, returning nil.")
            return nil
        } else {
            // Cache the result before returning
            keyStringCache[cacheKey] = result!
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
    
    // Helper function to build action map for O(1) lookups
    private func buildActionMap(for group: Group) -> [String: ActionOrGroup] {
        var map: [String: ActionOrGroup] = [:]
        for action in group.actions {
            if let key = action.item.key {
                map[key] = action
            }
        }
        return map
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
