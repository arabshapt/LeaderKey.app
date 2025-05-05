import Foundation
import SwiftUI

enum Cheater {
  class Window: MainWindow {
    override var hasCheatsheet: Bool { return false }

    required init(controller: Controller) {
      super.init(controller: controller, contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))
      let view = Cheatsheet.CheatsheetView()
      contentView = NSHostingView(rootView: view.environmentObject(self.controller.userState))
    }

    override func show(at origin: NSPoint? = nil, after: (() -> Void)? = nil) {
      if let explicitOrigin = origin {
        print("[CheaterWindow show(at:)] Using provided origin: \(explicitOrigin)")
        self.setFrameOrigin(explicitOrigin)
        let width = contentView?.fittingSize.width ?? Cheatsheet.CheatsheetView.preferredWidth
        let height = contentView?.fittingSize.height ?? 0
        let size = NSSize(width: width, height: height)
        print("[CheaterWindow show(at:)] Setting size to: \(size)")
        self.setContentSize(size)
      } else {
        print("[CheaterWindow show(at:)] Origin not provided, using default centering logic.")
        let screenSize = NSScreen.main?.frame.size ?? NSSize()
        let width = contentView?.frame.width ?? Cheatsheet.CheatsheetView.preferredWidth
        let height = contentView?.frame.height ?? 0
        let x = screenSize.width / 2 - width / 2
        let y = screenSize.height / 2 - height / 2 + (screenSize.height / 8)
        self.setFrame(CGRect(x: x, y: y, width: width, height: height), display: false)
      }

      self.displayIfNeeded()

      makeKeyAndOrderFront(nil)

      fadeInAndUp {
        after?()
      }
    }

    override func hide(after: (() -> Void)?) {
      fadeOutAndDown {
        self.close()
        after?()
      }
    }

    override func notFound() {
      shake()
    }
  }
}
