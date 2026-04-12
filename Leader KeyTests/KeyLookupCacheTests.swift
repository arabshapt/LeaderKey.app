import XCTest
@testable import Leader_Key

class KeyLookupCacheTests: XCTestCase {

  func testGetItemReturnsCorrectActionOrGroup() {
    let cache = KeyLookupCache()

    let action = Action(key: "a", type: .application, label: "App", value: "/Applications/Safari.app")
    let subgroup = Group(key: "b", label: "SubGroup", actions: [
      .action(Action(key: "x", type: .url, label: "URL", value: "https://example.com")),
    ])
    let root = Group(key: nil, label: "Root", actions: [
      .action(action),
      .group(subgroup),
    ])

    cache.buildFromGroup(root)

    // Lookup existing action
    let hitA = cache.getItem(forKey: "a", inGroupId: root.id)
    XCTAssertNotNil(hitA)
    if case .action(let found) = hitA {
      XCTAssertEqual(found.key, "a")
      XCTAssertEqual(found.label, "App")
    } else {
      XCTFail("Expected action, got group")
    }

    // Lookup existing group
    let hitB = cache.getItem(forKey: "b", inGroupId: root.id)
    XCTAssertNotNil(hitB)
    if case .group(let found) = hitB {
      XCTAssertEqual(found.key, "b")
      XCTAssertEqual(found.label, "SubGroup")
    } else {
      XCTFail("Expected group, got action")
    }

    // Lookup in subgroup
    let hitX = cache.getItem(forKey: "x", inGroupId: subgroup.id)
    XCTAssertNotNil(hitX)

    // Lookup missing key returns nil
    let miss = cache.getItem(forKey: "z", inGroupId: root.id)
    XCTAssertNil(miss)

    // Lookup valid key in wrong group returns nil
    let wrongGroup = cache.getItem(forKey: "a", inGroupId: subgroup.id)
    XCTAssertNil(wrongGroup)
  }

  func testDuplicateKeysLastWins() {
    let cache = KeyLookupCache()

    let action1 = Action(key: "a", type: .application, label: "First", value: "/first")
    let action2 = Action(key: "a", type: .url, label: "Second", value: "/second")
    let root = Group(key: nil, label: "Root", actions: [
      .action(action1),
      .action(action2),
    ])

    cache.buildFromGroup(root)

    // With duplicate keys, cache stores last one (dict overwrite)
    let hit = cache.getItem(forKey: "a", inGroupId: root.id)
    XCTAssertNotNil(hit)
    if case .action(let found) = hit {
      XCTAssertEqual(found.label, "Second")
    } else {
      XCTFail("Expected action")
    }
  }

  func testClearRemovesAllItems() {
    let cache = KeyLookupCache()
    let root = Group(key: nil, label: "Root", actions: [
      .action(Action(key: "a", type: .url, label: "Test", value: "https://test.com")),
    ])

    cache.buildFromGroup(root)
    XCTAssertNotNil(cache.getItem(forKey: "a", inGroupId: root.id))

    cache.clear()
    XCTAssertNil(cache.getItem(forKey: "a", inGroupId: root.id))
  }
}
