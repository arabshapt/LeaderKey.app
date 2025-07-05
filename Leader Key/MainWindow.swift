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
    // controller.hide() // Remove this line
  }

  // Helper function to create a readable string for modifier flags (duplicated from AppDelegate)
  private func describeModifiers(_ modifiers: NSEvent.ModifierFlags) -> String {
      var parts: [String] = []
      if modifiers.contains(.command) { parts.append("Cmd") }
      if modifiers.contains(.option) { parts.append("Opt") }
      if modifiers.contains(.control) { parts.append("Ctrl") }
      if modifiers.contains(.shift) { parts.append("Shift") }
      if modifiers.contains(.capsLock) { parts.append("CapsLock") }
      if parts.isEmpty { return "[None]" }
      return "[" + parts.joined(separator: "][") + "]"
  }

  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    print("[MainWindow] performKeyEquivalent received: mods: \(describeModifiers(event.modifierFlags)), chars: \(event.charactersIgnoringModifiers ?? "nil")")
    if event.modifierFlags.contains(.command) {
      controller.keyDown(with: event)
      return true
    }
    return false
  }

  override func keyDown(with event: NSEvent) {
    controller.keyDown(with: event)
  }

  func show(at origin: NSPoint? = nil, after: (() -> Void)? = nil) {
    // 1. Determine the final origin
    let finalOrigin: NSPoint
    if let newOrigin = origin {
        finalOrigin = newOrigin
        print("[MainWindow show(at:)] Using provided origin: \(newOrigin)")
    } else {
        self.center()
        finalOrigin = frame.origin
        print("[MainWindow show(at:)] Centered origin: \(finalOrigin)")
    }

    // 2. Build off-screen & invisible
    alphaValue = 0
    setFrameOrigin(finalOrigin)

    // Force layout / drawing so SwiftUI completes its first pass before we reveal the window
    displayIfNeeded()                    // AppKit pass
    contentView?.layoutSubtreeIfNeeded() // SwiftUI pass

    // 3. Show instantly without flicker
    alphaValue = 1
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
