import SwiftUI

enum Mini {
  static let size = 36.0
  static let margin = 8.0

  class Window: MainWindow {
    required init(controller: Controller) {
      super.init(
        controller: controller,
        contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))

      let view = MainView().environmentObject(self.controller.userState)
      contentView = NSHostingView(rootView: view)
    }

    override func show(at origin: NSPoint? = nil, after: (() -> Void)? = nil) {
      if let explicitOrigin = origin {
          print("[MiniWindow show(at:)] Using provided origin: \(explicitOrigin)")
          self.setFrameOrigin(explicitOrigin)
          self.setContentSize(NSSize(width: 250, height: 150))
      } else {
          print("[MiniWindow show(at:)] Origin not provided, centering.")
          self.center()
      }

      self.displayIfNeeded()
      makeKeyAndOrderFront(nil)
      after?()
    }

    override func hide(after: (() -> Void)? = nil) {
      fadeOut {
        super.hide(after: after)
      }
    }

    override func notFound() {
      shake()
    }

    override func cheatsheetOrigin(cheatsheetSize: NSSize) -> NSPoint {
      let screen = NSScreen.main == nil ? NSSize() : NSScreen.main!.frame.size

      return NSPoint(
        x: screen.width - cheatsheetSize.width - Mini.margin,
        y: Mini.margin + frame.height + Mini.margin)
    }
  }

  struct MainView: View {
    @EnvironmentObject var userState: UserState

    var body: some View {
      ZStack {
        let text = Text(userState.currentGroup?.key ?? userState.display ?? "●")
          .fontDesign(.rounded)
          .fontWeight(.bold)

        if userState.isShowingRefreshState {
          text.pulsate()
        } else {
          text
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .font(.system(size: 16, weight: .semibold, design: .rounded))
      .foregroundStyle(userState.currentGroup?.key == nil ? .secondary : .primary)
      .background(
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
      )
    }
  }
}

struct MiniMainViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
      MysteryBox.MainView().environmentObject(
        UserState(userConfig: UserConfig()))
    }.frame(width: Mini.size, height: Mini.size, alignment: .center)
  }
}
