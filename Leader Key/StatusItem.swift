import Cocoa
import Combine
import Defaults
import Sparkle

class StatusItem {
  enum Appearance {
    case normal
    case active
  }

  enum NormalModeStatus: Equatable {
    case inactive
    case normal
    case input
  }

  enum ResolvedAppearance: Equatable {
    case normal
    case leaderMode
    case stickyMode
    case normalMode
    case normalInputMode
    case reloadSuccess
  }

  struct ReloadSuccessFeedbackTiming {
    var fadeDuration: TimeInterval = 0.18
    var holdDuration: TimeInterval = 0.38
  }

  var appearance: Appearance = .normal {
    didSet {
      updateStatusItemAppearance()
    }
  }

  var statusItem: NSStatusItem?
  var reloadSuccessFeedbackTiming = ReloadSuccessFeedbackTiming()
  private(set) var isShowingReloadSuccessFeedback = false
  var normalModeStatus: NormalModeStatus = .inactive {
    didSet {
      updateStatusItemAppearance()
    }
  }
  var normalModeActive: Bool {
    get { normalModeStatus != .inactive }
    set { normalModeStatus = newValue ? .normal : .inactive }
  }
  var stickyModeActive = false {
    didSet {
      updateStatusItemAppearance()
    }
  }
  private(set) var renderedAppearance: ResolvedAppearance = .normal
  private var cancellables = Set<AnyCancellable>()
  private var reloadSuccessResetWorkItem: DispatchWorkItem?
  private var modeStatusMenuItem: NSMenuItem?

  var handlePreferences: (() -> Void)?
  var handleReloadConfig: (() -> Void)?
  var handleRevealConfig: (() -> Void)?
  var handleCheckForUpdates: (() -> Void)?
  var handleForceReset: (() -> Void)?
  var handleShowPerformanceStats: (() -> Void)?

  func enable() {
    statusItem = NSStatusBar.system.statusItem(
      withLength: NSStatusItem.squareLength)

    guard let item = statusItem else {
      print("No status item")
      return
    }

    if let menubarButton = item.button {
      menubarButton.image = NSImage(named: NSImage.Name("StatusItem"))
      menubarButton.alphaValue = 1.0
      menubarButton.contentTintColor = nil
    }

    let menu = NSMenu()

    let modeStatusItem = NSMenuItem(
      title: "Mode: Idle", action: nil, keyEquivalent: ""
    )
    modeStatusItem.isEnabled = false
    modeStatusMenuItem = modeStatusItem
    menu.addItem(modeStatusItem)
    menu.addItem(NSMenuItem.separator())

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

    // Add performance stats menu item (only in debug builds)
    #if DEBUG
      let performanceStatsItem = NSMenuItem(
        title: "Show Performance Stats", action: #selector(showPerformanceStats), keyEquivalent: ""
      )
      performanceStatsItem.target = self
      menu.addItem(performanceStatsItem)
    #endif

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

    cancelReloadSuccessFeedback()
    cancellables.removeAll()
    NSStatusBar.system.removeStatusItem(item)
    statusItem = nil
    modeStatusMenuItem = nil
  }

  func indicateReloadSuccess() {
    performOnMain {
      guard let button = self.feedbackButton() else { return }

      let shouldPlaySound = !self.isShowingReloadSuccessFeedback
      self.reloadSuccessResetWorkItem?.cancel()
      self.isShowingReloadSuccessFeedback = true
      self.updateStatusItemAppearance()

      button.alphaValue = 0.76
      self.animate(
        button: button,
        toAlpha: 1.0,
        duration: self.reloadSuccessFeedbackTiming.fadeDuration
      )

      if shouldPlaySound {
        self.playReloadSuccessSoundIfNeeded()
      }

      let restoreWorkItem = DispatchWorkItem { [weak self, weak button] in
        guard let self, let button else { return }

        self.animate(
          button: button,
          toAlpha: 0.84,
          duration: self.reloadSuccessFeedbackTiming.fadeDuration
        ) { [weak self, weak button] in
          guard let self, let button else { return }

          self.isShowingReloadSuccessFeedback = false
          self.reloadSuccessResetWorkItem = nil
          self.updateStatusItemAppearance()
          self.animate(
            button: button,
            toAlpha: 1.0,
            duration: self.reloadSuccessFeedbackTiming.fadeDuration
          )
        }
      }

      self.reloadSuccessResetWorkItem = restoreWorkItem
      self.scheduleReloadSuccessReset(
        after: self.reloadSuccessFeedbackTiming.holdDuration,
        workItem: restoreWorkItem
      )
    }
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

  @objc func showPerformanceStats() {
    handleShowPerformanceStats?()
  }

  private func updateStatusItemAppearance() {
    let resolvedAppearance = currentResolvedAppearance()
    renderedAppearance = resolvedAppearance

    modeStatusMenuItem?.title = menuTitle(for: resolvedAppearance)

    guard let button = feedbackButton() else { return }

    button.image = image(for: resolvedAppearance)
    button.toolTip = tooltip(for: resolvedAppearance)
    button.contentTintColor = nil
  }

  private func currentResolvedAppearance() -> ResolvedAppearance {
    if isShowingReloadSuccessFeedback {
      return .reloadSuccess
    }

    if stickyModeActive {
      return .stickyMode
    }

    if appearance == .active {
      return .leaderMode
    }

    switch normalModeStatus {
    case .inactive:
      return .normal
    case .normal:
      return .normalMode
    case .input:
      return .normalInputMode
    }
  }

  private func image(for appearance: ResolvedAppearance) -> NSImage? {
    modeImage(for: appearance)
  }

  private func modeImage(for appearance: ResolvedAppearance) -> NSImage {
    let visual = modeVisual(for: appearance)
    let size = NSSize(width: 18, height: 18)
    let image = NSImage(size: size)

    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()

    let badgeRect = NSRect(x: 2, y: 2, width: 14, height: 14)
    let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: 4, yRadius: 4)
    visual.fillColor.setFill()
    badgePath.fill()

    if let strokeColor = visual.strokeColor {
      strokeColor.setStroke()
      badgePath.lineWidth = 1
      badgePath.stroke()
    }

    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 10, weight: .bold),
      .foregroundColor: visual.textColor,
    ]
    let textSize = visual.label.size(withAttributes: attributes)
    let textOrigin = NSPoint(
      x: floor((size.width - textSize.width) / 2),
      y: floor((size.height - textSize.height) / 2) - 1
    )
    visual.label.draw(at: textOrigin, withAttributes: attributes)

    image.unlockFocus()
    image.isTemplate = false
    return image
  }

  private func modeVisual(for appearance: ResolvedAppearance) -> (
    label: String,
    fillColor: NSColor,
    strokeColor: NSColor?,
    textColor: NSColor
  ) {
    switch appearance {
    case .normal:
      return (
        label: "K",
        fillColor: NSColor.windowBackgroundColor,
        strokeColor: NSColor.secondaryLabelColor,
        textColor: NSColor.labelColor
      )
    case .leaderMode:
      return (
        label: "L",
        fillColor: NSColor.systemOrange,
        strokeColor: nil,
        textColor: NSColor.white
      )
    case .stickyMode:
      return (
        label: "S",
        fillColor: NSColor.systemPurple,
        strokeColor: nil,
        textColor: NSColor.white
      )
    case .normalMode:
      return (label: "N", fillColor: NSColor.systemBlue, strokeColor: nil, textColor: NSColor.white)
    case .normalInputMode:
      return (label: "I", fillColor: NSColor.systemTeal, strokeColor: nil, textColor: NSColor.white)
    case .reloadSuccess:
      return (
        label: "R",
        fillColor: NSColor.systemGreen,
        strokeColor: nil,
        textColor: NSColor.white
      )
    }
  }

  private func menuTitle(for appearance: ResolvedAppearance) -> String {
    "Mode: \(modeName(for: appearance))"
  }

  private func tooltip(for appearance: ResolvedAppearance) -> String {
    "Leader Key: \(modeName(for: appearance))"
  }

  private func modeName(for appearance: ResolvedAppearance) -> String {
    switch appearance {
    case .normal:
      return "Idle"
    case .leaderMode:
      return "Leader"
    case .stickyMode:
      return "Sticky"
    case .normalMode:
      return "Normal"
    case .normalInputMode:
      return "Input"
    case .reloadSuccess:
      return "Config Reloaded"
    }
  }

  private func cancelReloadSuccessFeedback() {
    reloadSuccessResetWorkItem?.cancel()
    reloadSuccessResetWorkItem = nil
    isShowingReloadSuccessFeedback = false
    if let button = feedbackButton() {
      button.alphaValue = 1.0
    }
    updateStatusItemAppearance()
  }

  func feedbackButton() -> NSButton? {
    statusItem?.button
  }

  func performOnMain(_ work: @escaping () -> Void) {
    DispatchQueue.main.async(execute: work)
  }

  func scheduleReloadSuccessReset(after delay: TimeInterval, workItem: DispatchWorkItem) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  func playReloadSuccessSoundIfNeeded() {
    guard let soundName = Defaults[.reloadSuccessSound].soundName else { return }
    NSSound(named: soundName)?.play()
  }

  func animate(
    button: NSButton,
    toAlpha alphaValue: CGFloat,
    duration: TimeInterval,
    completion: (() -> Void)? = nil
  ) {
    guard duration > 0 else {
      button.alphaValue = alphaValue
      completion?()
      return
    }

    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = duration
        button.animator().alphaValue = alphaValue
      },
      completionHandler: {
        completion?()
      }
    )
  }
}
