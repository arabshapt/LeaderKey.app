import Cocoa
import Combine
import Defaults
import SwiftUI

enum KeyHelpers: UInt16 {
  case enter = 36
  case tab = 48
  case space = 49
  case backspace = 51
  case escape = 53
}

class Controller {
  var userState: UserState
  var userConfig: UserConfig

  var window: MainWindow!
  var cheatsheetWindow: NSWindow!
  private var cheatsheetTimer: Timer?

  private var cancellables = Set<AnyCancellable>()

init(userState: UserState, userConfig: UserConfig) {
    self.userState = userState
    self.userConfig = userConfig

    Task {
        for await value in Defaults.updates(.theme) {
            let windowClass = Theme.classFor(value)
            self.window = await windowClass.init(controller: self)
        }
    }
    
// In the init method
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleNavigateToGroup(_:)),
    name: NSNotification.Name("NavigateToGroup"),
    object: nil
)

    Events.sink { event in
      switch event {
      case .didReload:
        // This should all be handled by the themes
        self.userState.isShowingRefreshState = true
        self.show()
        // Delay for 4 * 300ms to wait for animation to be noticeable
        delay(Int(Pulsate.singleDurationS * 1000) * 3) {
          self.hide()
          self.userState.isShowingRefreshState = false
        }
      default: break
      }
    }.store(in: &cancellables)

    self.cheatsheetWindow = Cheatsheet.createWindow(for: userState)
  }

  func show() {
    Events.send(.willActivate)

    window.show {
      Events.send(.didActivate)
    }

    switch Defaults[.autoOpenCheatsheet] {
    case .always:
      if !userState.isShowingRefreshState { showCheatsheet() }
    case .delay:
      if !userState.isShowingRefreshState { scheduleCheatsheet() }
    default: break
    }
  }

  func hide(afterClose: (() -> Void)? = nil) {
    Events.send(.willDeactivate)

    window.hide {
      self.clear()
      afterClose?()
      Events.send(.didDeactivate)
    }

    cheatsheetWindow?.orderOut(nil)
    cheatsheetTimer?.invalidate()
  }

  func keyDown(with event: NSEvent) {
    // Reset the delay timer
    if Defaults[.autoOpenCheatsheet] == .delay {
      scheduleCheatsheet()
    }

    if event.modifierFlags.contains(.command) {
      switch event.charactersIgnoringModifiers {
      case ",":
        NSApp.sendAction(
          #selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil,
          from: nil)
        hide()
        return
      case "w":
        hide()
        return
      case "q":
        NSApp.terminate(nil)
        return
      default:
        break
      }
    }

    switch event.keyCode {
    case KeyHelpers.backspace.rawValue:
      clear()
    case KeyHelpers.escape.rawValue:
      hide()
    default:
      let char = charForEvent(event)

      if char == "?" {
        showCheatsheet()
        return
      }

      let list =
        (userState.currentGroup != nil)
        ? userState.currentGroup : userConfig.root

      let hit = list?.actions.first { item in
        switch item {
        case .group(let group):
          if group.key == char {
            return true
          }
        case .action(let action):
          if action.key == char {
            return true
          }
        }
        return false
      }

      switch hit {
      case .action(let action):
        hide {
          self.runAction(action)
        }
      case .group(let group):
        if shouldRunGroupSequence(event) {
          hide {
            self.runGroup(group)
          }
        } else {
          userState.display = group.key
          userState.currentGroup = group
        }
      case .none:
        window.notFound()
      }
    }

    // Why do we need to wait here?
    delay(1) {
      self.positionCheatsheetWindow()
    }
  }

  private func shouldRunGroupSequence(_ event: NSEvent) -> Bool {
    let selectedModifier = Defaults[.modifierKeyForGroupSequence]
    guard let modifierFlag = selectedModifier.flag else {
      return false
    }
    return event.modifierFlags.contains(modifierFlag)
  }

  private func charForEvent(_ event: NSEvent) -> String? {
    if Defaults[.forceEnglishKeyboardLayout] {
      if let mapped = englishKeymap[event.keyCode] {
        // Check if Shift is pressed and convert to uppercase if so
        if event.modifierFlags.contains(.shift) {
          return mapped.uppercased()
        }

        return mapped
      }
    }

    return event.charactersIgnoringModifiers
  }

  private func positionCheatsheetWindow() {
    guard let mainWindow = window, let cheatsheet = cheatsheetWindow else {
      return
    }

    cheatsheet.setFrameOrigin(
      mainWindow.cheatsheetOrigin(cheatsheetSize: cheatsheet.frame.size))
  }

  private func showCheatsheet() {
    positionCheatsheetWindow()
    cheatsheetWindow?.orderFront(nil)
  }

  private func scheduleCheatsheet() {
    cheatsheetTimer?.invalidate()

    cheatsheetTimer = Timer.scheduledTimer(
      withTimeInterval: Double(Defaults[.cheatsheetDelayMS]) / 1000.0, repeats: false
    ) { [weak self] _ in
      self?.showCheatsheet()
    }
  }

  private func runGroup(_ group: Group) {
    for groupOrAction in group.actions {
      switch groupOrAction {
      case .group(let group):
        runGroup(group)
      case .action(let action):
        runAction(action)
      }
    }
  }

  private func runAction(_ action: Action) {
    switch action.type {
    case .application:
      NSWorkspace.shared.openApplication(
        at: URL(fileURLWithPath: action.value),
        configuration: NSWorkspace.OpenConfiguration())
    case .url:
      openURL(action)
    case .command:
      CommandRunner.run(action.value)
    case .folder:
      let path: String = (action.value as NSString).expandingTildeInPath
      NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
    default:
      print("\(action.type) unknown")
    }
  }

  private func clear() {
    userState.clear()
  }

  private func openURL(_ action: Action) {
    guard let url = URL(string: action.value) else {
      showAlert(
        title: "Invalid URL", message: "Failed to parse URL: \(action.value)")
      return
    }

    guard let scheme = url.scheme else {
      showAlert(
        title: "Invalid URL",
        message:
          "URL is missing protocol (e.g. https://, raycast://): \(action.value)"
      )
      return
    }

    if scheme == "http" || scheme == "https" {
      NSWorkspace.shared.open(
        url,
        configuration: NSWorkspace.OpenConfiguration())
    } else {
      NSWorkspace.shared.open(
        url,
        configuration: DontActivateConfiguration.shared.configuration)
    }
  }

  private func showAlert(title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
  // ...existing code...

 @objc private func handleNavigateToGroup(_ notification: Notification) {
    print("Received NavigateToGroup notification")
    guard let userInfo = notification.userInfo else {
        print("Missing userInfo in notification")
        return
    }
    
    // Handle both legacy single key and new path-based navigation
    if let groupKey = userInfo["groupKey"] as? String {
        navigateToGroupByKey(groupKey)
    } else if let groupPath = userInfo["groupPath"] as? [String] {
        navigateToGroupByPath(groupPath)
    } else {
        print("Missing or invalid group identifiers in notification")
    }
}

private func navigateToGroupByKey(_ groupKey: String) {
    print("Looking for group with key: \(groupKey)")
    if let group = findGroupByKey(groupKey, in: userConfig.root) {
        print("Found group: \(group.key)")
        // Show the app window
        show()
        
        // Navigate to the group
        userState.display = group.key
        userState.currentGroup = group
        print("Group navigation completed")
    } else {
        print("No group found with key: \(groupKey)")
    }
}

private func navigateToGroupByPath(_ groupPath: [String]) {
    print("Looking for group with path: \(groupPath)")
    
    // Start at the root group
    var currentGroup = userConfig.root
    
    // Navigate through each component of the path
    for (index, key) in groupPath.enumerated() {
        if let nextGroup = findDirectChildGroupByKey(key, in: currentGroup) {
            currentGroup = nextGroup
            
            // If we've reached the end of the path, select this group
            if index == groupPath.count - 1 {
                print("Found target group: \(nextGroup.key)")
                show()
                userState.display = nextGroup.key
                userState.currentGroup = nextGroup
                print("Group navigation completed")
                return
            }
        } else {
            print("Could not find group with key '\(key)' at path level \(index)")
            return
        }
    }
}

private func findDirectChildGroupByKey(_ key: String, in parentGroup: Group?) -> Group? {
    print("Looking for direct child '\(key)' in group: \(parentGroup?.key ?? "root")")
    guard let parent = parentGroup else { return nil }
    
    // Debug: print all available child group keys
    let childKeys = parent.actions.compactMap { action -> String? in
        if case let .group(subgroup) = action {
            return subgroup.key
        }
        return nil
    }
    print("Available child groups: \(childKeys)")
    
    // Search only through direct children
    for action in parent.actions {
        if case let .group(subgroup) = action, subgroup.key == key {
            return subgroup
        }
    }
    
    return nil
}

private func findGroupByKey(_ key: String, in parentGroup: Group?) -> Group? {
  guard let parent = parentGroup else { return nil }
  
  // Check if this is the group we're looking for
  if parent.key == key {
    return parent
  }
  
  // Search through subgroups
  for case let .group(subgroup) in parent.actions {
    if let found = findGroupByKey(key, in: subgroup) {
      return found
    }
  }
  
  return nil
}
}

class DontActivateConfiguration {
  // ...existing code...
  let configuration = NSWorkspace.OpenConfiguration()

  static var shared = DontActivateConfiguration()

  init() {
    configuration.activates = false
  }
}
