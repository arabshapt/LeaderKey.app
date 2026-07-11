import AppKit
import SwiftUI

enum ShortcutsOverviewTarget: Hashable, Identifiable {
  case global
  case fallback
  case app(bundleId: String)

  var id: String {
    switch self {
    case .global: return "global"
    case .fallback: return "fallback"
    case .app(let bundleId): return "app:\(bundleId)"
    }
  }
}

final class ShortcutsOverviewSelection: ObservableObject {
  @Published var target: ShortcutsOverviewTarget {
    didSet {
      if target != oldValue {
        drillPath = []
      }
    }
  }
  @Published var drillPath: [String]

  init(
    target: ShortcutsOverviewTarget = .global,
    drillPath: [String] = []
  ) {
    self.target = target
    self.drillPath = drillPath
  }

  /// A nil request comes from the status menu and deliberately preserves the
  /// current selection. Socket bundle requests select a discovered app map or
  /// the effective fallback map when that app has no regular configuration.
  func preselect(bundleId: String?, using userConfig: UserConfig) {
    guard let bundleId = bundleId?.trimmingCharacters(in: .whitespacesAndNewlines),
      !bundleId.isEmpty
    else { return }

    let configKey = userConfig.configKey(forBundleId: bundleId)
    if case .app(let resolvedBundleId) = userConfig.configFileKind(forDisplayKey: configKey) {
      target = .app(bundleId: resolvedBundleId)
    } else {
      target = .fallback
    }
  }
}

struct ShortcutsKeyboardGrid: View {
  let level: ShortcutsOverview.LevelView
  var compact = false
  var onDrill: (ShortcutsOverview.KeyAssignment) -> Void = { _ in }

  var body: some View {
    VStack(spacing: compact ? 3 : 6) {
      ForEach(Array(ShortcutsOverview.keyboardRows.enumerated()), id: \.offset) { _, row in
        HStack(spacing: compact ? 3 : 6) {
          ForEach(row, id: \.self) { baseKey in
            physicalKeycap(baseKey)
          }
        }
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Shortcut keyboard map")
  }

  private func physicalKeycap(_ baseKey: String) -> some View {
    let shiftedKey = ShortcutsOverview.shiftedKey(for: baseKey) ?? baseKey.uppercased()
    let baseAssignment = level.assignments[baseKey]
    let shiftedAssignment = level.assignments[shiftedKey]
    let isFree = level.freeKeys.contains(baseKey)

    return VStack(spacing: 1) {
      assignmentButton(
        glyph: shiftedKey,
        assignment: shiftedAssignment,
        conflict: level.duplicateConflicts[shiftedKey]
      )
      assignmentButton(
        glyph: baseKey,
        assignment: baseAssignment,
        conflict: level.duplicateConflicts[baseKey]
      )
    }
    .frame(width: compact ? 32 : 54, height: compact ? 32 : 54)
    .background(
      RoundedRectangle(cornerRadius: compact ? 5 : 8, style: .continuous)
        .fill(Color.primary.opacity(isFree ? 0.025 : 0.055))
    )
    .overlay(
      RoundedRectangle(cornerRadius: compact ? 5 : 8, style: .continuous)
        .stroke(Color.primary.opacity(isFree ? 0.12 : 0.25), lineWidth: 1)
    )
  }

  private func assignmentButton(
    glyph: String,
    assignment: ShortcutsOverview.KeyAssignment?,
    conflict: ShortcutsOverview.DuplicateConflict?
  ) -> some View {
    Button {
      if let assignment, assignment.isDrillable {
        onDrill(assignment)
      }
    } label: {
      HStack(spacing: 2) {
        Text(glyph)
          .font(.system(size: compact ? 9 : 12, weight: assignment == nil ? .regular : .semibold))
          .lineLimit(1)

        if !compact, let assignment {
          Image(systemName: overviewSymbol(for: assignment.type))
            .font(.system(size: 8))
        }

        if assignment?.isDrillable == true {
          Image(systemName: "chevron.right")
            .font(.system(size: compact ? 6 : 7, weight: .bold))
        }

        if conflict != nil {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: compact ? 6 : 7))
            .foregroundStyle(.red)
        }

        if assignment?.isFromFallback == true {
          Circle()
            .fill(Color.secondary)
            .frame(width: 4, height: 4)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .foregroundStyle(assignment.map { overviewColor(for: $0.type) } ?? .secondary)
      .background(
        assignment.map { overviewColor(for: $0.type).opacity(0.16) } ?? Color.clear
      )
      .contentShape(Rectangle())
      .opacity(assignment?.isFromFallback == true ? 0.7 : 1)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(
      accessibilityLabel(glyph: glyph, assignment: assignment, conflict: conflict)
    )
    .accessibilityHint(assignment?.isDrillable == true ? "Open this shortcut group" : "")
    .help(helpText(glyph: glyph, assignment: assignment, conflict: conflict))
  }

  private func accessibilityLabel(
    glyph: String,
    assignment: ShortcutsOverview.KeyAssignment?,
    conflict: ShortcutsOverview.DuplicateConflict?
  ) -> String {
    guard let assignment else { return "\(glyph), unassigned" }
    let duplicateSuffix = conflict == nil ? "" : ", duplicate assignment conflict"
    return "\(glyph), \(assignment.displayName)\(duplicateSuffix)"
  }

  private func helpText(
    glyph: String,
    assignment: ShortcutsOverview.KeyAssignment?,
    conflict: ShortcutsOverview.DuplicateConflict?
  ) -> String {
    guard let assignment else { return "\(glyph): Free" }
    var lines = ["\(glyph): \(assignment.displayName)"]
    if let actionValue = assignment.actionValue, !actionValue.isEmpty {
      lines.append(actionValue)
    }
    if assignment.isFromFallback {
      lines.append("Inherited from \(assignment.fallbackSource ?? defaultAppConfigDisplayName)")
    }
    if let conflict {
      lines.append("\(conflict.shadowed.count) duplicate assignment(s) also use this exact key")
    }
    return lines.joined(separator: "\n")
  }
}

struct ShortcutsOverviewView: View {
  @ObservedObject var userConfig: UserConfig
  @StateObject private var selection: ShortcutsOverviewSelection
  let compact: Bool

  @State private var searchQuery = ""

  init(
    userConfig: UserConfig,
    selection: ShortcutsOverviewSelection? = nil,
    compact: Bool = false
  ) {
    self.userConfig = userConfig
    self.compact = compact
    _selection = StateObject(wrappedValue: selection ?? ShortcutsOverviewSelection())
  }

  var body: some View {
    SwiftUI.Group {
      if compact {
        compactBody
      } else {
        regularBody
      }
    }
    .onAppear(perform: reconcileSelection)
    .onChange(of: userConfig.discoveredConfigFiles) { _ in
      reconcileSelection()
    }
    .onChange(of: resolvedPath.keys) { validPath in
      if selection.drillPath != validPath {
        selection.drillPath = validPath
      }
    }
    .onReceive(Events.shared.publisher) { event in
      if event == .didReload {
        selection.drillPath = []
        reconcileSelection()
      }
    }
  }

  private var regularBody: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        HStack(spacing: 12) {
          Text("Shortcut Map")
            .font(.title2.weight(.semibold))

          Spacer()

          Picker("Configuration", selection: $selection.target) {
            ForEach(configOptions) { option in
              HStack {
                if let bundleId = option.bundleId,
                  let icon = userConfig.getAppIcon(for: bundleId)
                {
                  Image(nsImage: icon)
                }
                Text(option.title)
              }
              .tag(option.target)
            }
          }
          .frame(width: 320)
        }

        breadcrumbBar

        ShortcutsKeyboardGrid(level: currentLevel, onDrill: drill)
          .frame(maxWidth: .infinity, alignment: .center)

        freeKeyFooter

        if !currentLevel.duplicateConflicts.isEmpty {
          Label(
            "This level contains \(currentLevel.duplicateConflicts.count) duplicate exact-key conflict(s). The first item is displayed.",
            systemImage: "exclamationmark.triangle.fill"
          )
          .font(.callout)
          .foregroundStyle(.orange)
        }

        Divider()

        sequenceList
      }
      .padding(24)
      .frame(maxWidth: SettingsConfig.contentWidth, alignment: .leading)
    }
    .frame(minWidth: SettingsConfig.contentWidth, minHeight: 650)
  }

  private var compactBody: some View {
    VStack(alignment: .leading, spacing: 8) {
      breadcrumbBar
      ShortcutsKeyboardGrid(level: currentLevel, compact: true, onDrill: drill)
      freeKeyFooter
    }
  }

  private var breadcrumbBar: some View {
    HStack(spacing: 6) {
      Button("Root") {
        selection.drillPath = []
      }
      .buttonStyle(.link)

      ForEach(resolvedPath.breadcrumb) { entry in
        Image(systemName: "chevron.right")
          .font(.caption2)
          .foregroundStyle(.secondary)
        Button("\(entry.key) · \(entry.title)") {
          selection.drillPath = entry.path
        }
        .buttonStyle(.link)
      }

      Spacer()

      if !resolvedPath.keys.isEmpty {
        Button {
          selection.drillPath.removeLast()
        } label: {
          Label("Back", systemImage: "arrow.left")
        }
        .keyboardShortcut(.escape, modifiers: [])
        .help("Go back one level (Esc)")
      }
    }
  }

  private var freeKeyFooter: some View {
    let sortedKeys = currentLevel.freeKeys.sorted(by: physicalKeyOrder)
    return HStack(alignment: .firstTextBaseline, spacing: 8) {
      Text("\(sortedKeys.count) free keys on this grid.")
        .font(.callout.weight(.medium))
      if !compact, !sortedKeys.isEmpty {
        Text(sortedKeys.joined(separator: "  "))
          .font(.system(.caption, design: .monospaced))
          .foregroundStyle(.secondary)
      }
    }
  }

  private var sequenceList: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("All Sequences")
          .font(.headline)
        Spacer()
        TextField("Search shortcuts", text: $searchQuery)
          .textFieldStyle(.roundedBorder)
          .frame(width: 280)
      }

      if filteredSequences.isEmpty {
        VStack(spacing: 8) {
          Image(systemName: "keyboard")
            .font(.title2)
            .foregroundStyle(.secondary)
          Text(searchQuery.isEmpty ? "No shortcuts" : "No matching shortcuts")
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
      } else {
        LazyVStack(alignment: .leading, spacing: 14) {
          ForEach(sequenceGroups, id: \.key) { group in
            VStack(alignment: .leading, spacing: 6) {
              Text(group.key)
                .font(.headline.monospaced())
                .foregroundStyle(.secondary)

              ForEach(group.entries) { entry in
                sequenceRow(entry)
              }
            }
          }
        }
      }
    }
  }

  private func sequenceRow(_ entry: ShortcutsOverview.SequenceEntry) -> some View {
    HStack(alignment: .top, spacing: 12) {
      HStack(spacing: 3) {
        ForEach(Array(entry.keys.enumerated()), id: \.offset) { index, key in
          if index > 0 {
            Image(systemName: "chevron.right")
              .font(.system(size: 7))
              .foregroundStyle(.tertiary)
          }
          Text(key)
            .font(.system(.caption, design: .monospaced, weight: .semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
      }
      .frame(minWidth: 150, alignment: .leading)

      Image(systemName: overviewSymbol(for: entry.type))
        .foregroundStyle(overviewColor(for: entry.type))
        .frame(width: 18)

      VStack(alignment: .leading, spacing: 2) {
        Text(entry.displayName)
          .fontWeight(.medium)
          .opacity(entry.isFromFallback ? 0.7 : 1)
        if let value = entry.actionValue, !value.isEmpty {
          Text(value)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .textSelection(.enabled)
        }
      }

      Spacer()

      if entry.isFromFallback {
        Label(
          entry.fallbackSource ?? defaultAppConfigDisplayName,
          systemImage: "circle.fill"
        )
        .font(.caption2)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 5)
    .padding(.horizontal, 8)
    .background(Color.primary.opacity(0.025))
    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    // future: click-through to editor
  }

  private var selectedRoot: Group {
    switch selection.target {
    case .global:
      return userConfig.root
    case .fallback:
      return userConfig.getMarkedFallbackConfig()
    case .app(let bundleId):
      return userConfig.getConfig(for: bundleId)
    }
  }

  private var resolvedPath: ShortcutsOverview.ResolvedPath {
    ShortcutsOverview.resolvePath(selection.drillPath, from: selectedRoot.actions)
  }

  private var currentLevel: ShortcutsOverview.LevelView {
    ShortcutsOverview.levelView(
      for: resolvedPath.actions,
      breadcrumb: resolvedPath.breadcrumb
    )
  }

  private var flattenedSequences: [ShortcutsOverview.SequenceEntry] {
    ShortcutsOverview.flattenedSequences(from: selectedRoot.actions)
  }

  private var filteredSequences: [ShortcutsOverview.SequenceEntry] {
    let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return flattenedSequences }
    return flattenedSequences.filter { entry in
      entry.display.localizedCaseInsensitiveContains(query)
        || entry.displayName.localizedCaseInsensitiveContains(query)
        || (entry.actionValue?.localizedCaseInsensitiveContains(query) ?? false)
        || (entry.fallbackSource?.localizedCaseInsensitiveContains(query) ?? false)
    }
  }

  private var sequenceGroups: [(key: String, entries: [ShortcutsOverview.SequenceEntry])] {
    var order: [String] = []
    var grouped: [String: [ShortcutsOverview.SequenceEntry]] = [:]
    for entry in filteredSequences {
      guard let firstKey = entry.keys.first else { continue }
      if grouped[firstKey] == nil {
        order.append(firstKey)
      }
      grouped[firstKey, default: []].append(entry)
    }
    return order.map { ($0, grouped[$0] ?? []) }
  }

  private var configOptions: [ConfigOption] {
    var optionsByTarget: [ShortcutsOverviewTarget: ConfigOption] = [
      .global: ConfigOption(target: .global, title: globalDefaultDisplayName, bundleId: nil),
      .fallback: ConfigOption(
        target: .fallback, title: defaultAppConfigDisplayName, bundleId: nil),
    ]

    for (displayName, _) in userConfig.discoveredConfigFiles {
      switch userConfig.configFileKind(forDisplayKey: displayName) {
      case .global:
        optionsByTarget[.global] = ConfigOption(
          target: .global, title: displayName, bundleId: nil)
      case .appFallback:
        optionsByTarget[.fallback] = ConfigOption(
          target: .fallback, title: displayName, bundleId: nil)
      case .app(let bundleId):
        let target = ShortcutsOverviewTarget.app(bundleId: bundleId)
        optionsByTarget[target] = ConfigOption(
          target: target, title: displayName, bundleId: bundleId)
      case .normalFallback, .normalApp, .tag, .normalTag, .unknown:
        continue
      }
    }

    let shared = [optionsByTarget[.global], optionsByTarget[.fallback]].compactMap { $0 }
    let apps = optionsByTarget.values
      .filter {
        if case .app = $0.target { return true }
        return false
      }
      .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    return shared + apps
  }

  private func drill(_ assignment: ShortcutsOverview.KeyAssignment) {
    guard assignment.isDrillable else { return }
    selection.drillPath = resolvedPath.keys + [assignment.key]
  }

  private func reconcileSelection() {
    if !configOptions.contains(where: { $0.target == selection.target }) {
      selection.target = .fallback
      return
    }

    let validPath = resolvedPath.keys
    if validPath != selection.drillPath {
      selection.drillPath = validPath
    }
  }

  private func physicalKeyOrder(_ lhs: String, _ rhs: String) -> Bool {
    let order = ShortcutsOverview.keyboardRows.flatMap { $0 }
    return (order.firstIndex(of: lhs) ?? .max) < (order.firstIndex(of: rhs) ?? .max)
  }
}

private struct ConfigOption: Identifiable {
  let target: ShortcutsOverviewTarget
  let title: String
  let bundleId: String?

  var id: ShortcutsOverviewTarget { target }
}

private func overviewColor(for type: Type) -> Color {
  switch type {
  case .group, .layer: return .accentColor
  case .application: return .purple
  case .url: return .cyan
  case .command: return .orange
  case .folder: return .yellow
  case .shortcut, .keystroke: return .green
  case .text: return .pink
  case .macro: return .indigo
  case .menu: return .mint
  case .intellij: return .red
  case .toggleStickyMode, .normalModeEnable, .normalModeInput, .normalModeDisable,
    .toggleHintOverlay:
    return .gray
  }
}

private func overviewSymbol(for type: Type) -> String {
  switch type {
  case .group: return "folder"
  case .layer: return "square.stack.3d.up"
  case .application: return "app"
  case .url: return "link"
  case .command: return "terminal"
  case .folder: return "folder"
  case .shortcut, .keystroke: return "keyboard"
  case .text: return "text.cursor"
  case .macro: return "play.rectangle.on.rectangle"
  case .menu: return "filemenu.and.selection"
  case .intellij: return "hammer"
  case .toggleStickyMode, .normalModeEnable, .normalModeInput, .normalModeDisable,
    .toggleHintOverlay:
    return "switch.2"
  }
}

struct ShortcutsOverviewView_Previews: PreviewProvider {
  static var previews: some View {
    ShortcutsOverviewView(userConfig: UserConfig())
      .frame(width: 1100, height: 800)
  }
}
