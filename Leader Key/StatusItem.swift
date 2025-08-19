import Cocoa
import Combine
import Sparkle

class StatusItem {
  enum Appearance {
    case normal
    case active
  }

  var appearance: Appearance = .normal {
    didSet {
      updateStatusItemAppearance()
    }
  }

  var statusItem: NSStatusItem?
  private var cancellables = Set<AnyCancellable>()

  var handlePreferences: (() -> Void)?
  var handleReloadConfig: (() -> Void)?
  var handleRevealConfig: (() -> Void)?
  var handleCheckForUpdates: (() -> Void)?
  var handleForceReset: (() -> Void)?
  
  // Developer Tools handlers
  var handleNodeJSStressTest: (() -> Void)?
  var handleIntelliJStressTest: (() -> Void)?
  var handleRecoveryUnderStress: (() -> Void)?
  var handleShowRecoveryStatistics: (() -> Void)?

  func enable() {
    statusItem = NSStatusBar.system.statusItem(
      withLength: NSStatusItem.squareLength)

    guard let item = statusItem else {
      print("No status item")
      return
    }

    if let menubarButton = item.button {
      menubarButton.image = NSImage(named: NSImage.Name("StatusItem"))
    }

    let menu = NSMenu()

    let preferencesItem = NSMenuItem(
      title: "Preferences…", action: #selector(showPreferences),
      keyEquivalent: ","
    )
    preferencesItem.target = self
    menu.addItem(preferencesItem)

    menu.addItem(NSMenuItem.separator())

    let checkForUpdatesItem = NSMenuItem(
      title: "Check for Updates...", action: #selector(checkForUpdates),
      keyEquivalent: ""
    )
    checkForUpdatesItem.target = self
    menu.addItem(checkForUpdatesItem)

    menu.addItem(NSMenuItem.separator())

    let revealConfigItem = NSMenuItem(
      title: "Show config in Finder", action: #selector(revealConfigFile),
      keyEquivalent: ""
    )
    revealConfigItem.target = self
    menu.addItem(revealConfigItem)

    let reloadConfigItem = NSMenuItem(
      title: "Reload config", action: #selector(reloadConfig), keyEquivalent: ""
    )
    reloadConfigItem.target = self
    menu.addItem(reloadConfigItem)

    let forceResetItem = NSMenuItem(
      title: "Force reset", action: #selector(forceReset), keyEquivalent: ""
    )
    forceResetItem.target = self
    menu.addItem(forceResetItem)

    menu.addItem(NSMenuItem.separator())

    // Developer Tools submenu
    let developerToolsItem = NSMenuItem(
      title: "Developer Tools", action: nil, keyEquivalent: ""
    )
    let developerToolsSubmenu = NSMenu()
    
    let nodeJSTestItem = NSMenuItem(
      title: "NodeJS Scenario Test", action: #selector(runNodeJSStressTest), keyEquivalent: ""
    )
    nodeJSTestItem.target = self
    developerToolsSubmenu.addItem(nodeJSTestItem)
    
    let intelliJTestItem = NSMenuItem(
      title: "IntelliJ Scenario Test", action: #selector(runIntelliJStressTest), keyEquivalent: ""
    )
    intelliJTestItem.target = self
    developerToolsSubmenu.addItem(intelliJTestItem)
    
    let recoveryTestItem = NSMenuItem(
      title: "🔥 Test Recovery Under Stress", action: #selector(testRecoveryUnderStress), keyEquivalent: ""
    )
    recoveryTestItem.target = self
    developerToolsSubmenu.addItem(recoveryTestItem)
    
    developerToolsSubmenu.addItem(NSMenuItem.separator())
    
    let recoveryStatsItem = NSMenuItem(
      title: "📊 Show Recovery Statistics", action: #selector(showRecoveryStatistics), keyEquivalent: ""
    )
    recoveryStatsItem.target = self
    developerToolsSubmenu.addItem(recoveryStatsItem)
    
    developerToolsItem.submenu = developerToolsSubmenu
    menu.addItem(developerToolsItem)

    menu.addItem(NSMenuItem.separator())

    menu.addItem(
      NSMenuItem(
        title: "Quit Leader Key",
        action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"
      ))

    item.menu = menu

    updateStatusItemAppearance()

    Events.sink { event in
      switch event {
      case .willActivate:
        self.appearance = .active
        case .willDeactivate:
        self.appearance = .normal
      default:
        break
      }
    }.store(in: &cancellables)

  }

  func disable() {
    guard let item = statusItem else { return }

    cancellables.removeAll()
    NSStatusBar.system.removeStatusItem(item)
    statusItem = nil
  }

  @objc func showPreferences() {
    handlePreferences?()
  }

  @objc func reloadConfig() {
    handleReloadConfig?()
  }

  @objc func revealConfigFile() {
    handleRevealConfig?()
  }

  @objc func checkForUpdates() {
    handleCheckForUpdates?()
  }

  @objc func forceReset() {
    handleForceReset?()
  }

  @objc func runNodeJSStressTest() {
    handleNodeJSStressTest?()
  }

  @objc func runIntelliJStressTest() {
    handleIntelliJStressTest?()
  }

  @objc func testRecoveryUnderStress() {
    handleRecoveryUnderStress?()
  }

  @objc func showRecoveryStatistics() {
    handleShowRecoveryStatistics?()
  }

  private func updateStatusItemAppearance() {
    guard let button = statusItem?.button else { return }

    switch appearance {
    case .normal:
      button.image = NSImage(named: NSImage.Name("StatusItem"))
    case .active:
      button.image = NSImage(named: NSImage.Name("StatusItem-filled"))
    }
  }
}
