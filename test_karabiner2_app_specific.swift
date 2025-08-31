#!/usr/bin/env swift

import Foundation

// Create test with proper compilation
let tempFile = URL(fileURLWithPath: "/tmp/test_app_specific.swift")
let testCode = """
import Foundation

// Copy the required structs
struct UserConfig: Codable {
    let root: Group
}

struct Group: Codable {
    let actions: [ActionOrGroup]
    let label: String?
    let key: String?
}

enum ActionOrGroup: Codable {
    case action(Action)
    case group(Group)
    
    var item: ActionItem {
        switch self {
        case .action(let action): return action
        case .group(let group): return group
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        if type == "action" {
            self = .action(try Action(from: decoder))
        } else if type == "group" {
            self = .group(try Group(from: decoder))
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .action(let action):
            try action.encode(to: encoder)
        case .group(let group):
            try group.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}

struct Action: Codable, ActionItem {
    let type: String = "action"
    let key: String?
    let label: String?
    let command: String?
}

protocol ActionItem {
    var key: String? { get }
}

extension Group: ActionItem {}

// Include the Karabiner2Exporter class
\(try! String(contentsOf: URL(fileURLWithPath: "Leader Key/Karabiner2Exporter.swift"), encoding: .utf8))

// Test configuration
let testConfigJSON = \"\"\"
{
  "root": {
    "actions": [
      {
        "type": "action",
        "key": "a",
        "label": "Apps",
        "command": "ls -la"
      },
      {
        "type": "group",
        "key": "t",
        "label": "Terminal",
        "actions": [
          {
            "type": "action",
            "key": "n",
            "label": "New Window",
            "command": "open -a Terminal"
          },
          {
            "type": "action",
            "key": "c",
            "label": "Clear",
            "command": "clear"
          }
        ]
      }
    ]
  }
}
\"\"\"

// Decode the test configuration
let jsonData = testConfigJSON.data(using: .utf8)!
let config = try! JSONDecoder().decode(UserConfig.self, from: jsonData)

print("=== Testing App-Specific Conditions ===\\n")

// Test 1: Without bundle ID (global)
print("Test 1: Global config (no bundle ID)")
let globalEDN = Karabiner2Exporter.generateGokuEDN(from: config, bundleId: nil)
let globalLines = globalEDN.components(separatedBy: "\\n")
let globalHasConditions = globalLines.contains { $0.contains("{:conditions") }
print("Has conditions: \\(globalHasConditions) (should be false)")
print("Sample lines:")
for line in globalLines.filter({ $0.contains(":!Ck") || $0.contains("[:a") }).prefix(2) {
    print("  \\(line.trimmingCharacters(in: .whitespacesAndNewlines))")
}

print("\\n" + String(repeating: "-", count: 50) + "\\n")

// Test 2: With Terminal bundle ID
print("Test 2: App-specific config for Terminal")
let terminalEDN = Karabiner2Exporter.generateGokuEDN(from: config, bundleId: "com.apple.Terminal")
let terminalLines = terminalEDN.components(separatedBy: "\\n")
let terminalConditions = terminalLines.filter { $0.contains("frontmost_application_is") }
print("Number of frontmost_application_is conditions: \\(terminalConditions.count)")
print("Sample condition lines:")
for (index, line) in terminalConditions.prefix(3).enumerated() {
    print("  \\(index + 1). \\(line.trimmingCharacters(in: .whitespacesAndNewlines))")
}

print("\\n" + String(repeating: "-", count: 50) + "\\n")

// Test 3: Verify condition format
print("Test 3: Condition format verification")
let expectedCondition = "[:frontmost_application_is [\\"com.apple.Terminal\\"]]"
let hasCorrectFormat = terminalLines.contains { $0.contains(expectedCondition) }
print("Has correct frontmost_application_is format: \\(hasCorrectFormat)")

// Check activation has condition
if let activationLine = terminalLines.first(where: { $0.contains(":!Ck") }) {
    print("Activation line with condition:")
    print("  \\(activationLine.trimmingCharacters(in: .whitespacesAndNewlines))")
}

// Check a state transition has condition
if let transitionLine = terminalLines.first(where: { $0.contains("[:a") && $0.contains("leader_state") }) {
    print("State transition with condition:")
    print("  \\(transitionLine.trimmingCharacters(in: .whitespacesAndNewlines))")
}

print("\\n=== Test Complete ===")
"""

try! testCode.write(to: tempFile, atomically: true, encoding: .utf8)

// Compile and run the test
let task = Process()
task.launchPath = "/usr/bin/swift"
task.arguments = [tempFile.path]

let pipe = Pipe()
task.standardOutput = pipe
task.standardError = pipe

task.launch()
task.waitUntilExit()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
print(String(data: data, encoding: .utf8)!)

try? FileManager.default.removeItem(at: tempFile)