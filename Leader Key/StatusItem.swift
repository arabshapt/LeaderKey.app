import Cocoa
import Combine
import Defaults
import Sparkle

class StatusItem {
  enum Appearance {
    case normal
    case active
  }

  enum ResolvedAppearance: Equatable {
    case normal
    case active
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
  private(set) var renderedAppearance: ResolvedAppearance = .normal
  private var cancellables = Set<AnyCancellable>()
  private var reloadSuccessResetWorkItem: DispatchWorkItem?

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
  }

  func indicateReloadSuccess() {
    performOnMain {
      guard let button = self.feedbackButton() else { return }

      let shouldPlaySound = !self.isShowingReloadSuccessFeedback
      self.reloadSuccessResetWorkItem?.cancel()
      self.isShowingReloadSuccessFeedback = true
      self.updateStatusItemAppearance()

      button.alphaValue = 0.76
      self.animate(button: button, toAlpha: 1.0, duration: self.reloadSuccessFeedbackTiming.fadeDuration)

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
          self.animate(button: button, toAlpha: 1.0, duration: self.reloadSuccessFeedbackTiming.fadeDuration)
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

    guard let button = feedbackButton() else { return }

    button.image = image(for: resolvedAppearance)

    switch resolvedAppearance {
    case .normal, .active:
      button.contentTintColor = nil
    case .reloadSuccess:
      button.contentTintColor = NSColor.systemGreen
    }
  }

  private func currentResolvedAppearance() -> ResolvedAppearance {
    if isShowingReloadSuccessFeedback {
      return .reloadSuccess
    }

    switch appearance {
    case .normal:
      return .normal
    case .active:
      return .active
    }
  }

  private func image(for appearance: ResolvedAppearance) -> NSImage? {
    switch appearance {
    case .normal:
      return NSImage(named: NSImage.Name("StatusItem"))
    case .active, .reloadSuccess:
      return NSImage(named: NSImage.Name("StatusItem-filled"))
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
