import Cocoa
import QuartzCore
import SwiftUI

class PanelWindow: NSPanel {
  init(contentRect: NSRect) {
    super.init(
      contentRect: contentRect,
      styleMask: [.nonactivatingPanel],
      backing: .buffered, defer: false
    )

    isFloatingPanel = true
    isReleasedWhenClosed = false
    animationBehavior = .none
    backgroundColor = .clear
    isOpaque = false
  }
}

class MainWindow: PanelWindow, NSWindowDelegate {
  override var acceptsFirstResponder: Bool { return true }
  override var canBecomeKey: Bool { return false }
  override var canBecomeMain: Bool { return false }

  var hasCheatsheet: Bool { return true }
  var controller: Controller

  required init(controller: Controller) {
    self.controller = controller
    super.init(contentRect: NSRect())
    self.level = .statusBar
  }

  init(controller: Controller, contentRect: NSRect) {
    self.controller = controller
    super.init(contentRect: contentRect)
    delegate = self
    self.level = .statusBar
  }

  func windowDidResignKey(_ notification: Notification) {
    controller.hide()
  }

  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    if event.modifierFlags.contains(.command) {
      controller.keyDown(with: event)
      return true
    }
    return false
  }

  override func keyDown(with event: NSEvent) {
    controller.keyDown(with: event)
  }

  func show(after: (() -> Void)?) {
    makeKeyAndOrderFront(nil)
    after?()
  }

  func hide(after: (() -> Void)?) {
    close()
    after?()
  }

  func notFound() {
  }

  func cheatsheetOrigin(cheatsheetSize: NSSize) -> NSPoint {
    return NSPoint(x: 0, y: 0)
  }
}
