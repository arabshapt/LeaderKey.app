import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import Sparkle
import SwiftUI
import UserNotifications

let updateLocationIdentifier = "UpdateCheck"

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
      Settings.Section(title: "Global Shortcut") {
        KeyboardShortcuts.Recorder(for: .activate)
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

    KeyboardShortcuts.onKeyUp(for: .activate) {
      if self.controller.window.isKeyWindow {
        switch Defaults[.reactivateBehavior] {
        case .hide:
          self.hide()
        case .reset:
          self.controller.userState.clear()
        case .nothing:
          return
        }
      } else if self.controller.window.isVisible {
        // should never happen as the window will self-hide when not key
        self.controller.window.makeKeyAndOrderFront(nil)
      } else {
        self.show()
      }
    }
    
    registerGroupShortcuts()
    
    Task {
      for await _ in Defaults.updates(.groupShortcuts) {
        self.registerGroupShortcuts()
      }
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    config.saveConfig()
  }

  @IBAction
  func settingsMenuItemActionHandler(_: NSMenuItem) {
    settingsWindowController.show()
    NSApp.activate(ignoringOtherApps: true)
  }

  func show(completion: (() -> Void)? = nil) {
    controller.show(completion: completion)
  }

  func hide() {
    controller.hide()
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
}
