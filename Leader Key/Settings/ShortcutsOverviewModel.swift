import Foundation

/// Read-only data model shared by the shortcut overview surfaces.
enum ShortcutsOverview {
  /// Physical US-QWERTY caps rendered by the overview. Valid config keys that
  /// are not represented here remain available in the flattened sequence list.
  static let keyboardRows: [[String]] = [
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="],
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]", "\\"],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'"],
    ["z", "x", "c", "v", "b", "n", "m", ",", ".", "/"],
  ]

  static let shiftedKeyByBaseKey: [String: String] = [
    "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^",
    "7": "&", "8": "*", "9": "(", "0": ")", "-": "_", "=": "+",
    "q": "Q", "w": "W", "e": "E", "r": "R", "t": "T", "y": "Y",
    "u": "U", "i": "I", "o": "O", "p": "P", "[": "{", "]": "}", "\\": "|",
    "a": "A", "s": "S", "d": "D", "f": "F", "g": "G", "h": "H",
    "j": "J", "k": "K", "l": "L", ";": ":", "'": "\"",
    "z": "Z", "x": "X", "c": "C", "v": "V", "b": "B", "n": "N",
    "m": "M", ",": "<", ".": ">", "/": "?",
  ]

  static let candidateKeys: Set<String> = Set(keyboardRows.flatMap { $0 })

  static func shiftedKey(for baseKey: String) -> String? {
    shiftedKeyByBaseKey[baseKey]
  }

  // MARK: - Node helpers

  static func children(of node: ActionOrGroup) -> [ActionOrGroup]? {
    switch node {
    case .action:
      return nil
    case .group(let group):
      return group.actions
    case .layer(let layer):
      return layer.actions
    }
  }

  static func isFromFallback(_ node: ActionOrGroup) -> Bool {
    switch node {
    case .action(let action): return action.isFromFallback
    case .group(let group): return group.isFromFallback
    case .layer(let layer): return layer.isFromFallback
    }
  }

  static func fallbackSource(_ node: ActionOrGroup) -> String? {
    switch node {
    case .action(let action): return action.fallbackSource
    case .group(let group): return group.fallbackSource
    case .layer(let layer): return layer.fallbackSource
    }
  }

  // MARK: - Level view

  struct AssignmentIdentity: Hashable {
    let key: String
    let sourceIndex: Int
  }

  struct KeyAssignment: Identifiable {
    let key: String
    let node: ActionOrGroup
    fileprivate let sourceIndex: Int

    var id: AssignmentIdentity { AssignmentIdentity(key: key, sourceIndex: sourceIndex) }
    var type: Type { node.item.type }
    var displayName: String { node.item.displayName }
    var isDrillable: Bool { ShortcutsOverview.children(of: node) != nil }

    var actionValue: String? {
      if case .action(let action) = node { return action.value }
      return nil
    }

    var isFromFallback: Bool { ShortcutsOverview.isFromFallback(node) }
    var fallbackSource: String? { ShortcutsOverview.fallbackSource(node) }
  }

  /// Duplicate exact-key assignments are invalid config, but the overview
  /// keeps the first item visible and reports every shadowed item separately.
  struct DuplicateConflict: Identifiable {
    let key: String
    let primary: KeyAssignment
    let shadowed: [KeyAssignment]

    var id: String { key }
    var assignments: [KeyAssignment] { [primary] + shadowed }
  }

  struct BreadcrumbEntry: Identifiable, Equatable {
    let path: [String]
    let key: String
    let title: String

    var id: [String] { path }
  }

  struct LevelView {
    let breadcrumb: [BreadcrumbEntry]
    let assignments: [String: KeyAssignment]
    let duplicateConflicts: [String: DuplicateConflict]
    /// Physical base caps with neither their base nor shifted glyph assigned.
    let freeKeys: Set<String>
  }

  static func levelView(
    for actions: [ActionOrGroup], breadcrumb: [BreadcrumbEntry] = []
  ) -> LevelView {
    var allAssignments: [String: [KeyAssignment]] = [:]
    for (sourceIndex, node) in actions.enumerated() {
      guard let key = node.item.key, !key.isEmpty else { continue }
      allAssignments[key, default: []].append(
        KeyAssignment(key: key, node: node, sourceIndex: sourceIndex))
    }

    let assignments = allAssignments.compactMapValues(\.first)
    let duplicateConflicts: [String: DuplicateConflict] = allAssignments.compactMapValues {
      matches in
      guard let primary = matches.first, matches.count > 1 else { return nil }
      return DuplicateConflict(
        key: primary.key, primary: primary, shadowed: Array(matches.dropFirst()))
    }
    let freeKeys = candidateKeys.filter { baseKey in
      guard assignments[baseKey] == nil else { return false }
      guard let shiftedKey = shiftedKey(for: baseKey) else { return true }
      return assignments[shiftedKey] == nil
    }

    return LevelView(
      breadcrumb: breadcrumb,
      assignments: assignments,
      duplicateConflicts: duplicateConflicts,
      freeKeys: Set(freeKeys)
    )
  }

  // MARK: - Fresh-root path resolution

  struct ResolvedPath {
    let keys: [String]
    let breadcrumb: [BreadcrumbEntry]
    let actions: [ActionOrGroup]
  }

  /// Resolves each drill step from the supplied root using exact, first-match
  /// lookup. Invalid suffixes are truncated, so reloads cannot retain stale nodes.
  static func resolvePath(_ requestedPath: [String], from rootActions: [ActionOrGroup])
    -> ResolvedPath
  {
    var currentActions = rootActions
    var resolvedKeys: [String] = []
    var breadcrumb: [BreadcrumbEntry] = []

    for key in requestedPath {
      guard let node = currentActions.first(where: { $0.item.key == key }),
        let children = children(of: node)
      else { break }

      resolvedKeys.append(key)
      breadcrumb.append(
        BreadcrumbEntry(path: resolvedKeys, key: key, title: node.item.displayName))
      currentActions = children
    }

    return ResolvedPath(keys: resolvedKeys, breadcrumb: breadcrumb, actions: currentActions)
  }

  // MARK: - Flattened sequence list

  struct SequenceEntry: Identifiable {
    /// Structural index path is deterministic and remains distinct for invalid duplicates.
    let id: [Int]
    let keys: [String]
    let node: ActionOrGroup

    var display: String { keys.joined(separator: " → ") }
    var type: Type { node.item.type }
    var displayName: String { node.item.displayName }

    var actionValue: String? {
      if case .action(let action) = node { return action.value }
      return nil
    }

    var isFromFallback: Bool { ShortcutsOverview.isFromFallback(node) }
    var fallbackSource: String? { ShortcutsOverview.fallbackSource(node) }
  }

  static func flattenedSequences(
    from actions: [ActionOrGroup], prefix: [String] = [], indexPrefix: [Int] = []
  ) -> [SequenceEntry] {
    var result: [SequenceEntry] = []
    for (index, node) in actions.enumerated() {
      guard let key = node.item.key, !key.isEmpty else { continue }
      let keyPath = prefix + [key]
      let indexPath = indexPrefix + [index]
      if let children = children(of: node) {
        result.append(
          contentsOf: flattenedSequences(
            from: children, prefix: keyPath, indexPrefix: indexPath))
      } else {
        result.append(SequenceEntry(id: indexPath, keys: keyPath, node: node))
      }
    }
    return result
  }
}
