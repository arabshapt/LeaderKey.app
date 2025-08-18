import Cocoa

class MainMenu: NSMenu {
  init() {
    super.init(title: "MainMenu")

    let appMenu = NSMenuItem()
    appMenu.submenu = NSMenu(title: "Leader Key")
    appMenu.submenu?.items = [
      NSMenuItem(
        title: "About Leader Key",
        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""),
      .separator(),
      NSMenuItem(
        title: "Preferences...", action: #selector(AppDelegate.settingsMenuItemActionHandler(_:)),
        keyEquivalent: ","),
      .separator(),
      NSMenuItem(
        title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"),
      .separator(),
      NSMenuItem(
        title: "Quit Leader Key", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"
      )
    ]

    let editMenu = NSMenuItem()
    editMenu.submenu = NSMenu(title: "Edit")
    editMenu.submenu?.items = [
      NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"),
      NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z"),
      .separator(),
      NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
      NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
      NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"),
      NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
    ]

    let debugMenu = NSMenuItem()
    debugMenu.submenu = NSMenu(title: "Debug")
    debugMenu.submenu?.items = [
      NSMenuItem(
        title: "Quick Stress Test", 
        action: #selector(AppDelegate.runQuickStressTest(_:)), 
        keyEquivalent: "t"),
      NSMenuItem(
        title: "NodeJS Scenario Test", 
        action: #selector(AppDelegate.runNodeJSStressTest(_:)), 
        keyEquivalent: ""),
      NSMenuItem(
        title: "IntelliJ Scenario Test", 
        action: #selector(AppDelegate.runIntelliJStressTest(_:)), 
        keyEquivalent: ""),
      .separator(),
      NSMenuItem(
        title: "Comprehensive Test Suite", 
        action: #selector(AppDelegate.runComprehensiveStressTests(_:)), 
        keyEquivalent: "T"),
      .separator(),
      NSMenuItem(
        title: "⚠️ Extreme Stress Tests", 
        action: #selector(AppDelegate.runExtremeStressTests(_:)), 
        keyEquivalent: ""),
      NSMenuItem(
        title: "🔥 System Exhaustion Test", 
        action: #selector(AppDelegate.runSystemExhaustionTest(_:)), 
        keyEquivalent: ""),
      .separator(),
      NSMenuItem(
        title: "⏱️ 24-Hour Stability Test", 
        action: #selector(AppDelegate.run24HourStabilityTest(_:)), 
        keyEquivalent: ""),
      NSMenuItem(
        title: "🔋 48-Hour Endurance Test", 
        action: #selector(AppDelegate.run48HourEnduranceTest(_:)), 
        keyEquivalent: ""),
      .separator(),
      NSMenuItem(
        title: "Watchdog Status", 
        action: #selector(AppDelegate.showWatchdogStatus(_:)), 
        keyEquivalent: ""),
      NSMenuItem(
        title: "Memory Breakdown Report", 
        action: #selector(AppDelegate.showMemoryBreakdown(_:)), 
        keyEquivalent: "M"),
      NSMenuItem(
        title: "Memory Locking Status", 
        action: #selector(AppDelegate.showMemoryLockingStatus(_:)), 
        keyEquivalent: "L"),
    ]

    items = [appMenu, editMenu, debugMenu]
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
