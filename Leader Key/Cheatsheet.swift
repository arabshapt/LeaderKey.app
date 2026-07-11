import Defaults
import Kingfisher
import SwiftUI

enum Cheatsheet {
  private static let iconSize = NSSize(width: 24, height: 24)

  struct PreparedRow: Identifiable {
    let item: ActionOrGroup
    let children: [PreparedRow]

    var id: UUID { item.id }
  }

  static func preparedRows(
    from actions: [ActionOrGroup],
    showFallbackItems: Bool,
    includeDescendants: Bool = true
  ) -> [PreparedRow] {
    actions
      .filter { showFallbackItems || !isFromFallback($0) }
      .sortedAlphabetically()
      .map { item in
        let childActions: [ActionOrGroup]
        if includeDescendants {
          switch item {
          case .action:
            childActions = []
          case .group(let group):
            childActions = group.actions
          case .layer(let layer):
            childActions = layer.actions
          }
        } else {
          childActions = []
        }
        return PreparedRow(
          item: item,
          children: preparedRows(
            from: childActions,
            showFallbackItems: showFallbackItems,
            includeDescendants: includeDescendants
          )
        )
      }
  }

  private static func isFromFallback(_ item: ActionOrGroup) -> Bool {
    switch item {
    case .action(let action):
      return action.isFromFallback
    case .group(let group):
      return group.isFromFallback
    case .layer(let layer):
      return layer.isFromFallback
    }
  }

  struct KeyBadge: SwiftUI.View {
    let key: String
    let showFallbackIndicator: Bool

    init(key: String, showFallbackIndicator: Bool = false) {
      self.key = key
      self.showFallbackIndicator = showFallbackIndicator
    }

    var body: some SwiftUI.View {
      ZStack(alignment: .bottomTrailing) {
        Text(key)
          .font(.system(.body, design: .rounded))
          .multilineTextAlignment(.center)
          .fontWeight(.bold)
          .padding(.vertical, 4)
          .frame(width: 24)
          .background(.white.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 5.0, style: .continuous))

        if showFallbackIndicator {
          Image(systemName: "circle.fill")
            .foregroundColor(.white.opacity(0.2))
            .font(.system(size: 4))
            .offset(x: -2, y: -2)
        }
      }
    }
  }

  struct ActionRow: SwiftUI.View {
    let action: Action
    let indent: Int
    @Default(.showDetailsInCheatsheet) var showDetails
    @Default(.showAppIconsInCheatsheet) var showIcons

    var body: some SwiftUI.View {
      HStack {
        HStack {
          ForEach(0..<indent, id: \.self) { _ in
            Text("  ")
          }
          KeyBadge(key: action.key ?? "●", showFallbackIndicator: action.isFromFallback)
            .help(
              action.isFromFallback ? "From \(action.fallbackSource ?? "Fallback App Config")" : "")

          if showIcons {
            actionIcon(item: ActionOrGroup.action(action), iconSize: iconSize)
          }

          Text(action.displayName)
            .lineLimit(1)
            .truncationMode(.middle)
            .opacity(action.isFromFallback ? 0.7 : 1.0)
        }
        Spacer()
        if showDetails {
          // Show detail text based on type
          switch action.type {
          case .shortcut:
            Text("Shortcut: \(action.value)")
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          case .text:
            let snippet = action.value.prefix(30)
            let suffix = action.value.count > 30 ? "..." : ""
            Text("Types: '\(snippet)\(suffix)'")
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          default:
            Text(action.value)
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          }
        }
      }
    }
  }

  struct GroupRow: SwiftUI.View {
    @Default(.expandGroupsInCheatsheet) var expand
    @Default(.showDetailsInCheatsheet) var showDetails
    @Default(.showAppIconsInCheatsheet) var showIcons

    let group: Group
    let children: [PreparedRow]
    let indent: Int

    var body: some SwiftUI.View {
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          ForEach(0..<indent, id: \.self) { _ in
            Text("  ")
          }
          KeyBadge(key: group.key ?? "", showFallbackIndicator: group.isFromFallback)
            .help(
              group.isFromFallback ? "From \(group.fallbackSource ?? "Fallback App Config")" : "")

          if showIcons {
            actionIcon(item: ActionOrGroup.group(group), iconSize: iconSize)
          }

          Image(systemName: "chevron.right")
            .foregroundStyle(.secondary)

          Text(group.displayName)
            .opacity(group.isFromFallback ? 0.7 : 1.0)

          Spacer()
          if showDetails {
            Text("\(group.actions.count.description) item(s)")
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          }
        }
        if expand {
          ForEach(children) { child in
            Cheatsheet.ItemRow(row: child, indent: indent + 1)
          }
        }
      }
    }
  }

  struct LayerRow: SwiftUI.View {
    @Default(.expandGroupsInCheatsheet) var expand
    @Default(.showDetailsInCheatsheet) var showDetails
    @Default(.showAppIconsInCheatsheet) var showIcons

    let layer: Layer
    let children: [PreparedRow]
    let indent: Int

    var body: some SwiftUI.View {
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          ForEach(0..<indent, id: \.self) { _ in
            Text("  ")
          }
          KeyBadge(key: layer.key ?? "", showFallbackIndicator: layer.isFromFallback)
            .help(
              layer.isFromFallback ? "From \(layer.fallbackSource ?? "Fallback App Config")" : "")

          if showIcons {
            actionIcon(item: ActionOrGroup.layer(layer), iconSize: iconSize)
          }

          Image(systemName: "square.stack.3d.up")
            .foregroundStyle(.secondary)

          Text(layer.displayName)
            .opacity(layer.isFromFallback ? 0.7 : 1.0)

          Spacer()
          if showDetails {
            Text("\(layer.actions.count.description) item(s)")
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          }
        }
        if expand {
          ForEach(children) { child in
            Cheatsheet.ItemRow(row: child, indent: indent + 1)
          }
        }
      }
    }
  }

  struct ItemRow: SwiftUI.View {
    let row: PreparedRow
    let indent: Int

    @ViewBuilder
    var body: some SwiftUI.View {
      switch row.item {
      case .action(let action):
        Cheatsheet.ActionRow(action: action, indent: indent)
      case .group(let group):
        Cheatsheet.GroupRow(group: group, children: row.children, indent: indent)
      case .layer(let layer):
        Cheatsheet.LayerRow(layer: layer, children: row.children, indent: indent)
      }
    }
  }

  struct CheatsheetView: SwiftUI.View {
    @EnvironmentObject var userState: UserState
    @State private var contentHeight: CGFloat = 0
    @Default(.showFallbackItems) var showFallbackItems
    @Default(.expandGroupsInCheatsheet) var expandGroups

    var maxHeight: CGFloat {
      if let screen = NSScreen.main {
        return screen.visibleFrame.height - 40  // Leave some margin
      }
      return 640
    }

    // Constrain to edge of screen
    static var preferredWidth: CGFloat {
      if let screen = NSScreen.main {
        let screenHalf = screen.visibleFrame.width / 2
        let desiredWidth: CGFloat = 580
        let margin: CGFloat = 20
        return desiredWidth > screenHalf ? screenHalf - margin : desiredWidth
      }
      return 580
    }

    var actions: [ActionOrGroup] {
      let baseActions = userState.activeRoot?.actions ?? []
      return
        (userState.currentGroup != nil)
        ? userState.currentGroup!.actions : baseActions
    }

    var rows: [PreparedRow] {
      preparedRows(
        from: actions,
        showFallbackItems: showFallbackItems,
        includeDescendants: expandGroups
      )
    }

    var body: some SwiftUI.View {
      ScrollView(showsIndicators: false) {
        LazyVStack(alignment: .leading, spacing: 4) {
          // Header showing current group or root label
          HStack {
            KeyBadge(key: userState.currentGroup?.key ?? "•")
            Text(headerTitle())
              .foregroundStyle(.secondary)
          }
          .padding(.bottom, 8)
          Divider()
            .padding(.bottom, 8)

          ForEach(rows) { row in
            Cheatsheet.ItemRow(row: row, indent: 0)
          }
        }
        .padding()
        .overlay(
          GeometryReader { geo in
            Color.clear.preference(
              key: HeightPreferenceKey.self,
              value: geo.size.height
            )
          }
        )
      }
      .frame(width: Cheatsheet.CheatsheetView.preferredWidth)
      .frame(height: min(contentHeight, maxHeight))
      .background(
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
      )
      .onPreferenceChange(HeightPreferenceKey.self) { height in
        self.contentHeight = height
      }
    }

    private func headerTitle() -> String {
      if let cg = userState.currentGroup {
        if let keyString = cg.key, !keyString.isEmpty {
          return cg.displayName
        } else {
          return "Leader Key"
        }
      }
      return "Leader Key"
    }
  }

  struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = nextValue()
    }
  }

  static func createWindow(for userState: UserState) -> NSWindow {
    // Build view controller on demand to reduce baseline memory
    let view = CheatsheetView().environmentObject(userState)
    let controller = NSHostingController(rootView: view)
    let cheatsheet = PanelWindow(
      contentRect: NSRect(x: 0, y: 0, width: 580, height: 640)
    )
    cheatsheet.isReleasedWhenClosed = true  // allow memory to be reclaimed when window is closed
    cheatsheet.contentViewController = controller
    return cheatsheet
  }
}

struct CheatsheetView_Previews: PreviewProvider {
  static var previews: some View {
    Cheatsheet.CheatsheetView()
      .environmentObject(UserState(userConfig: UserConfig()))
  }
}
