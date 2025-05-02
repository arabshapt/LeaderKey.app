import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import Sparkle
import SwiftUI
import UserNotifications
import ObjectiveC

let updateLocationIdentifier = "UpdateCheck"

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
        identifier: .general, title: "General",
        toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!,
        contentView: { GeneralPane().environmentObject(self.config) }
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
    guard
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    else { return }
        guard !isRunningTests() else { return } // isRunningTests() is in private extension

        UNUserNotificationCenter.current().delegate = self // Conformance is in extension
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
        if let error = error { print("Error requesting notification permission: \(error)") }
    }

    NSApp.mainMenu = MainMenu()

    config.ensureAndLoad()
    state = UserState(userConfig: config)
    controller = Controller(userState: state, userConfig: config)
    
        setupFileMonitor()      // Defined in private extension
        setupStatusItem()       // Defined in private extension
        startEventTapMonitoring() // Defined in Event Tap Handling extension
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    // Attempt to start monitoring if it failed previously (e.g., due to permissions)
    if !isMonitoring {
      print("[AppDelegate] applicationDidBecomeActive: Not monitoring, attempting to start...")
      startEventTapMonitoring()
    } else {
      print("[AppDelegate] applicationDidBecomeActive: Already monitoring.")
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
        stopEventTapMonitoring() // Defined in Event Tap Handling extension
    config.saveCurrentlyEditingConfig()
  }

    // --- Actions & Window Handling ---
  @IBAction
  func settingsMenuItemActionHandler(_: NSMenuItem) { 
      // Configure window properties before showing
      if let window = settingsWindowController.window {
          window.styleMask.insert(NSWindow.StyleMask.resizable)
          window.minSize = NSSize(width: 450, height: 650) // Set minimum size
      }
      settingsWindowController.show()
      NSApp.activate(ignoringOtherApps: true) 
  }

    func show(type: Controller.ActivationType = .appSpecificWithFallback, completion: (() -> Void)? = nil) { controller.show(type: type, completion: completion) }

    func hide() { 
      print("[AppDelegate] hide() called.") // Log entry into hide()
      controller.hide() 
    }

    // --- Activation Logic (Called by Event Tap) ---
  func handleActivation(type: Controller.ActivationType) {
      if controller.window.isVisible { // Check visibility first
          switch Defaults[.reactivateBehavior] {
          case .hide:
              // If behavior is hide, just hide and reset immediately when visible.
              hide()
              resetSequenceState()
              return // Stop processing here
          case .reset:
              // If window wasn't key, make it key first.
              if !controller.window.isKeyWindow {
                  print("[AppDelegate] handleActivation (Reset): Window visible but not key. Activating.")
                  NSApp.activate(ignoringOtherApps: true)
                  controller.window.makeKeyAndOrderFront(nil)
              }
              // Clear state, reset sequence, start new sequence.
              controller.userState.clear()
              resetSequenceState() // Clear just in case
              startSequence(activationType: type)
          case .nothing:
              // If window wasn't key, make it key first.
              if !controller.window.isKeyWindow {
                  print("[AppDelegate] handleActivation (Nothing): Window visible but not key. Activating.")
                  NSApp.activate(ignoringOtherApps: true)
                  controller.window.makeKeyAndOrderFront(nil)
              }
              // Only start a sequence if one isn't already active.
              if currentSequenceGroup == nil { startSequence(activationType: type) }
          }
      } else {
          // Window wasn't visible, show it AND start the sequence
          show(type: type)
          startSequence(activationType: type)
      }
  }
    
    // NOTE: All Event Tap methods (start/stop/handle/process...), Sparkle delegate methods, 
    // UNUserNotificationCenter delegate methods, URL Scheme methods, and private helpers 
    // (setupFileMonitor, setupStatusItem, isRunningTests) should be defined ONLY in extensions below.
    // Ensure there are NO duplicate definitions within this main class body.
}

// MARK: - Private Helpers
private extension AppDelegate {
    // ... (setupFileMonitor, setupStatusItem, isRunningTests implementations) ...
    func setupFileMonitor() {
        Task {
            for await _ in Defaults.updates(.configDir) {
                self.fileMonitor?.stopMonitoring()
                self.fileMonitor = FileMonitor(fileURL: config.url) { self.config.reloadConfig() }
                self.fileMonitor.startMonitoring()
            }
        }
    }

    func setupStatusItem() {
        statusItem.handlePreferences = { self.settingsWindowController.show(); NSApp.activate(ignoringOtherApps: true) }
        statusItem.handleReloadConfig = { self.config.reloadConfig() }
        statusItem.handleRevealConfig = { NSWorkspace.shared.activateFileViewerSelecting([self.config.url]) }
        statusItem.handleCheckForUpdates = { self.updaterController.checkForUpdates(nil) }
        Task { 
            for await value in Defaults.updates(.showMenuBarIcon) {
                DispatchQueue.main.async {
                    if value {
                        self.statusItem.enable()
                    } else {
                        self.statusItem.disable()
                    }
                }
            }
        }
    }

    func isRunningTests() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil
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
    // ... (URL handling method implementations) ...
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { handleURL(url) }
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "leaderkey" else { return }
        show()
        if url.host == "navigate",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let keysParam = queryItems.first(where: { $0.name == "keys" })?.value
        {
            let keys = keysParam.split(separator: ",").map(String.init)
            processKeys(keys)
        }
    }

    private func processKeys(_ keys: [String]) {
        guard !keys.isEmpty else { return }
        controller.handleKey(keys[0])
        if keys.count > 1 {
            let remainingKeys = Array(keys.dropFirst())
            var delayMs = 100
            for key in remainingKeys {
                delay(delayMs) { [weak self] in self?.controller.handleKey(key) }
                delayMs += 100
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
    private struct AssociatedKeys {
        static var eventTap = "eventTap"
        static var runLoopSource = "runLoopSource"
        static var isMonitoring = "isMonitoring"
        static var activeRootGroup = "activeRootGroup"
        static var currentSequenceGroup = "currentSequenceGroup"
        static var didShowPermissionsAlertRecently = "didShowPermissionsAlertRecently"
    }

    // --- Event Tap Logic Methods ---
    func startEventTapMonitoring() {
        guard !isMonitoring else { return } // Already monitoring
        print("[AppDelegate] Attempting to start event tap monitoring...")

        // Attempt to create the event tap
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, 
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventTapCallback, 
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("[AppDelegate] Failed to create event tap. Permissions likely missing.")
            // Check permissions status *after* failure, without prompting user here
            if !checkAccessibilityPermissions() && !didShowPermissionsAlertRecently {
                print("[AppDelegate] Permissions check failed and alert not shown recently. Showing alert.")
                showPermissionsAlert()
                self.didShowPermissionsAlertRecently = true
                // Reset the flag after a delay to allow re-prompting later if needed
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    print("[AppDelegate] Resetting didShowPermissionsAlertRecently flag.")
                    self.didShowPermissionsAlertRecently = false
                }
            } else {
                print("[AppDelegate] Permissions check passed OR alert shown recently. Not showing alert now.")
            }
            return // Stop, as tap creation failed
        }
        
        // Tap creation successful, proceed with setup
        print("[AppDelegate] Event tap created successfully.")
        self.eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.isMonitoring = true
        self.didShowPermissionsAlertRecently = false // Reset flag as monitoring is now active
        print("[AppDelegate] Event tap enabled and monitoring started.")
    }

    func stopEventTapMonitoring() {
        // ... (implementation as before) ...
        guard isMonitoring else { return }
        print("[AppDelegate] Stopping event tap.")
        resetSequenceState()
        if let source = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes); self.runLoopSource = nil }
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false); self.eventTap = nil }
        self.isMonitoring = false
        print("[AppDelegate] Monitoring stopped.")
    }

    func handleCGEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        // ... (implementation as before) ...
        guard event.type == .keyDown else { return Unmanaged.passRetained(event) }
        guard let nsEvent = NSEvent(cgEvent: event) else { return Unmanaged.passRetained(event) }
        // Pass the original CGEvent along
        let handled = processKeyEvent(cgEvent: event, keyCode: nsEvent.keyCode, modifiers: nsEvent.modifierFlags)
        return handled ? nil : Unmanaged.passRetained(event)
    }

    private func processKeyEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        // 1. Check for activation shortcuts FIRST
        let shortcutAppSpecific = KeyboardShortcuts.getShortcut(for: .activateAppSpecific)
        let shortcutDefaultOnly = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly)
        var matchedActivationType: Controller.ActivationType? = nil

        // Check App-Specific Shortcut
        if let shortcut = shortcutAppSpecific, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            print("[AppDelegate] processKeyEvent: Matched App-Specific shortcut.")
            matchedActivationType = .appSpecificWithFallback
        }
        // Check Default Only Shortcut
        else if let shortcut = shortcutDefaultOnly, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            print("[AppDelegate] processKeyEvent: Matched Default Only shortcut.")
            matchedActivationType = .defaultOnly
        }

        // 2. If an activation shortcut was pressed, handle it
        if let type = matchedActivationType {
            handleActivation(type: type) // This handles show/hide/reset logic
            return true // Consume the activation shortcut press
        }

        // NEW: Check for Cmd+, to open Settings
        if modifiers.contains(.command), let nsEvent = NSEvent(cgEvent: cgEvent), nsEvent.charactersIgnoringModifiers == "," {
            print("[AppDelegate] Cmd+, detected via event tap. Opening settings.")
            NSApp.sendAction(#selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil, from: nil)
            // Reset sequence state and hide the panel
            resetSequenceState()
            DispatchQueue.main.async { self.hide() }
            return true // Consume the Cmd+, press
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

        // 4. If NOT activation or Escape, check if we are in a sequence
        if currentSequenceGroup != nil {
            // processKeyInSequence now only shakes on error or processes valid keys,
            // always returning true to consume the event within the sequence.
            return processKeyInSequence(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers)
        }

        // 5. If NOT activation, Escape, or in a sequence, let the event pass through
        print("[AppDelegate] processKeyEvent: No activation, Escape, or active sequence. Passing event.")
        return false
    }

    private func processKeyInSequence(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        guard let keyString = keyStringForEvent(cgEvent: cgEvent, keyCode: keyCode, modifiers: modifiers) else {
            // Invalid keyString mapping - just shake
            DispatchQueue.main.async { self.controller.window.shake() }
            return true // Event handled (by shaking)
        }
        if let currentGroup = currentSequenceGroup, let hit = currentGroup.actions.first(where: { $0.item.key == keyString }) {
            switch hit {
            case .action(let action): controller.runAction(action); if !isInStickyMode(modifiers) { hide() }; resetSequenceState(); return true
            case .group(let subgroup): currentSequenceGroup = subgroup; controller.userState.navigateToGroup(subgroup); return true
            }
        } else {
            // Key not found in the current group - just shake
            DispatchQueue.main.async { self.controller.window.shake() }
            return true // Event handled (by shaking)
        }
    }

    private func startSequence(activationType: Controller.ActivationType) {
        print("[AppDelegate] startSequence: type: \(activationType)")
        
        // Get the root group determined by the show() method via the controller's state
        guard let rootGroup = controller.userState.activeRoot else {
            print("[AppDelegate] Error: startSequence called but controller.userState.activeRoot is nil. Falling back to default config.")
            // Fallback logic, though this indicates a potential issue elsewhere
            self.activeRootGroup = config.root
            self.currentSequenceGroup = config.root
            if self.controller.window.isVisible {
                DispatchQueue.main.async {
                    self.controller.userState.navigateToGroup(self.config.root)
                }
            }
            return
        }

        // Set the sequence state using the already loaded active root
        self.activeRootGroup = rootGroup
        self.currentSequenceGroup = rootGroup
        
        // Update UI if window is already visible
        if self.controller.window.isVisible {
            DispatchQueue.main.async {
                self.controller.userState.navigateToGroup(rootGroup)
            }
        }
    }

    private func resetSequenceState() {
        // ... (implementation as before) ...
        if currentSequenceGroup != nil || activeRootGroup != nil {
            self.currentSequenceGroup = nil; self.activeRootGroup = nil
            DispatchQueue.main.async { self.controller.userState.clear() }
        }
    }

    private func isInStickyMode(_ modifierFlags: NSEvent.ModifierFlags) -> Bool {
        let config = Defaults[.modifierKeyConfiguration]
        // Expand switch statement to fix line length
        switch config {
        case .controlGroupOptionSticky:
            return modifierFlags.contains(.option)
        case .optionGroupControlSticky:
            return modifierFlags.contains(.control)
        }
    }

    private func keyStringForEvent(cgEvent: CGEvent, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String? {
        if Defaults[.forceEnglishKeyboardLayout], let mapped = englishKeymap[keyCode] { return modifiers.contains(.shift) ? mapped.uppercased() : mapped }
        switch keyCode {
            case 36: return "\u{21B5}"; case 48: return "\t"; case 49: return " "; case 51: return "\u{0008}"; case KeyCodes.escape: return "\u{001B}"
            case 126: return "↑"; case 125: return "↓"; case 123: return "←"; case 124: return "→"
            default:
                guard let tempEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else { return nil }
                tempEvent.flags = CGEventFlags(rawValue: UInt64(modifiers.rawValue))
                var length = 0
                var chars = [UniChar](repeating: 0, count: 4)
                tempEvent.keyboardGetUnicodeString(maxStringLength: chars.count, actualStringLength: &length, unicodeString: &chars)
                return length > 0 ? String(utf16CodeUnits: chars, count: length) : nil
        }
    }

    // --- Permissions Helpers ---
    private func checkAccessibilityPermissions() -> Bool {
        // ... (implementation as before) ...
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: false]; let enabled = AXIsProcessTrustedWithOptions(options as CFDictionary); return enabled
    }
    
    private func showPermissionsAlert() {
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
