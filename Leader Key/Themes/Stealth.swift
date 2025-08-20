import Foundation
import SwiftUI

enum Stealth {
  class Window: MainWindow {
    override var hasCheatsheet: Bool { return false }

    required init(controller: Controller) {
      super.init(controller: controller, contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))
      backgroundColor = .clear
      isOpaque = false
      hasShadow = false
      alphaValue = 0
    }

    override func show(at origin: NSPoint? = nil, after: (() -> Void)? = nil) {
      makeKeyAndOrderFront(nil)
      after?()
    }

    override func hide(after: (() -> Void)?) {
      self.close()
      after?()
    }

    override func notFound() {
    }
  }
}