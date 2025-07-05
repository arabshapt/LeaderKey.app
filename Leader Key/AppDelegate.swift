import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import Sparkle
import SwiftUI
import UserNotifications
import ObjectiveC

let updateLocationIdentifier = "UpdateCheck"

// Define the same unique tag here
private let leaderKeySyntheticEventTag: Int64 = 0xDEADBEEF

// MARK: - Event Tap Callback

// This needs to be a top-level function or static method to be used as a C callback.
private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo = userInfo else {
        return Unmanaged.passRetained(event)
    }

    // Cast the reference to AppDelegate and call the handler
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userInfo).takeUnretainedValue()
    return appDelegate.handleCGEvent(event)
}

// MARK: - Key Code Constants (Example)

// Define key codes for easier reference
struct KeyCodes {
    static let keyK: UInt16 = 40
    static let escape: UInt16 = 53
    // Add other key codes as needed
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
fileprivate struct KeyboardShortcutsView: View {
    private let contentWidth = 900.0

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "Global Activation Shortcuts") {
                Form {
                    KeyboardShortcuts.Recorder("Activate (App-Specific):", name: .activateAppSpecific)
                    KeyboardShortcuts.Recorder("Activate (Default Only):", name: .activateDefaultOnly)
                }
                Text("These shortcuts activate Leader Key globally.\nApp-Specific tries to load the config for the frontmost app.\nDefault Only always loads the default config.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

fileprivate struct OpacityPane: View {
    @Default(.normalModeOpacity) var normalModeOpacity
    @Default(.stickyModeOpacity) var stickyModeOpacity

    var body: some View {
        Settings.Container(contentWidth: 1100.0) {
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
      ),
    ],
    style: .segmentedControl
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

    print("[AppDelegate] applicationDidFinishLaunching: Starting up...")

    // Setup Notifications
    UNUserNotificationCenter.current().delegate = self // Conformance is in extension
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error { print("[AppDelegate] Error requesting notification permission: \(error)") }
        print("[AppDelegate] Notification permission granted: \(granted)")
    }

    // Setup Main Menu
    NSApp.mainMenu = MainMenu()

    // Load configuration and initialize state
    print("[AppDelegate] Initializing UserConfig and UserState...")
    config.ensureAndLoad() // Ensures config dir/file exists and loads default config
    state = UserState(userConfig: config)
    controller = Controller(userState: state, userConfig: config, appDelegate: self)
    print("[AppDelegate] UserConfig and UserState initialized.")

    // Setup background services and UI elements
    setupFileMonitor()      // Defined in private extension
    setupStatusItem()       // Defined in private extension
    setupUpdaterController() // Configure auto-update behavior

    // Attempt to start the global event tap immediately
    print("[AppDelegate] Attempting initial startEventTapMonitoring()...")
    startEventTapMonitoring() // Defined in Event Tap Handling extension

    // Add a delayed check to retry starting the event tap if it failed initially.
    // This helps if Accessibility permissions were granted just before launch
    // and the system needs a moment to register them.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Wait 1 second
        if !self.isMonitoring {
            print("[AppDelegate] Delayed check: Still not monitoring. Retrying startEventTapMonitoring()...")
            self.startEventTapMonitoring()
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
    print("[AppDelegate] applicationWillTerminate completed.")
  }

    // --- Actions & Window Handling ---
  @IBAction
  func settingsMenuItemActionHandler(_: NSMenuItem) {
      print("[AppDelegate] settingsMenuItemActionHandler called.")

      // Ensure we have the window reference first
      guard let window = settingsWindowController.window else {
          print("[AppDelegate settings] Error: Could not get settings window reference.")
          settingsWindowController.show()
          NSApp.activate(ignoringOtherApps: true)
          return
      }

      // --- Configure Window Properties First ---
      window.styleMask.insert(NSWindow.StyleMask.resizable)
      window.minSize = NSSize(width: 450, height: 650) // Ensure minSize is set

      // --- Defer Positioning Logic Slightly ---
      DispatchQueue.main.async { // Add async dispatch
          print("[AppDelegate settings async] Starting deferred positioning logic...")
          // --- Calculate Target Origin --- START ---
          var calculatedOrigin: NSPoint? = nil
          let mouseLocation = NSEvent.mouseLocation
          let screen = NSScreen.screens.first { $0.frame.contains(mouseLocation) } ?? NSScreen.main

          if let targetScreen = screen {
              let screenFrame = targetScreen.visibleFrame
              // Re-check window size within async block, might be updated
              let windowSize = window.frame.size
              let effectiveWidth = (windowSize.width > 0) ? windowSize.width : window.minSize.width
              let effectiveHeight = (windowSize.height > 0) ? windowSize.height : window.minSize.height

              if effectiveWidth > 0 && effectiveHeight > 0 {
                  let newOriginX = screenFrame.origin.x + (screenFrame.size.width - effectiveWidth) / 2.0
                  let newOriginY = screenFrame.origin.y + (screenFrame.size.height - effectiveHeight) / 2.0
                  calculatedOrigin = NSPoint(x: newOriginX, y: newOriginY)
                  print("[AppDelegate settings async] Calculated Center Origin: \(calculatedOrigin!)")
              } else {
                  print("[AppDelegate settings async] Warning: Could not determine effective window size (Size: \(windowSize)). Origin calculation skipped.")
              }
          } else {
              print("[AppDelegate settings async] Warning: Could not get target screen. Origin calculation skipped.")
          }
          // --- Calculate Target Origin --- END ---

          // --- Set Origin --- START ---
          if let originToSet = calculatedOrigin {
              print("[AppDelegate settings async] Setting origin: \(originToSet)")
              window.setFrameOrigin(originToSet)
          } else {
              print("[AppDelegate settings async] Origin calculation failed. Centering window.")
              window.center()
          }
          // --- Set Origin --- END ---
      } // End async dispatch

      // Show the window controller immediately (positioning will happen asynchronously)
      settingsWindowController.show()

      NSApp.activate(ignoringOtherApps: true) // Bring the app to the front for settings
      print("[AppDelegate] Settings window show() called (positioning deferred).")
  }

    // Convenience method to show the main Leader Key window
    func show(type: Controller.ActivationType = .appSpecificWithFallback, completion: (() -> Void)? = nil) {
        print("[AppDelegate] show(type: \(type)) called.")
        controller.show(type: type, completion: completion)
    }

    // Convenience method to hide the main Leader Key window
    func hide() {
      print("[AppDelegate] hide() called.") // Log entry into hide()
      controller.hide()
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

        print("[AppDelegate] handleCommandReleased: Command key released with resetOnCmdRelease enabled. Resetting and hiding.")
        DispatchQueue.main.async {
            self.resetSequenceState()
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
              resetSequenceState() // Reset any ongoing sequence
              return // Stop processing here

          case .reset:
              // Preference: Reset the sequence if activated again while visible.
              print("[AppDelegate] handleActivation: Reactivate behavior is 'reset'. Resetting sequence.")
              // If window wasn't key (e.g., user clicked elsewhere), make it key first.
              if !controller.window.isKeyWindow {
                  print("[AppDelegate] handleActivation (Reset): Window visible but not key. Activating.")
                  NSApp.activate(ignoringOtherApps: true)
                  controller.window.makeKeyAndOrderFront(nil)
              }
              // Clear existing state, reset sequence variables, and start a new sequence based on the activation type.
              controller.userState.clear()
              resetSequenceState() // Reset sequence state in AppDelegate
              print("[AppDelegate] handleActivation (Reset): Starting new sequence.")
              controller.repositionWindowNearMouse()
              startSequence(activationType: type)

          case .nothing:
              // Preference: Do nothing if activated again while visible, unless window lost focus.
              print("[AppDelegate] handleActivation: Reactivate behavior is 'nothing'.")
              // If window wasn't key, make it key first.
              if !controller.window.isKeyWindow {
                  print("[AppDelegate] handleActivation (Nothing): Window visible but not key. Activating.")
                  NSApp.activate(ignoringOtherApps: true)
                  controller.window.makeKeyAndOrderFront(nil)
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
          // Window wasn't visible, so show it AND start the sequence.
          print("[AppDelegate] handleActivation: Window not visible. Showing window and starting sequence.")
          show(type: type) // Show the window (Controller loads the appropriate config)
          startSequence(activationType: type) // Start the key sequence based on the loaded config
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
           let keysParam = queryItems.first(where: { $0.name == "keys" })?.value
        {
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
    private struct AssociatedKeys {
        static var eventTap = "eventTap"
        static var runLoopSource = "runLoopSource"
        static var isMonitoring = "isMonitoring"
        static var activeRootGroup = "activeRootGroup"
        static var currentSequenceGroup = "currentSequenceGroup"
        static var didShowPermissionsAlertRecently = "didShowPermissionsAlertRecently"
        static var stickyModeToggled = "stickyModeToggled"
        static var lastModifierFlags = "lastModifierFlags"
        static var activeActivationShortcut = "activeActivationShortcut"
    }

    // --- Event Tap Logic Methods ---
    func startEventTapMonitoring() {
        // Ensure we don't start multiple taps
        guard !isMonitoring else {
            print("[AppDelegate] startEventTapMonitoring: Already monitoring. Aborting.")
            return
        }
        print("[AppDelegate] startEventTapMonitoring: Attempting to start...")

        // Create the event tap. This requires Accessibility permissions.
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue) // Listen for key down, key up, and modifier changes
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, // Listen to all processes in the current session
            place: .headInsertEventTap, // Insert tap before other taps
            options: .defaultTap, // Default behavior
            eventsOfInterest: eventMask, // Mask for key down events
            callback: eventTapCallback, // C function callback defined globally
            userInfo: Unmanaged.passUnretained(self).toOpaque() // Pass reference to self
        ) else {
            // Failure usually means Accessibility permissions are missing or denied.
            print("[AppDelegate] startEventTapMonitoring: Failed to create event tap. Permissions likely missing.")
            // Check permissions status *after* failure, only prompt if we haven't recently.
            if !checkAccessibilityPermissions() && !didShowPermissionsAlertRecently {
                print("[AppDelegate] startEventTapMonitoring: Accessibility permissions check failed AND alert not shown recently. Showing alert.")
                showPermissionsAlert()
                self.didShowPermissionsAlertRecently = true // Flag to avoid spamming alerts
                // Reset the flag after a short delay to allow re-prompting later if needed
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    print("[AppDelegate] Resetting didShowPermissionsAlertRecently flag.")
                    self.didShowPermissionsAlertRecently = false
                }
            } else {
                print("[AppDelegate] startEventTapMonitoring: Accessibility check passed OR alert shown recently. Not showing permissions alert now.")
            }
            return // Stop, as tap creation failed
        }

        // Tap creation successful, proceed with setup
        print("[AppDelegate] startEventTapMonitoring: Event tap created successfully.")
        self.eventTap = tap
        // Create a run loop source from the tap and add it to the current run loop
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        // Enable the tap
        CGEvent.tapEnable(tap: tap, enable: true)
        self.isMonitoring = true // Set monitoring state
        self.didShowPermissionsAlertRecently = false // Reset alert flag as monitoring is now active
        print("[AppDelegate] startEventTapMonitoring: Event tap enabled and monitoring started.")
    }

    func stopEventTapMonitoring() {
        guard isMonitoring else {
             print("[AppDelegate] stopEventTapMonitoring: Not currently monitoring. Aborting.")
             return
        }
        print("[AppDelegate] stopEventTapMonitoring: Stopping event tap...")
        resetSequenceState() // Ensure sequence state is cleared
        // Remove run loop source and invalidate the tap
        if let source = runLoopSource {
             print("[AppDelegate] stopEventTapMonitoring: Removing run loop source.")
             CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
             self.runLoopSource = nil
        }
        if let tap = eventTap {
             print("[AppDelegate] stopEventTapMonitoring: Disabling and releasing tap.")
             CGEvent.tapEnable(tap: tap, enable: false) // Disable first
             self.eventTap = nil // Release reference
        }
        self.isMonitoring = false // Update state
        print("[AppDelegate] stopEventTapMonitoring: Monitoring stopped.")
    }

    // This is the entry point called by the C callback `eventTapCallback`
    func handleCGEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        // Handle different event types
        switch event.type {
        case .keyDown:
            return handleKeyDownEvent(event)
        case .keyUp:
            return handleKeyUpEvent(event)
        case .flagsChanged:
            return handleFlagsChangedEvent(event)
        default:
            return Unmanaged.passRetained(event)
        }
    }

    private func handleKeyDownEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        // ----> Check if the event is tagged as synthetic <----
        let userData = event.getIntegerValueField(.eventSourceUserData)
        if userData == leaderKeySyntheticEventTag {
            print("[AppDelegate] handleKeyDownEvent: Ignoring synthetic event generated by Leader Key.")
            return Unmanaged.passRetained(event) // Pass it through
        }
        // ----> End synthetic event check <----

        // Try to convert CGEvent to NSEvent to easily access key code and modifiers
        guard let nsEvent = NSEvent(cgEvent: event) else {
             print("[AppDelegate] handleKeyDownEvent: Failed to convert CGEvent to NSEvent. Passing event through.")
             return Unmanaged.passRetained(event)
        }
        // Process the key event using our main logic function
        // Let's get the mapped key string here for better logging
        let mappedKeyString = keyStringForEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags) ?? "[?Unmapped?]"
        print("[AppDelegate] handleKeyDownEvent: Received keyDown, keyCode: \(nsEvent.keyCode) ('\(mappedKeyString)'), mods: \(describeModifiers(nsEvent.modifierFlags)). Processing...")
        let handled = processKeyEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags)

        // If 'handled' is true, consume the event (return nil). Otherwise, pass it through (return retained event).
         print("[AppDelegate] handleKeyDownEvent: Event handled = \(handled). Returning \(handled ? "nil (consume)" : "event (pass through)").")
        return handled ? nil : Unmanaged.passRetained(event)
    }

    private func handleKeyUpEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        // For key up events, just update transparency if we're in a sequence
        if currentSequenceGroup != nil {
            guard let nsEvent = NSEvent(cgEvent: event) else {
                return Unmanaged.passRetained(event)
            }

            // Update transparency based on current modifier state
            let isStickyModeActive = isInStickyMode(nsEvent.modifierFlags)
            DispatchQueue.main.async {
                self.controller.window.alphaValue = isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
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

            // Update transparency based on current modifier state
            let isStickyModeActive = isInStickyMode(currentFlags)
            DispatchQueue.main.async {
                self.controller.window.alphaValue = isStickyModeActive ? Defaults[.stickyModeOpacity] : Defaults[.normalModeOpacity]
            }
            print("[AppDelegate] handleFlagsChangedEvent: Modifier flags changed, command pressed: \(commandPressed), command released: \(commandReleased), sticky mode = \(isStickyModeActive)")
        }

        // Always pass through modifier changes
        return Unmanaged.passRetained(event)
    }

    private func processKeyEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        // 1. Check for activation shortcuts FIRST
        let shortcutAppSpecific = KeyboardShortcuts.getShortcut(for: .activateAppSpecific)
        let shortcutDefaultOnly = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly)
        var matchedActivationType: Controller.ActivationType? = nil
        var matchedShortcut: KeyboardShortcuts.Shortcut? = nil

        // Check App-Specific Shortcut
        if let shortcut = shortcutAppSpecific, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            print("[AppDelegate] processKeyEvent: Matched App-Specific shortcut.")
            matchedActivationType = .appSpecificWithFallback
            matchedShortcut = shortcut
        }
        // Check Default Only Shortcut
        else if let shortcut = shortcutDefaultOnly, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            print("[AppDelegate] processKeyEvent: Matched Default Only shortcut.")
            matchedActivationType = .defaultOnly
            matchedShortcut = shortcut
        }

        // 2. If an activation shortcut was pressed, handle it
        if let type = matchedActivationType {
            handleActivation(type: type, activationShortcut: matchedShortcut) // Pass the matched shortcut
            return true // Consume the activation shortcut press
        }

        // 3. If NOT an activation shortcut, check for Escape
        if keyCode == KeyCodes.escape {
            let isWindowVisible = self.controller.window.isVisible
            print("[AppDelegate] Escape pressed. Window isVisible: \(isWindowVisible)")

            if isWindowVisible {
                // Normal case: Window is visible, reset state, hide, and consume event.
                print("[AppDelegate] Escape: Window is visible. Resetting state and dispatching hide().")
                resetSequenceState()
                DispatchQueue.main.async { self.hide() }
                return true // Consume the Escape press
            } else {
                // Inconsistent state: Window is visually present but isVisible is false.
                // Do NOT reset state, do NOT hide, let the Escape key pass through.
                print("[AppDelegate] Escape: Window isVisible is false (inconsistent state?). Passing event through.")
                return false // Pass through the Escape press
            }
        }

        // 4. If NOT activation, Escape, or Cmd+, check if we are in a sequence
        if currentSequenceGroup != nil {
            // --- SPECIAL CHECK WITHIN ACTIVE SEQUENCE ---
            // Check for Cmd+, specifically *before* normal sequence processing
            if modifiers.contains(.command),
               let nsEvent = NSEvent(cgEvent: cgEvent),
               nsEvent.charactersIgnoringModifiers == ","
            {
                print("[AppDelegate] processKeyEvent: Cmd+, detected while sequence active. Opening settings.")
                NSApp.sendAction(#selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil, from: nil)
                // Reset sequence state and hide the panel
                resetSequenceState()
                DispatchQueue.main.async { self.hide() }
                return true // Consume the Cmd+, press
            }
            // --- END SPECIAL CHECK ---

            // If not Cmd+, process the key normally within the sequence
            print("[AppDelegate] processKeyEvent: Active sequence detected (and not Cmd+). Processing key within sequence...")

            // Clear the activation shortcut since the user is now actively using Leader Key
            // This enables the Cmd-release reset feature after activation
            if activeActivationShortcut != nil {
                print("[AppDelegate] processKeyEvent: Clearing activeActivationShortcut - user is now actively using Leader Key.")
                activeActivationShortcut = nil
            }

            return processKeyInSequence(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
        }

        // 5. If NOT activation, Escape, or in a sequence, let the event pass through
        print("[AppDelegate] processKeyEvent: No activation shortcut, Escape, or active sequence matched. Passing event through.")
        return false
    }

    private func processKeyInSequence(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        print("[AppDelegate] processKeyInSequence: Processing keyCode: \(keyCode), mods: \(describeModifiers(modifiers))")

        // Get the single character string representation for the key event
        guard let keyString = keyStringForEvent(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers) else {
            // If we can't map the key event to a string (should be rare), shake the window.
            print("[AppDelegate] processKeyInSequence: Could not map event to keyString. Shaking window.")
            DispatchQueue.main.async { self.controller.window.shake() }
            return true // Event handled (by shaking)
        }

        print("[AppDelegate] processKeyInSequence: Mapped keyString: '\(keyString)'")

        // Check if the keyString matches an action or group within the currently active group
        if let currentGroup = currentSequenceGroup, let hit = currentGroup.actions.first(where: { $0.item.key == keyString }) {
            print("[AppDelegate] processKeyInSequence: Found match for '\(keyString)' in group '\(currentGroup.displayName).'")
            switch hit {
            case .action(let action):
                print("[AppDelegate] processKeyInSequence: Matched ACTION: '\\(action.displayName)' (\\(action.value)).")
                // Run the action
                controller.runAction(action)

                // Original Behavior: Check Sticky Mode for ALL action types
                let isStickyModeActive = isInStickyMode(modifiers)
                if !isStickyModeActive {
                    print("[AppDelegate] processKeyInSequence: Sticky mode NOT active. Hiding window and resetting sequence.")
                    hide()
                    resetSequenceState()
                } else {
                    print("[AppDelegate] processKeyInSequence: Sticky mode ACTIVE. Keeping window open and preserving sequence state.")
                }
                return true // Event handled

            case .group(let subgroup):
                print("[AppDelegate] processKeyInSequence: Matched GROUP: '\(subgroup.displayName). Navigating into subgroup.")

                // Check if the group has sticky mode enabled
                if subgroup.stickyMode == true {
                    print("[AppDelegate] processKeyInSequence: Group has stickyMode enabled. Activating sticky mode.")
                    activateStickyMode()
                }

                // Navigate into the subgroup
                currentSequenceGroup = subgroup // Update sequence state
                controller.userState.navigateToGroup(subgroup) // Update UI state
                return true // Event handled
            }
        } else {
            // Key not found in the current group - shake the window to indicate error
            let groupName = currentSequenceGroup?.displayName ?? "(nil)"
            print("[AppDelegate] processKeyInSequence: Key '\(keyString)' not found in current group '\(groupName).'")
            DispatchQueue.main.async { self.controller.window.shake() }
            return true // Event handled (by shaking)
        }
    }

    // This function is called when an activation shortcut is pressed or via URL scheme.
    // It sets up the initial state for a new key sequence based on the loaded config.
    private func startSequence(activationType: Controller.ActivationType) {
        print("[AppDelegate] startSequence: Starting sequence with type: \(activationType)")

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
        // --- Option 1: Forced English Layout ---
        if Defaults[.forceEnglishKeyboardLayout], let mapped = englishKeymap[keyCode] {
            // Respect Shift key for case
            let result = modifiers.contains(.shift) ? mapped.uppercased() : mapped
            print("[AppDelegate] keyStringForEvent (Forced English): keyCode \(keyCode), mods \(describeModifiers(modifiers)) -> '\(result)' (Case Sensitive)")
            return result.isEmpty ? nil : result
        }

        // --- Option 2: System Layout (Case Sensitive, Ignore Ctrl/Opt Effect) ---

        // Handle specific non-character keys FIRST by keycode
        switch keyCode {
            case 36: return "\u{21B5}" // Enter
            case 48: return "\t"       // Tab
            case 49: return " "       // Space
            case 51: return "\u{0008}" // Backspace
            case KeyCodes.escape: return "\u{001B}" // Escape
            case 126: return "↑"      // Up Arrow
            case 125: return "↓"      // Down Arrow
            case 123: return "←"      // Left Arrow
            case 124: return "→"      // Right Arrow
            default: break // Continue for other keys
        }

        // For remaining keys, determine character based on modifiers
        let nsEvent = NSEvent(cgEvent: cgEvent)
        var result: String? = nil

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
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: false] // Option to not prompt
        let enabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        print("[AppDelegate] checkAccessibilityPermissions: AXIsProcessTrustedWithOptions returned \(enabled).")
        return enabled
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
                if let url = URL(string: urlString) { NSWorkspace.shared.open(url) }
                else { NSWorkspace.shared.open(URL(fileURLWithPath: backupPath)) }
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
