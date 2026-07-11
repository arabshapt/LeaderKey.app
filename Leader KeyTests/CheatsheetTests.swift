import XCTest

@testable import Leader_Key

final class CheatsheetTests: XCTestCase {
  func testPreparedRowsSortFilterAndKeepNodeIdentityRecursively() {
    let firstChild = action(key: "a", label: "First child")
    let secondChild = action(key: "B", label: "Second child")
    let group = Group(
      key: "g",
      label: "Group",
      iconPath: nil,
      stickyMode: nil,
      actions: [.action(secondChild), .action(firstChild)]
    )
    let last = action(key: "z", label: "Last")
    var inherited = action(key: "a", label: "Inherited")
    inherited.isFromFallback = true

    let rows = Cheatsheet.preparedRows(
      from: [.action(last), .action(inherited), .group(group)],
      showFallbackItems: false
    )

    XCTAssertEqual(rows.map { $0.item.item.key }, ["g", "z"])
    XCTAssertEqual(rows.map(\.id), [group.id, last.id])
    XCTAssertEqual(rows[0].children.map { $0.item.item.key }, ["a", "B"])
    XCTAssertEqual(rows[0].children.map(\.id), [firstChild.id, secondChild.id])
    XCTAssertEqual(
      Cheatsheet.preparedRows(
        from: [.action(last), .group(group)],
        showFallbackItems: true
      ).map(\.id),
      [group.id, last.id]
    )
  }

  private func action(key: String, label: String) -> Action {
    Action(
      key: key,
      type: .command,
      label: label,
      value: "true",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )
  }
}
