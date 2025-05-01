import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import Sparkle
import SwiftUI
import UserNotifications

let updateLocationIdentifier = "UpdateCheck"

// MARK: - StealthModeManager class implementation
class StealthModeManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    // --- State for Silent Sequence Handling ---
    private var activeStealthRoot: Group? = nil
    private var activeStealthGroup: Group? = nil
    private var lastKeyTime: Date = Date() // Tracks time since last key press *in sequence* or activation
    private var sequenceTimeoutInterval: TimeInterval = 1.0 // Timeout for the sequence
    // --- End State ---

    private var isEnabled = false
    private weak var appDelegate: AppDelegate? // Use weak reference to avoid retain cycles

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    func startMonitoring() {
        guard !isEnabled else { return }
        print("[StealthModeManager] Attempting to start monitoring...")
        guard checkAccessibilityPermissions() else {
            print("[StealthModeManager] Accessibility permissions not granted. Cannot start.")
            return
        }

        let eventMask: CGEventMask = UInt64(1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: stealthModeCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("[StealthModeManager] Failed to create event tap")
            showPermissionsAlert()
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isEnabled = true
        print("[StealthModeManager] Event tap created and enabled. Monitoring started.")
    }

    func stopMonitoring() {
        guard isEnabled else { return }
        print("[StealthModeManager] Stopping monitoring...")
        resetStealthSequence() // Ensure sequence state is cleared when stopping
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            self.eventTap = nil
        }
        isEnabled = false
        print("[StealthModeManager] Monitoring stopped.")
    }

    // MARK: - Event Handling

    func handleCGEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let type = event.type
        guard type == .keyDown else { return Unmanaged.passRetained(event) }

        print("[StealthModeManager] handleCGEvent: KeyDown detected.")

        // Check for timeout *only if* a sequence is active
        let now = Date()
        if activeStealthGroup != nil { // Check if sequence active
            if now.timeIntervalSince(lastKeyTime) > sequenceTimeoutInterval {
                print("[StealthModeManager] handleCGEvent: Sequence timed out.")
                resetStealthSequence() // Reset state on timeout
            }
        }

        guard let nsEvent = NSEvent(cgEvent: event) else {
            print("[StealthModeManager] handleCGEvent: Could not create NSEvent from CGEvent.")
            return Unmanaged.passRetained(event)
        }

        let keyCode = nsEvent.keyCode
        let modifiers = nsEvent.modifierFlags

        print("[StealthModeManager] handleCGEvent: Processing keyCode: \(keyCode) Modifiers: \(modifiers.rawValue)")
        let handled = processKey(keyCode: keyCode, modifiers: modifiers)

        // Log the outcome
        let returnValue = handled ? nil : Unmanaged.passRetained(event)
        print("[StealthModeManager] handleCGEvent: Event handled by processKey: \(handled). Returning: \(returnValue == nil ? "nil (Consume)" : "event (Pass Through)")")
        
        return returnValue
    }

    private func processKey(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {

        // === Are we currently inside a silent sequence? ===
        if activeStealthGroup != nil {
            print("[StealthModeManager] processKey: Active stealth sequence. Processing keyCode: \(keyCode)")
            lastKeyTime = Date() // Keep sequence alive

            guard let keyString = keyStringForEvent(keyCode: keyCode, modifiers: modifiers) else {
                print("[StealthModeManager] processKey: Could not get key string for sequence input. Aborting sequence.")
                resetStealthSequence()
                return false // Event not handled (aborted sequence)
            }
            
            print("[StealthModeManager] processKey: Key string for sequence: '\(keyString)'")

            if keyCode == 53 { // Escape Key Code
               print("[StealthModeManager] processKey: Escape pressed. Cancelling stealth sequence.")
               resetStealthSequence()
               return true // Escape was handled
            }

            if let currentActiveGroup = activeStealthGroup,
               let hit = currentActiveGroup.actions.first(where: { $0.item.key == keyString }) {
                switch hit {
                case .action(let action):
                    print("[StealthModeManager] processKey: Matched action '\(action.displayName)' in sequence. Executing.")
                    guard let controller = appDelegate?.controller else {
                         print("[StealthModeManager] processKey: ERROR - AppDelegate or Controller not found for action execution.")
                         resetStealthSequence()
                         return false
                    }
                    controller.runAction(action)
                    resetStealthSequence()
                    return true // Action was handled
                case .group(let subgroup):
                     print("[StealthModeManager] processKey: Matched subgroup '\(subgroup.displayName)' in sequence. Navigating.")
                     activeStealthGroup = subgroup
                     return true // Navigation was handled
                }
            } else {
                print("[StealthModeManager] processKey: Key '\(keyString)' (keyCode: \(keyCode)) did not match any item. Aborting sequence.")
                resetStealthSequence()
                // Event was *not* handled as part of the sequence, but we don't want it passed through either.
                // Let it fall through to the activation check, but it likely won't match.
                // If we returned true here, a mistyped key would be consumed silently.
                // Returning false allows it to potentially trigger another app's shortcut if not an activation key.
                // Let's return true to consume mistyped keys within a sequence.
                return true 
            }
        }

        // === If NOT inside a sequence, check for activation shortcuts ===
        print("[StealthModeManager] processKey: Checking for activation shortcuts for keyCode: \(keyCode)")
        guard let ad = appDelegate else { return false }
        
        let shortcutAppSpecific = KeyboardShortcuts.getShortcut(for: .activateAppSpecific)
        let shortcutDefaultOnly = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly)

        // Check Group shortcuts FIRST
        for (groupPath, _) in Defaults[.groupShortcuts] {
            let shortcutName = KeyboardShortcuts.Name.forGroup(groupPath)
            if let shortcut = KeyboardShortcuts.getShortcut(for: shortcutName),
               matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
                print("[StealthModeManager] processKey: Matched GLOBAL GROUP shortcut for path '\(groupPath)'. Starting silent sequence.")
                guard let targetGroup = ad.config.findGroupByPath(groupPath) else {
                    print("[StealthModeManager] processKey: ERROR - Could not find group for path '\(groupPath)'")
                    resetStealthSequence()
                    return false
                }
                activeStealthRoot = ad.config.root
                activeStealthGroup = targetGroup
                lastKeyTime = Date()
                return true // Activation handled
            }
        }

        // Check main activation shortcuts
        if let shortcut = shortcutAppSpecific, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            print("[StealthModeManager] processKey: Matched activateAppSpecific shortcut. Starting silent sequence.")
            let frontmostApp = NSWorkspace.shared.frontmostApplication
            let bundleId = frontmostApp?.bundleIdentifier
            let rootGroup = ad.config.getConfig(for: bundleId) ?? ad.config.root
            activeStealthRoot = rootGroup
            activeStealthGroup = rootGroup
            lastKeyTime = Date()
            return true // Activation handled
        }

        if let shortcut = shortcutDefaultOnly, matchesShortcut(keyCode: keyCode, modifiers: modifiers, shortcut: shortcut) {
            print("[StealthModeManager] processKey: Matched activateDefaultOnly shortcut. Starting silent sequence.")
            let rootGroup = ad.config.root
            activeStealthRoot = rootGroup
            activeStealthGroup = rootGroup
            lastKeyTime = Date()
            return true // Activation handled
        }

        // No activation shortcut matched
        print("[StealthModeManager] processKey: KeyCode \(keyCode) did not match any activation shortcuts.")
        // Ensure state is reset if no activation occurred (should be redundant but safe)
        resetStealthSequence()
        return false // Event was not handled by StealthModeManager
    }

    // MARK: - Helpers

    private func resetStealthSequence() {
        // Check if state actually needs resetting to avoid redundant logs
        if activeStealthGroup != nil || activeStealthRoot != nil {
            print("[StealthModeManager] resetStealthSequence: Resetting state.")
            activeStealthGroup = nil
            activeStealthRoot = nil
        }
    }

    private func matchesShortcut(keyCode: UInt16, modifiers: NSEvent.ModifierFlags, shortcut: KeyboardShortcuts.Shortcut) -> Bool {
        let keyCodeMatch = (keyCode == UInt16(shortcut.carbonKeyCode))
        let modifiersMatch = modifiers.contains(shortcut.modifiers)
        // Optional: Add detailed logging back if needed for debugging matching issues
        // print("[StealthModeManager] matchesShortcut: Checking keyCode \(keyCode) vs \(shortcut.carbonKeyCode). Match: \(keyCodeMatch)")
        // print("[StealthModeManager] matchesShortcut: Checking mods \(modifiers.rawValue) vs \(shortcut.modifiers.rawValue). Match: \(modifiersMatch)")
        return keyCodeMatch && modifiersMatch
    }

    private func keyStringForEvent(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String? {
        if Defaults[.forceEnglishKeyboardLayout] {
            if let mapped = englishKeymap[keyCode] {
                return modifiers.contains(.shift) ? mapped.uppercased() : mapped
            }
        }

        switch keyCode {
            case 36: return "\u{21B5}" // Enter
            case 48: return "\t"     // Tab
            case 49: return " "      // Space
            case 51: return "\u{0008}" // Backspace (currently unused in sequence)
            case 53: return "\u{001B}" // Escape
            case 126: return "↑"
            case 125: return "↓"
            case 123: return "←"
            case 124: return "→"
            default: // Attempt fallback for printable chars
                guard let tempEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else { return nil }
                // Ensure flags cast is correct
                tempEvent.flags = CGEventFlags(rawValue: UInt64(modifiers.rawValue)) 
                var length = 0
                var chars = [UniChar](repeating: 0, count: 4) // Allow slightly longer buffer
                tempEvent.keyboardGetUnicodeString(maxStringLength: chars.count, actualStringLength: &length, unicodeString: &chars)
                return length > 0 ? String(utf16CodeUnits: chars, count: length) : nil
        }
    }
    
    // MARK: - Permissions Helpers (Keep Existing)
     private func checkAccessibilityPermissions() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessibilityEnabled {
            showPermissionsAlert()
        }
        
        return accessibilityEnabled
    }
    
    private func showPermissionsAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "Leader Key needs accessibility permissions to use stealth mode. Please enable it in System Preferences > Security & Privacy > Privacy > Accessibility."
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                } else {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane"))
                }
            }
            
            Defaults[.useStealthMode] = false
        }
    }

    // NOTE: activateGroupWithPath is likely no longer needed within StealthModeManager
    // as groups are activated via processKey starting a sequence. Consider removing.
    // private func activateGroupWithPath(_ groupPath: String) { ... }

} // End of StealthModeManager class

// This is the callback function required by CGEvent.tapCreate
private func stealthModeCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo = userInfo else {
        return Unmanaged.passRetained(event)
    }
    
    // Cast the reference to StealthModeManager and call the handler
    let manager = Unmanaged<StealthModeManager>.fromOpaque(userInfo).takeUnretainedValue()
    return manager.handleCGEvent(event)
}

// Supporting types for Shortcuts settings
fileprivate struct GroupViewModel: Identifiable {
    let id: UUID
    let name: String
    let key: String
    let path: String
}

fileprivate struct GroupShortcutRow: View {
    @Default(.groupShortcuts) var groupShortcuts
    let group: GroupViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.name)
                    .fontWeight(.medium)
                
                Text("Key: \(group.key)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            KeyboardShortcuts.Recorder(
                for: KeyboardShortcuts.Name.forGroup(group.path),
                onChange: { shortcut in
                    // When the shortcut changes, update our mapping
                    updateShortcutMapping(shortcut: shortcut != nil)
                }
            )
            .frame(width: 160)
        }
        .padding(.vertical, 4)
        .onAppear {
            // When a recorder appears, make sure its path exists in the mapping
            updateShortcutMapping(shortcut: KeyboardShortcuts.getShortcut(for: .forGroup(group.path)) != nil)
        }
    }
    
    private func updateShortcutMapping(shortcut: Bool) {
        var updatedShortcuts = groupShortcuts
        
        if shortcut {
            // Add or update the mapping
            updatedShortcuts[group.path] = group.path
        } else {
            // Remove the mapping if shortcut was cleared
            updatedShortcuts.removeValue(forKey: group.path)
        }
        
        groupShortcuts = updatedShortcuts
    }
}

fileprivate struct GroupShortcutsView: View {
    @EnvironmentObject private var config: UserConfig
    @Default(.groupShortcuts) var groupShortcuts
    @State private var selectedGroup: Group?
    @State private var searchText = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Configure global shortcuts for specific groups")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            Divider()
            
            searchField
            
            List {
                ForEach(filteredGroups, id: \.id) { group in
                    GroupShortcutRow(group: group)
                }
            }
            .frame(height: 300)
            .border(Color.primary.opacity(0.2), width: 1)
        }
        .padding()
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search groups", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(7)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
    
    private var filteredGroups: [GroupViewModel] {
        getAllGroups().filter { group in
            searchText.isEmpty || 
            group.name.localizedCaseInsensitiveContains(searchText) ||
            group.key.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func getAllGroups() -> [GroupViewModel] {
        var result: [GroupViewModel] = []
        
        // Add root group
        let rootPath = config.getGroupPath(for: config.root)
        result.append(GroupViewModel(
            id: UUID(),
            name: config.root.displayName,
            key: config.root.key ?? "",
            path: rootPath
        ))
        
        // Recursively add all subgroups
        findGroups(in: config.root, result: &result)
        
        return result
    }
    
    private func findGroups(in group: Group, result: inout [GroupViewModel]) {
        for item in group.actions {
            if case .group(let subgroup) = item {
                let path = config.getGroupPath(for: subgroup)
                result.append(GroupViewModel(
                    id: UUID(),
                    name: subgroup.displayName,
                    key: subgroup.key ?? "",
                    path: path
                ))
                findGroups(in: subgroup, result: &result)
            }
        }
    }
}

// Local container for Shortcuts settings
fileprivate struct KeyboardShortcutsView: View {
  @EnvironmentObject private var config: UserConfig
  
  var body: some View {
    Settings.Container(contentWidth: 800.0) {
      Settings.Section(title: "Global Shortcuts") {
        Form {
            KeyboardShortcuts.Recorder("Activate (App-Specific):", name: .activateAppSpecific)
            KeyboardShortcuts.Recorder("Activate (Default Only):", name: .activateDefaultOnly)
        }
        Text("App-Specific tries to use the config for the active app (e.g., app.com.app.bundle.json), falls back to app.default.json, then config.json. Default Only always uses config.json.")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
      }
      
      Settings.Section(title: "For Groups", verticalAlignment: .top) {
        GroupShortcutsView()
      }
    }
  }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
  SPUStandardUserDriverDelegate,
  UNUserNotificationCenterDelegate
{
  var controller: Controller!

  let statusItem = StatusItem()
  let config = UserConfig()
  var fileMonitor: FileMonitor!
  var stealthMode: StealthModeManager?

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
        contentView: { KeyboardShortcutsView().environmentObject(self.config) }
      ),
      Settings.Pane(
        identifier: .advanced, title: "Advanced",
        toolbarIcon: NSImage(named: NSImage.advancedName)!,
        contentView: { AdvancedPane().environmentObject(self.config) }
      ),
    ],
    style: .segmentedControl
  )

  func applicationDidFinishLaunching(_: Notification) {
    guard
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    else { return }
    guard !isRunningTests() else { return }

    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .badge, .sound,
    ]) {
      granted, error in
      if let error = error {
        print("Error requesting notification permission: \(error)")
      }
    }

    NSApp.mainMenu = MainMenu()

    config.ensureAndLoad()
    state = UserState(userConfig: config)
    controller = Controller(userState: state, userConfig: config)
    
    // Initialize stealth mode manager
    stealthMode = StealthModeManager(appDelegate: self)

    Task {
      for await _ in Defaults.updates(.configDir) {
        self.fileMonitor?.stopMonitoring()

        self.fileMonitor = FileMonitor(
          fileURL: config.url,
          callback: {
            self.config.reloadConfig()
          })
        self.fileMonitor.startMonitoring()
      }
    }

    statusItem.handlePreferences = {
      self.settingsWindowController.show()
      NSApp.activate(ignoringOtherApps: true)
    }
    statusItem.handleReloadConfig = {
      self.config.reloadConfig()
    }
    statusItem.handleRevealConfig = {
      NSWorkspace.shared.activateFileViewerSelecting([self.config.url])
    }
    statusItem.handleCheckForUpdates = {
      self.updaterController.checkForUpdates(nil)
    }

    Task {
      for await value in Defaults.updates(.showMenuBarIcon) {
        if value {
          self.statusItem.enable()
        } else {
          self.statusItem.disable()
        }
      }
    }

    // Register new shortcuts
    KeyboardShortcuts.onKeyUp(for: .activateDefaultOnly) { [weak self] in
      guard !Defaults[.useStealthMode] else {
        print("[AppDelegate] StealthMode ON: Ignoring standard KeyboardShortcuts handler for activateDefaultOnly")
        return
      }
      print("[AppDelegate] StealthMode OFF: Handling standard KeyboardShortcuts handler for activateDefaultOnly")
      self?.handleActivation(type: .defaultOnly)
    }

    KeyboardShortcuts.onKeyUp(for: .activateAppSpecific) { [weak self] in
      guard !Defaults[.useStealthMode] else {
        print("[AppDelegate] StealthMode ON: Ignoring standard KeyboardShortcuts handler for activateAppSpecific")
        return
      }
       print("[AppDelegate] StealthMode OFF: Handling standard KeyboardShortcuts handler for activateAppSpecific")
      self?.handleActivation(type: .appSpecificWithFallback)
    }

    registerGroupShortcuts()
    
    Task {
      for await _ in Defaults.updates(.groupShortcuts) {
        self.registerGroupShortcuts()
      }
    }
    
    // Configure stealth mode observer
    Task {
      for await value in Defaults.updates(.useStealthMode) {
        print("[AppDelegate] Stealth mode setting changed via Defaults: \(value)")
        if value {
          print("[AppDelegate] Enabling stealth mode monitoring.")
          self.stealthMode?.startMonitoring()
        } else {
          print("[AppDelegate] Disabling stealth mode monitoring.")
          self.stealthMode?.stopMonitoring()
        }
      }
    }
    
    // Start stealth mode if enabled by default
    if Defaults[.useStealthMode] {
      print("[AppDelegate] Stealth mode is enabled on launch. Starting monitoring.")
      stealthMode?.startMonitoring()
    } else {
       print("[AppDelegate] Stealth mode is disabled on launch.")
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    config.saveCurrentlyEditingConfig()
  }

  @IBAction
  func settingsMenuItemActionHandler(_: NSMenuItem) {
    settingsWindowController.show()
    NSApp.activate(ignoringOtherApps: true)
  }

  func show(type: Controller.ActivationType = .appSpecificWithFallback, completion: (() -> Void)? = nil) {
    controller.show(type: type, completion: completion)
  }

  func hide() {
    controller.hide()
  }

  // Helper function to handle activation logic for both shortcuts
  private func handleActivation(type: Controller.ActivationType) {
    if controller.window.isKeyWindow {
      switch Defaults[.reactivateBehavior] {
      case .hide:
        hide()
      case .reset:
        controller.userState.clear()
        // When resetting, ensure we show with the correct config type again
        show(type: type)
      case .nothing:
        return
      }
    } else if controller.window.isVisible {
      // Should never happen as the window will self-hide when not key
      controller.window.makeKeyAndOrderFront(nil)
    } else {
      show(type: type)
    }
  }

  // MARK: - Sparkle Gentle Reminders

  var supportsGentleScheduledUpdateReminders: Bool {
    return true
  }

  func standardUserDriverWillHandleShowingUpdate(
    _ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem,
    state: SPUUserUpdateState
  ) {
    NSApp.setActivationPolicy(.regular)

    if !state.userInitiated {
      NSApp.dockTile.badgeLabel = "1"

      let content = UNMutableNotificationContent()
      content.title = "Leader Key Update Available"
      content.body = "Version \(update.displayVersionString) is now available"

      let request = UNNotificationRequest(
        identifier: updateLocationIdentifier, content: content,
        trigger: nil)
      UNUserNotificationCenter.current().add(request)
    }
  }

  func standardUserDriverDidReceiveUserAttention(
    forUpdate update: SUAppcastItem
  ) {
    NSApp.dockTile.badgeLabel = ""

    UNUserNotificationCenter.current().removeDeliveredNotifications(
      withIdentifiers: [
        updateLocationIdentifier
      ])
  }

  func standardUserDriverWillFinishUpdateSession() {
    NSApp.setActivationPolicy(.accessory)
  }

  // MARK: - UNUserNotificationCenter Delegate

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.notification.request.identifier
      == updateLocationIdentifier
      && response.actionIdentifier == UNNotificationDefaultActionIdentifier
    {
      updaterController.checkForUpdates(nil)
    }
    completionHandler()
  }

  func isRunningTests() -> Bool {
    let environment = ProcessInfo.processInfo.environment
    guard environment["XCTestSessionIdentifier"] != nil else { return false }
    return true
  }

  // MARK: - URL Scheme Handling

  func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      handleURL(url)
    }
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
        delay(delayMs) { [weak self] in
          self?.controller.handleKey(key)
        }
        delayMs += 100
      }
    }
  }

  // MARK: - Group Shortcuts

  private func registerGroupShortcuts() {
    // Clear existing group shortcuts
    for (groupPath, _) in Defaults[.groupShortcuts] {
      let shortcutName = KeyboardShortcuts.Name.forGroup(groupPath)
      KeyboardShortcuts.disable(shortcutName)
    }
    
    // Register new ones
    for (groupPath, _) in Defaults[.groupShortcuts] {
      let shortcutName = KeyboardShortcuts.Name.forGroup(groupPath)
      KeyboardShortcuts.onKeyUp(for: shortcutName) { [weak self] in
        guard !Defaults[.useStealthMode] else {
            print("[AppDelegate] StealthMode ON: Ignoring standard KeyboardShortcuts handler for group: \(groupPath)")
            return
        }
        print("[AppDelegate] StealthMode OFF: Handling standard KeyboardShortcuts handler for group: \(groupPath)")
        // Original logic when not in stealth mode
        guard let self = self else { return }
        
        // Open LeaderKey and navigate to the specific group
        if let group = self.config.findGroupByPath(groupPath) {
          if self.controller.window.isKeyWindow {
            // If already open, just navigate to the group
            self.controller.userState.clear()
            self.controller.userState.navigateToGroupPath(group)
          } else {
            // Navigate to the group before showing the window
            self.controller.userState.clear()
            self.controller.userState.navigateToGroupPath(group)
            // Then show the window
            self.show()
          }
        } else {
          self.show()
        }
      }
    }
  }

  // Add public method for activation that can be called from StealthModeManager
  func activateWithType(_ type: Controller.ActivationType) {
    handleActivation(type: type)
  }
}
