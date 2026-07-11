import Foundation

enum CommandScoutSequenceFeasibility: Equatable {
  case available(physicalPenalty: Int)
  case blockedPrefix([String])
  case occupiedLeaf([String])
  case invalid
}

/// Exact-case structural view used while assigning a batch of suggestions.
/// Intermediate slots may only traverse groups; actions and layers block them.
struct CommandScoutSequenceTrie {
  private struct Node {
    var slots: [String: Slot] = [:]
  }

  private indirect enum Slot {
    case group(Node)
    case occupied
  }

  private var root: Node

  init(root: Group) {
    self.root = Self.node(from: root.actions)
  }

  func feasibility(for tokens: [String]) -> CommandScoutSequenceFeasibility {
    guard Self.isValid(tokens) else { return .invalid }
    return Self.feasibility(for: tokens, index: 0, in: root, physicalPenalty: 0)
  }

  @discardableResult
  mutating func reserve(_ tokens: [String]) -> Bool {
    guard case .available = feasibility(for: tokens) else { return false }
    Self.reserve(tokens, index: 0, in: &root)
    return true
  }

  private static func node(from actions: [ActionOrGroup]) -> Node {
    var node = Node()
    for item in actions {
      guard let key = item.item.key, !key.isEmpty, node.slots[key] == nil else { continue }
      if case .group(let group) = item {
        node.slots[key] = .group(Self.node(from: group.actions))
      } else {
        node.slots[key] = .occupied
      }
    }
    return node
  }

  private static func feasibility(
    for tokens: [String],
    index: Int,
    in node: Node,
    physicalPenalty: Int
  ) -> CommandScoutSequenceFeasibility {
    let token = tokens[index]
    let path = Array(tokens.prefix(index + 1))
    let isLeaf = index == tokens.count - 1

    if isLeaf {
      guard node.slots[token] == nil else { return .occupiedLeaf(path) }
      return .available(
        physicalPenalty: physicalPenalty + physicalOpeningPenalty(for: token, in: node))
    }

    switch node.slots[token] {
    case .group(let child):
      return feasibility(
        for: tokens,
        index: index + 1,
        in: child,
        physicalPenalty: physicalPenalty
      )
    case .occupied:
      return .blockedPrefix(path)
    case nil:
      return feasibility(
        for: tokens,
        index: index + 1,
        in: Node(),
        physicalPenalty: physicalPenalty + physicalOpeningPenalty(for: token, in: node)
      )
    }
  }

  private static func reserve(_ tokens: [String], index: Int, in node: inout Node) {
    let token = tokens[index]
    if index == tokens.count - 1 {
      node.slots[token] = .occupied
      return
    }

    var child: Node
    if case .group(let existingChild) = node.slots[token] {
      child = existingChild
    } else {
      child = Node()
    }
    reserve(tokens, index: index + 1, in: &child)
    node.slots[token] = .group(child)
  }

  private static func physicalOpeningPenalty(for key: String, in node: Node) -> Int {
    guard let pair = ShortcutsOverview.physicalKeyPair(for: key) else { return 0 }
    let counterpart = key == pair.base ? pair.shifted : pair.base
    return node.slots[counterpart] == nil ? 0 : 1
  }

  private static func isValid(_ tokens: [String]) -> Bool {
    !tokens.isEmpty && tokens.count <= 3
      && tokens.allSatisfy(CommandScoutSequenceNormalizer.isAllowedToken)
  }
}

enum CommandScoutTreeInsertionFailure: Equatable {
  case invalidSequence
  case blockedPrefix([String])
  case occupiedLeaf([String])
}

struct CommandScoutTreeInsertionResult {
  let root: Group
  let failure: CommandScoutTreeInsertionFailure?

  var inserted: Bool { failure == nil }
}

/// Pure insertion shared by the editor apply path and projected Scout preview.
enum CommandScoutTreeInsertion {
  static func inserting(
    tokens: [String],
    action: Action,
    category: String,
    into root: Group
  ) -> CommandScoutTreeInsertionResult {
    guard !tokens.isEmpty, tokens.count <= 3,
      tokens.allSatisfy(CommandScoutSequenceNormalizer.isAllowedToken)
    else {
      return CommandScoutTreeInsertionResult(root: root, failure: .invalidSequence)
    }

    var updatedRoot = root
    var leafAction = action
    leafAction.key = tokens.last
    let failure = insert(
      tokens: tokens,
      tokenIndex: 0,
      leafAction: leafAction,
      category: category,
      actions: &updatedRoot.actions
    )
    return CommandScoutTreeInsertionResult(root: updatedRoot, failure: failure)
  }

  static func projectedRoot(
    byInserting suggestions: [CommandScoutSuggestion],
    into root: Group
  ) -> Group {
    suggestions.reduce(root) { projectedRoot, suggestion in
      guard let action = suggestion.makeAction() else { return projectedRoot }
      let result = inserting(
        tokens: suggestion.sequenceTokens,
        action: action,
        category: suggestion.category,
        into: projectedRoot
      )
      return result.inserted ? result.root : projectedRoot
    }
  }

  private static func insert(
    tokens: [String],
    tokenIndex: Int,
    leafAction: Action,
    category: String,
    actions: inout [ActionOrGroup]
  ) -> CommandScoutTreeInsertionFailure? {
    let token = tokens[tokenIndex]
    let path = Array(tokens.prefix(tokenIndex + 1))
    let isLeaf = tokenIndex == tokens.count - 1

    if isLeaf {
      guard !actions.contains(where: { $0.item.key == token }) else {
        return .occupiedLeaf(path)
      }
      actions.append(.action(leafAction))
      return nil
    }

    if let existingIndex = actions.firstIndex(where: { $0.item.key == token }) {
      guard case .group(var existingGroup) = actions[existingIndex] else {
        return .blockedPrefix(path)
      }
      if let failure = insert(
        tokens: tokens,
        tokenIndex: tokenIndex + 1,
        leafAction: leafAction,
        category: category,
        actions: &existingGroup.actions
      ) {
        return failure
      }
      actions[existingIndex] = .group(existingGroup)
      return nil
    }

    actions.append(
      .group(
        createdGroup(
          tokens: tokens,
          tokenIndex: tokenIndex,
          leafAction: leafAction,
          category: category
        )))
    return nil
  }

  private static func createdGroup(
    tokens: [String],
    tokenIndex: Int,
    leafAction: Action,
    category: String
  ) -> Group {
    let nextIndex = tokenIndex + 1
    let child: ActionOrGroup
    if nextIndex == tokens.count - 1 {
      child = .action(leafAction)
    } else {
      child = .group(
        createdGroup(
          tokens: tokens,
          tokenIndex: nextIndex,
          leafAction: leafAction,
          category: category
        ))
    }
    return Group(
      key: tokens[tokenIndex],
      label: tokenIndex == 0
        ? category.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        : nil,
      actions: [child]
    )
  }
}

extension String {
  fileprivate var nonEmpty: String? { isEmpty ? nil : self }
}
