import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import Sparkle
import SwiftUI
import UserNotifications

let updateLocationIdentifier = "UpdateCheck"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
  SPUStandardUserDriverDelegate,
  UNUserNotificationCenterDelegate
{
  var controller: Controller!

  let statusItem = StatusItem()
  let config = UserConfig()
  var fileMonitor: FileMonitor!

  var booting = true

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
        identifier: .advanced, title: "Advanced",
        toolbarIcon: NSImage(named: NSImage.advancedName)!,
        contentView: {
          AdvancedPane().environmentObject(self.config)
        }),
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
        self.hide()
      } else if self.controller.window.isVisible {
        // should never happen as the window will self-hide when not key
        self.controller.window.makeKeyAndOrderFront(nil)
      } else {
        self.show()
      }
    }
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    // If this is the first activation, don't show as we're just booting the app
    if booting {
      booting = false
    } else if settingsWindowController.window?.isVisible == true {
      // nothing
    } else {
      // If activated again, user ran the app twice so show the window
      controller.show()
    }
  }

func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
        handleIncomingURL(url)
    }
}

private func handleIncomingURL(_ url: URL) {
    print("Handling URL: \(url.absoluteString)")
    guard url.scheme?.lowercased() == "leaderkey" else { 
        print("Invalid scheme: \(url.scheme ?? "nil")")
        return 
    }
    
    // Check if this is a group URL by looking at the host
    if url.host?.lowercased() == "group" {
        // Get all path components after the host
        let pathComponents = url.pathComponents
        print("URL components: \(pathComponents)")
        
        if pathComponents.count >= 2 {
            // Remove the first component which is "/"
            let groupPath = Array(pathComponents.dropFirst())
            print("Group path: \(groupPath)")
            
            // Notify the app to navigate to the specified group path
            DispatchQueue.main.async {
                print("Posting NavigateToGroup notification with path: \(groupPath)")
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavigateToGroup"),
                    object: nil,
                    userInfo: ["groupPath": groupPath]
                )
            }
        } else {
            print("Missing group path in URL")
        }
    } else {
        print("Invalid URL host: \(url.host ?? "nil"), expected 'group'")
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

  func show() {
    controller.show()
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
}
