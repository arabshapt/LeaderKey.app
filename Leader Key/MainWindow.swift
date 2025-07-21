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

    // 2. Apply cached size if available
    if let currentGroup = controller.userState.currentGroup ?? controller.userState.activeRoot,
       let cachedSize = ViewSizeCache.shared.size(for: currentGroup) {
        print("[MainWindow show] Using cached size: \(cachedSize)")
        setContentSize(cachedSize)
    }

    // 3. Build off-screen & invisible to measure if needed
    alphaValue = 0
    setFrameOrigin(finalOrigin)

    // Force layout / drawing so SwiftUI completes its first pass
    displayIfNeeded()                    // AppKit pass
    contentView?.layoutSubtreeIfNeeded() // SwiftUI pass

    // 4. If no cache yet, store measured size
    if let currentGroup = controller.userState.currentGroup ?? controller.userState.activeRoot,
       ViewSizeCache.shared.size(for: currentGroup) == nil {
        let measured = contentView?.fittingSize ?? frame.size
        ViewSizeCache.shared.store(measured, for: currentGroup)
        print("[MainWindow show] Cached size: \(measured)")
    }

    // 5. Execute completion, then reveal
    after?()

    // Reveal on next run loop cycle after any state updates from the completion have laid out.
    DispatchQueue.main.async {
        // Force layout once more to capture any changes made in the completion (e.g., header update)
        self.displayIfNeeded()
        self.contentView?.layoutSubtreeIfNeeded()

        self.alphaValue = 1
        self.makeKeyAndOrderFront(nil)
    }
  }

  func hide(after: (() -> Void)?) {
    // Make the window fully transparent and remove it from the screen, but keep it alive in memory
    alphaValue = 0
    orderOut(nil)
    after?()
  }

  func notFound() {
  }

  func cheatsheetOrigin(cheatsheetSize: NSSize) -> NSPoint {
    return NSPoint(x: 0, y: 0)
  }
}
