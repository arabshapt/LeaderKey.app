import XCTest

@testable import Leader_Key

final class ShortcutsOverviewModelTests: XCTestCase {
  func testShiftMapCoversEveryRenderedPhysicalCap() {
    XCTAssertEqual(
      Set(ShortcutsOverview.shiftedKeyByBaseKey.keys),
      ShortcutsOverview.candidateKeys
    )
    XCTAssertEqual(ShortcutsOverview.shiftedKey(for: "1"), "!")
    XCTAssertEqual(ShortcutsOverview.shiftedKey(for: ";"), ":")
    XCTAssertEqual(ShortcutsOverview.shiftedKey(for: "/"), "?")
  }

  func testLevelViewIndexesExactKeysAndSkipsMissingKeys() {
    let actions: [ActionOrGroup] = [
      action("a", label: "Alpha"),
      action(nil, label: "Missing"),
      action("", label: "Empty"),
      action("A", label: "Shift Alpha"),
    ]

    let level = ShortcutsOverview.levelView(for: actions)

    XCTAssertEqual(Set(level.assignments.keys), ["a", "A"])
    XCTAssertEqual(level.assignments["a"]?.displayName, "Alpha")
    XCTAssertEqual(level.assignments["A"]?.displayName, "Shift Alpha")
  }

  func testDuplicateExactKeyKeepsFirstAndExposesConflictMetadata() {
    let level = ShortcutsOverview.levelView(for: [
      action("a", label: "First"),
      action("a", label: "Second"),
      action("a", label: "Third"),
    ])

    XCTAssertEqual(level.assignments["a"]?.displayName, "First")
    XCTAssertEqual(
      level.duplicateConflicts["a"]?.assignments.map(\.displayName),
      ["First", "Second", "Third"]
    )
    XCTAssertEqual(level.duplicateConflicts["a"]?.shadowed.count, 2)
  }

  func testFreeKeysUsePhysicalBaseAndShiftOccupancy() {
    let level = ShortcutsOverview.levelView(for: [
      action("T", label: "Shift T"),
      action("!", label: "Bang"),
      action(":", label: "Colon"),
      action("?", label: "Question"),
    ])

    XCTAssertFalse(level.freeKeys.contains("t"))
    XCTAssertFalse(level.freeKeys.contains("1"))
    XCTAssertFalse(level.freeKeys.contains(";"))
    XCTAssertFalse(level.freeKeys.contains("/"))
    XCTAssertTrue(level.freeKeys.contains("q"))
  }

  func testFallbackProvenanceFlowsThroughAssignmentsAndSequences() {
    var inherited = Action(
      key: "f", type: .command, label: "Fallback", value: "echo fallback")
    inherited.isFromFallback = true
    inherited.fallbackSource = "Fallback App Config"
    let node = ActionOrGroup.action(inherited)

    let assignment = ShortcutsOverview.levelView(for: [node]).assignments["f"]
    let sequence = ShortcutsOverview.flattenedSequences(from: [node]).first

    XCTAssertEqual(assignment?.isFromFallback, true)
    XCTAssertEqual(assignment?.fallbackSource, "Fallback App Config")
    XCTAssertEqual(sequence?.isFromFallback, true)
    XCTAssertEqual(sequence?.fallbackSource, "Fallback App Config")
  }

  func testFlattenedSequencesTraverseGroupsAndLayersDepthFirst() {
    let actions: [ActionOrGroup] = [
      .group(
        Group(
          key: "o", label: "Open",
          actions: [
            action("s", label: "Safari", type: .application, value: "/Applications/Safari.app"),
            .layer(
              Layer(
                key: "w", label: "Web", tapAction: nil,
                actions: [
                  action("n", label: "New", type: .shortcut, value: "Cn")
                ])),
          ])),
      action("caps_lock", label: "Outside Grid"),
    ]

    let entries = ShortcutsOverview.flattenedSequences(from: actions)

    XCTAssertEqual(entries.map(\.keys), [["o", "s"], ["o", "w", "n"], ["caps_lock"]])
    XCTAssertEqual(entries.map(\.display), ["o → s", "o → w → n", "caps_lock"])
    XCTAssertEqual(entries.map(\.displayName), ["Safari", "New", "Outside Grid"])
  }

  func testFlattenedSequencesHaveStableStructuralIdentity() {
    func makeTree() -> [ActionOrGroup] {
      [
        action("a", label: "First"),
        .group(Group(key: "g", label: "Group", actions: [action("x", label: "Nested")])),
      ]
    }

    let first = ShortcutsOverview.flattenedSequences(from: makeTree())
    let second = ShortcutsOverview.flattenedSequences(from: makeTree())

    XCTAssertEqual(first.map(\.id), second.map(\.id))
    XCTAssertEqual(first.map(\.id), [[0], [1, 0]])
  }

  func testResolvePathUsesExactFirstMatchFromFreshRoot() {
    let original: [ActionOrGroup] = [
      .group(Group(key: "g", label: "First Group", actions: [action("a", label: "Alpha")])),
      .group(Group(key: "g", label: "Shadowed Group", actions: [action("b", label: "Beta")])),
    ]

    let resolved = ShortcutsOverview.resolvePath(["g"], from: original)
    XCTAssertEqual(resolved.keys, ["g"])
    XCTAssertEqual(resolved.breadcrumb.map(\.title), ["First Group"])
    XCTAssertEqual(resolved.breadcrumb.map(\.id), [["g"]])
    XCTAssertEqual(resolved.actions.first?.item.key, "a")

    let reloaded: [ActionOrGroup] = [
      .group(Group(key: "g", label: "Reloaded", actions: [action("z", label: "Zulu")]))
    ]
    let refreshed = ShortcutsOverview.resolvePath(["g", "missing"], from: reloaded)
    XCTAssertEqual(refreshed.keys, ["g"])
    XCTAssertEqual(refreshed.breadcrumb.map(\.title), ["Reloaded"])
    XCTAssertEqual(refreshed.actions.first?.item.key, "z")
  }

  func testEmptyContainersProduceNoFlattenedRows() {
    let entries = ShortcutsOverview.flattenedSequences(from: [
      .group(Group(key: "g", label: "Empty Group", actions: [])),
      .layer(Layer(key: "l", label: "Empty Layer", tapAction: nil, actions: [])),
    ])

    XCTAssertTrue(entries.isEmpty)
  }

  private func action(
    _ key: String?, label: String, type: Type = .command, value: String = "echo test"
  ) -> ActionOrGroup {
    .action(Action(key: key, type: type, label: label, value: value))
  }
}
