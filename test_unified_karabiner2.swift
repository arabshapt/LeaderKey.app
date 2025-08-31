#!/usr/bin/env swift

import Foundation

// Test unified Karabiner2 config generation
let tempFile = URL(fileURLWithPath: "/tmp/test_unified.swift")
let testCode = """
import Foundation

// Copy the required structs
struct UserConfig: Codable {
    var root: Group
    let fileName: String = "test.json"
    
    init(root: Group = Group(actions: [], label: nil, key: nil)) {
        self.root = root
    }
    
    func getConfig(for bundleId: String?) -> Group {
        // Simplified - just return root for testing
        return root
    }
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

// Test configurations
let globalConfigJSON = \"\"\"
{
  "actions": [
    {
      "type": "action",
      "key": "a",
      "label": "Apps",
      "command": "open -a Finder"
    },
    {
      "type": "group",
      "key": "g",
      "label": "Git",
      "actions": [
        {
          "type": "action",
          "key": "s",
          "label": "Status",
          "command": "git status"
        }
      ]
    }
  ]
}
\"\"\"

let vscodeConfigJSON = \"\"\"
{
  "actions": [
    {
      "type": "action",
      "key": "c",
      "label": "Code",
      "command": "code ."
    },
    {
      "type": "group",
      "key": "g",
      "label": "Go to",
      "actions": [
        {
          "type": "action",
          "key": "d",
          "label": "Definition",
          "command": "vscode:definition"
        }
      ]
    }
  ]
}
\"\"\"

let terminalConfigJSON = \"\"\"
{
  "actions": [
    {
      "type": "action",
      "key": "c",
      "label": "Clear",
      "command": "clear"
    },
    {
      "type": "action",
      "key": "n",
      "label": "New Tab",
      "command": "osascript -e 'tell app Terminal to do script'"
    }
  ]
}
\"\"\"

// Decode configs
let globalRoot = try! JSONDecoder().decode(Group.self, from: globalConfigJSON.data(using: .utf8)!)
let vscodeRoot = try! JSONDecoder().decode(Group.self, from: vscodeConfigJSON.data(using: .utf8)!)
let terminalRoot = try! JSONDecoder().decode(Group.self, from: terminalConfigJSON.data(using: .utf8)!)

// Create UserConfigs
let globalConfig = UserConfig(root: globalRoot)
let vscodeConfig = UserConfig(root: vscodeRoot)
let terminalConfig = UserConfig(root: terminalRoot)

// Test unified generation
print("=== Testing Unified Karabiner2 EDN Generation ===\\n")

let unifiedEDN = Karabiner2Exporter.generateUnifiedGokuEDN(
    globalConfig: globalConfig,
    appConfigs: [
        ("com.microsoft.VSCode", vscodeConfig),
        ("com.apple.Terminal", terminalConfig)
    ]
)

print(unifiedEDN)

print("\\n=== Analysis ===\\n")

// Check for :applications section
let hasApplications = unifiedEDN.contains(":applications")
print("Has :applications section: \\(hasApplications)")

// Check for app aliases
let hasVSCodeAlias = unifiedEDN.contains(":vscode")
let hasTerminalAlias = unifiedEDN.contains(":terminal")
print("Has VSCode alias: \\(hasVSCodeAlias)")
print("Has Terminal alias: \\(hasTerminalAlias)")

// Check for activation keys
let hasCmdK = unifiedEDN.contains(":!Ck")
let hasCmdShiftK = unifiedEDN.contains(":!CSk")
print("Has Cmd+K activation: \\(hasCmdK)")
print("Has Cmd+Shift+K activation: \\(hasCmdShiftK)")

// Check for state isolation
let lines = unifiedEDN.components(separatedBy: "\\n")
let globalStates = lines.filter { $0.contains("GLOBAL CONFIG") }.count
let vscodeStates = lines.filter { $0.contains("VSCODE CONFIG") }.count
let terminalStates = lines.filter { $0.contains("TERMINAL CONFIG") }.count
print("\\nSection counts:")
print("  Global sections: \\(globalStates)")
print("  VSCode sections: \\(vscodeStates)")
print("  Terminal sections: \\(terminalStates)")

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