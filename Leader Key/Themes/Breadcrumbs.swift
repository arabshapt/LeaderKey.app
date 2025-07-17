import SwiftUI

enum Breadcrumbs {
  static let dimension = 36.0
  static let margin = 8.0
  static let padding = 13.0

  class Window: MainWindow {
    required init(controller: Controller) {
      super.init(
        controller: controller,
        contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))

      let view = MainView().environmentObject(self.controller.userState)
      contentView = NSHostingView(rootView: view)
    }

    override func show(at origin: NSPoint? = nil, after: (() -> Void)? = nil) {
      let screen = NSScreen.main == nil ? NSSize() : NSScreen.main!.frame.size

      let initialX: CGFloat
      let initialY: CGFloat

      if let explicitOrigin = origin {
        print("[BreadcrumbsWindow show(at:)] Using provided origin: \(explicitOrigin)")
        initialX = explicitOrigin.x
        initialY = explicitOrigin.y
      } else {
        print("[BreadcrumbsWindow show(at:)] Origin not provided, using default bottom-left positioning.")
        initialX = Breadcrumbs.margin
        initialY = Breadcrumbs.margin
      }

      if controller.userState.navigationPath.isEmpty == true {
        self.setFrame(
          CGRect(
            x: initialX,
            y: initialY,
            width: Breadcrumbs.dimension,
            height: Breadcrumbs.dimension),
          display: false)
      } else {
        self.setFrame(
          CGRect(
            x: initialX,
            y: initialY,
            width: 200,
            height: Breadcrumbs.dimension),
          display: false)

        self.contentAspectRatio = NSSize(width: 0, height: Breadcrumbs.dimension)
        self.contentMinSize = NSSize(width: 80, height: Breadcrumbs.dimension)
        self.contentMaxSize = NSSize(
          width: screen.width - (Breadcrumbs.margin * 2),
          height: Breadcrumbs.dimension
        )
      }

      self.displayIfNeeded()

      makeKeyAndOrderFront(nil)

      fadeIn {
        after?()
      }
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
      return NSPoint(
        x: Breadcrumbs.margin,
        y: frame.maxY + Breadcrumbs.margin)
    }
  }

  struct MainView: View {
    @EnvironmentObject var userState: UserState

    var breadcrumbPath: [String] {
      return userState.navigationPath.map(\.displayName)
    }

    var body: some View {
      HStack(spacing: 0) {
        if breadcrumbPath.isEmpty {
          let text = Text("●")
            .foregroundStyle(.secondary)
            .padding(.horizontal, Breadcrumbs.padding)

          if userState.isShowingRefreshState {
            text.pulsate()
          } else {
            text
          }
        } else {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
              ForEach(0..<breadcrumbPath.count, id: \.self) { index in
                if index > 0 {
                  Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                }

                let text = Text(breadcrumbPath[index])
                  .lineLimit(1)
                  .truncationMode(.middle)

                if userState.isShowingRefreshState {
                  text.pulsate()
                } else {
                  text
                }
              }
            }
            .padding(.horizontal, Breadcrumbs.padding)
          }
        }
      }
      .frame(height: Breadcrumbs.dimension)
      .fixedSize(horizontal: true, vertical: true)
      .font(.system(size: 14, weight: .medium, design: .rounded))
      .background(
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
      )
      .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
    }
  }
}
