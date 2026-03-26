import XCTest
@testable import Leader_Key

final class KarCompilerServiceTests: XCTestCase {
  func testPatchedKarabinerRootReplacesOnlyManagedRulesInSelectedProfile() throws {
    let unmanagedRule: [String: Any] = [
      "description": "KeepMe",
      "manipulators": [["type": "basic"]]
    ]
    let managedRule: [String: Any] = [
      "description": "LeaderKeyManaged/Old",
      "manipulators": [["type": "basic", "from": ["key_code": "a"]]]
    ]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "Default",
          "selected": true,
          "complex_modifications": [
            "rules": [unmanagedRule, managedRule]
          ]
        ]
      ]
    ]

    let compiledRules: [[String: Any]] = [
      [
        "description": "LeaderKeyManaged/New",
        "manipulators": [["type": "basic", "from": ["key_code": "b"]]]
      ]
    ]

    let patched = try KarCompilerService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])
    let profile = try XCTUnwrap(profiles.first)
    let complex = try XCTUnwrap(profile["complex_modifications"] as? [String: Any])
    let rules = try XCTUnwrap(complex["rules"] as? [[String: Any]])

    XCTAssertEqual(rules.count, 2)
    XCTAssertEqual(rules[0]["description"] as? String, "KeepMe")
    XCTAssertEqual(rules[1]["description"] as? String, "LeaderKeyManaged/New")
  }

  func testPatchedKarabinerRootOnlyTouchesSelectedProfile() throws {
    let unselectedRule: [String: Any] = ["description": "UnselectedRule"]
    let selectedRule: [String: Any] = ["description": "LeaderKeyManaged/SelectedOld"]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "ProfileA",
          "selected": false,
          "complex_modifications": ["rules": [unselectedRule]]
        ],
        [
          "name": "ProfileB",
          "selected": true,
          "complex_modifications": ["rules": [selectedRule]]
        ]
      ]
    ]

    let compiledRules: [[String: Any]] = [["description": "LeaderKeyManaged/NewRule"]]

    let patched = try KarCompilerService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])

    let firstProfileRules = try XCTUnwrap(
      (profiles[0]["complex_modifications"] as? [String: Any])?["rules"] as? [[String: Any]])
    XCTAssertEqual(firstProfileRules.count, 1)
    XCTAssertEqual(firstProfileRules[0]["description"] as? String, "UnselectedRule")

    let secondProfileRules = try XCTUnwrap(
      (profiles[1]["complex_modifications"] as? [String: Any])?["rules"] as? [[String: Any]])
    XCTAssertEqual(secondProfileRules.count, 1)
    XCTAssertEqual(secondProfileRules[0]["description"] as? String, "LeaderKeyManaged/NewRule")
    XCTAssertEqual(profiles[1]["selected"] as? Bool, true)
  }

  func testPatchedKarabinerRootKeepsManagedBlockPosition() throws {
    let leadingRule: [String: Any] = ["description": "LeadingRule"]
    let managedRuleA: [String: Any] = ["description": "LeaderKeyManaged/OldA"]
    let managedRuleB: [String: Any] = ["description": "LeaderKeyManaged/OldB"]
    let trailingRule: [String: Any] = ["description": "TrailingRule"]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "Default",
          "selected": true,
          "complex_modifications": [
            "rules": [leadingRule, managedRuleA, managedRuleB, trailingRule]
          ]
        ]
      ]
    ]

    let compiledRules: [[String: Any]] = [
      ["description": "LeaderKeyManaged/NewA"],
      ["description": "LeaderKeyManaged/NewB"]
    ]

    let patched = try KarCompilerService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])
    let profile = try XCTUnwrap(profiles.first)
    let complex = try XCTUnwrap(profile["complex_modifications"] as? [String: Any])
    let rules = try XCTUnwrap(complex["rules"] as? [[String: Any]])
    let descriptions = rules.compactMap { $0["description"] as? String }

    XCTAssertEqual(
      descriptions,
      ["LeadingRule", "LeaderKeyManaged/NewA", "LeaderKeyManaged/NewB", "TrailingRule"])
  }
}
