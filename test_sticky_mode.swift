#!/usr/bin/env swift

import Foundation

// Load the test config
let configPath = "test-sticky-config.json"
let configData = try! Data(contentsOf: URL(fileURLWithPath: configPath))

// Parse it into UserConfig structure
struct TestConfig: Codable {
  let key: String?
  let type: String
  let label: String?
  let stickyMode: Bool?
  let actions: [TestItem]?
  let value: String?
}

enum TestItem: Codable {
  case action(TestConfig)
  case group(TestConfig)
  
  private enum CodingKeys: String, CodingKey {
    case key, type, value, actions, label, stickyMode
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    
    if type == "group" {
      let key = try container.decodeIfPresent(String.self, forKey: .key)
      let label = try container.decodeIfPresent(String.self, forKey: .label)
      let stickyMode = try container.decodeIfPresent(Bool.self, forKey: .stickyMode)
      let actions = try container.decode([TestItem].self, forKey: .actions)
      self = .group(TestConfig(key: key, type: type, label: label, stickyMode: stickyMode, actions: actions, value: nil))
    } else {
      let key = try container.decodeIfPresent(String.self, forKey: .key)
      let label = try container.decodeIfPresent(String.self, forKey: .label)
      let value = try container.decode(String.self, forKey: .value)
      let stickyMode = try container.decodeIfPresent(Bool.self, forKey: .stickyMode)
      self = .action(TestConfig(key: key, type: type, label: label, stickyMode: stickyMode, actions: nil, value: value))
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .action(let action):
      try container.encode(action.key, forKey: .key)
      try container.encode(action.type, forKey: .type)
      try container.encode(action.value, forKey: .value)
      try container.encodeIfPresent(action.label, forKey: .label)
      try container.encodeIfPresent(action.stickyMode, forKey: .stickyMode)
    case .group(let group):
      try container.encode(group.key, forKey: .key)
      try container.encode(group.type, forKey: .type)
      try container.encode(group.actions, forKey: .actions)
      try container.encodeIfPresent(group.label, forKey: .label)
      try container.encodeIfPresent(group.stickyMode, forKey: .stickyMode)
    }
  }
}

let decoder = JSONDecoder()
let rootConfig = try! decoder.decode(TestConfig.self, from: configData)

// Walk through the config and check sticky mode
func checkStickyMode(_ config: TestConfig, level: Int = 0) {
  let indent = String(repeating: "  ", count: level)
  
  if let key = config.key {
    print("\(indent)[\(key)] \(config.label ?? "No label")")
  } else {
    print("\(indent)Root: \(config.label ?? "No label")")
  }
  
  if let stickyMode = config.stickyMode {
    print("\(indent)  -> stickyMode: \(stickyMode)")
  }
  
  if let actions = config.actions {
    for action in actions {
      switch action {
      case .group(let group):
        checkStickyMode(group, level: level + 1)
      case .action(let act):
        let actIndent = String(repeating: "  ", count: level + 1)
        print("\(actIndent)[\(act.key ?? "?")] \(act.label ?? "No label") - \(act.type)")
      }
    }
  }
}

print("=== Test Config Structure ===")
checkStickyMode(rootConfig)

print("\n=== Expected Behavior ===")
print("Group 'o' has stickyMode: true")
print("  - After executing action 'a', should stay in group 'o'")
print("  - leaderkey_sticky should be set to 1")
print("  - leader_state should remain at group 'o' state")
print("")
print("Group 'n' has stickyMode: false")
print("  - After executing action 'x', should exit Leader Key")
print("  - All variables should reset to 0")