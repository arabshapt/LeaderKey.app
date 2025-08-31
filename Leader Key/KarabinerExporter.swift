import AppKit
import Foundation

final class KarabinerExporter {

  enum ExportFormat {
    case karabinerJSON
    case gokuEDN
    case karabiner2EDN
  }

  static func exportConfiguration(userConfig: UserConfig, format: ExportFormat) -> String {
    switch format {
    case .karabinerJSON:
      return generateKarabinerJSON(from: userConfig)
    case .gokuEDN:
      return generateGokuEDN(from: userConfig)
    case .karabiner2EDN:
      // Detect if we're exporting an app-specific config
      var bundleId: String? = nil
      
      // Check if the frontmost app has a specific config  
      if let frontmostApp = NSWorkspace.shared.frontmostApplication,
         let appBundleId = frontmostApp.bundleIdentifier,
         appBundleId != Bundle.main.bundleIdentifier // Don't use Leader Key's own bundle ID
      {
        // Check if this app has a specific config
        let appConfigFile = "app.\(appBundleId).json"
        let configDir = FileManager.default.homeDirectoryForCurrentUser
          .appendingPathComponent("Library/Application Support/Leader Key")
        let appConfigPath = configDir.appendingPathComponent(appConfigFile)
        
        if FileManager.default.fileExists(atPath: appConfigPath.path) {
          bundleId = appBundleId
        }
      }
      
      return Karabiner2Exporter.generateGokuEDN(from: userConfig, bundleId: bundleId)
    }
  }

  static func saveToFile(_ content: String, format: ExportFormat) -> URL? {
    let panel = NSSavePanel()
    switch format {
    case .karabinerJSON:
      panel.nameFieldStringValue = "leader_key_config.json"
      panel.allowedContentTypes = [.json]
    case .gokuEDN:
      panel.nameFieldStringValue = "leader_key_config.edn"
      panel.allowedContentTypes = [.plainText]
    case .karabiner2EDN:
      panel.nameFieldStringValue = "leader_key_state_machine.edn"
      panel.allowedContentTypes = [.plainText]
    }
    panel.canCreateDirectories = true
    panel.showsTagField = false

    guard panel.runModal() == .OK, let url = panel.url else {
      return nil
    }

    do {
      try content.write(to: url, atomically: true, encoding: .utf8)
      return url
    } catch {
      debugLog("[KarabinerExporter] Failed to save file: \(error)")
      return nil
    }
  }

  private static func generateKarabinerJSON(from config: UserConfig) -> String {
    var allKeys = Set<String>()
    collectKeysFromGroup(config.root, into: &allKeys)

    // Check if CLI tool is available
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let useCLI = FileManager.default.fileExists(atPath: cliPath)

    let letterManipulators = "abcdefghijklmnopqrstuvwxyz".map { letter in
      let key = String(letter)
      guard allKeys.contains(key) else { return nil }
      let command =
        useCLI ? "\(cliPath) key '\(key)'" : "echo 'key \(key)' | nc -U /tmp/leaderkey.sock"
      return """
                {
                  "type": "basic",
                  "from": { "key_code": "\(key)" },
                  "to": [{ "shell_command": "\(command)" }],
                  "conditions": [{ "type": "variable_if", "name": "leader_mode", "value": 1 }]
                }
        """
    }.compactMap { $0 }.joined(separator: ",\n")

    let numberManipulators = "0123456789".map { number in
      let key = String(number)
      guard allKeys.contains(key) else { return nil }
      let command =
        useCLI ? "\(cliPath) key '\(key)'" : "echo 'key \(key)' | nc -U /tmp/leaderkey.sock"
      return """
                {
                  "type": "basic",
                  "from": { "key_code": "\(key)" },
                  "to": [{ "shell_command": "\(command)" }],
                  "conditions": [{ "type": "variable_if", "name": "leader_mode", "value": 1 }]
                }
        """
    }.compactMap { $0 }.joined(separator: ",\n")

    let specialKeyManipulators = [
      ("space", "spacebar"),
      ("return", "return_or_enter"),
      ("tab", "tab"),
      ("delete", "delete_or_backspace"),
      (".", "period"),
      (",", "comma"),
      (";", "semicolon"),
      ("/", "slash"),
    ].compactMap { (key, karabinerCode) -> String? in
      guard allKeys.contains(key) || allKeys.contains(karabinerCode) else { return nil }
      let command =
        useCLI
        ? "\(cliPath) key '\(karabinerCode)'"
        : "echo 'key \(karabinerCode)' | nc -U /tmp/leaderkey.sock"
      return """
                {
                  "type": "basic",
                  "from": { "key_code": "\(karabinerCode)" },
                  "to": [{ "shell_command": "\(command)" }],
                  "conditions": [{ "type": "variable_if", "name": "leader_mode", "value": 1 }]
                }
        """
    }.joined(separator: ",\n")

    let allManipulators = [letterManipulators, numberManipulators, specialKeyManipulators]
      .filter { !$0.isEmpty }
      .joined(separator: ",\n")

    let activateCommand =
      useCLI ? "\(cliPath) activate" : "echo 'activate' | nc -U /tmp/leaderkey.sock"
    let deactivateCommand =
      useCLI ? "\(cliPath) deactivate" : "echo 'deactivate' | nc -U /tmp/leaderkey.sock"

    return """
      {
        "title": "Leader Key Integration (Generated)",
        "rules": [
          {
            "description": "Leader Key - Activate with Cmd+K",
            "manipulators": [
              {
                "type": "basic",
                "from": {
                  "key_code": "k",
                  "modifiers": {
                    "mandatory": ["command"]
                  }
                },
                "to": [
                  {
                    "shell_command": "\(activateCommand)"
                  },
                  {
                    "set_variable": {
                      "name": "leader_mode",
                      "value": 1
                    }
                  }
                ]
              }
            ]
          },
          {
            "description": "Leader Key - Deactivate with Escape",
            "manipulators": [
              {
                "type": "basic",
                "from": {
                  "key_code": "escape"
                },
                "to": [
                  {
                    "key_code": "escape"
                  },
                  {
                    "set_variable": {
                      "name": "leader_mode",
                      "value": 0
                    }
                  },
                  {
                    "shell_command": "\(deactivateCommand)"
                  }
                ],
                "conditions": [
                  {
                    "type": "variable_if",
                    "name": "leader_mode",
                    "value": 1
                  }
                ]
              }
            ]
          },
          {
            "description": "Leader Key - Forward configured keys",
            "manipulators": [
      \(allManipulators)
            ]
          }
        ]
      }
      """
  }

  private static func generateGokuEDN(from config: UserConfig) -> String {
    var allKeys = Set<String>()
    collectKeysFromGroup(config.root, into: &allKeys)

    // Check if CLI tool is available
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let useCLI = FileManager.default.fileExists(atPath: cliPath)

    let letterRules = "abcdefghijklmnopqrstuvwxyz".compactMap { letter -> String? in
      let key = String(letter)
      guard allKeys.contains(key) else { return nil }
      let command =
        useCLI ? "\(cliPath) key '\(key)'" : "echo 'key \(key)' | nc -U /tmp/leaderkey.sock"
      return "   [:\(key) [[:shell \"\(command)\"]] [\"leader_mode\" 1]]"
    }.joined(separator: "\n")

    let numberRules = "0123456789".compactMap { number -> String? in
      let key = String(number)
      guard allKeys.contains(key) else { return nil }
      let command =
        useCLI ? "\(cliPath) key '\(key)'" : "echo 'key \(key)' | nc -U /tmp/leaderkey.sock"
      return "   [:\(key) [[:shell \"\(command)\"]] [\"leader_mode\" 1]]"
    }.joined(separator: "\n")

    let specialKeyRules = [
      ("space", "spacebar"),
      ("return", "return_or_enter"),
      ("tab", "tab"),
      ("delete", "delete_or_backspace"),
      (".", "period"),
      (",", "comma"),
      (";", "semicolon"),
      ("/", "slash"),
    ].compactMap { (key, gokuCode) -> String? in
      guard
        allKeys.contains(key)
          || allKeys.contains(gokuCode.replacingOccurrences(of: "_or_", with: ""))
      else { return nil }
      let command =
        useCLI
        ? "\(cliPath) key '\(gokuCode)'" : "echo 'key \(gokuCode)' | nc -U /tmp/leaderkey.sock"
      return
        "   [:\(gokuCode) [[:shell \"\(command)\"]] [\"leader_mode\" 1]]"
    }.joined(separator: "\n")

    // Pre-compute activation/deactivation commands to avoid complex string interpolation
    let activateAppCmd =
      useCLI ? "\(cliPath) activate app" : "echo 'activate app' | nc -U /tmp/leaderkey.sock"
    let activateGlobalCmd =
      useCLI ? "\(cliPath) activate global" : "echo 'activate global' | nc -U /tmp/leaderkey.sock"
    let deactivateCmd =
      useCLI ? "\(cliPath) deactivate" : "echo 'deactivate' | nc -U /tmp/leaderkey.sock"

    return """
      ;; Goku Configuration for Leader Key
      ;; Generated from Leader Key app configuration
      ;; https://github.com/yqrashawn/GokuRakuJoudo

      {
       :main [
         ;; ========== ACTIVATION ==========
         ;; Activate Leader Key with Cmd+K (app-specific mode)
         [:!Ck [[\"leader_mode\" 1] [:shell \"\(activateAppCmd)\"]]]
         
         ;; Activate Leader Key with Cmd+Shift+K (global mode)  
         [:!CSk [[\"leader_mode\" 1] [:shell \"\(activateGlobalCmd)\"]]]
         
         ;; ========== DEACTIVATION ==========
         ;; Deactivate with Escape (and pass escape through)
         [:escape [[:escape] [\"leader_mode\" 0] [:shell \"\(deactivateCmd)\"]] [\"leader_mode\" 1]]
         
         ;; Emergency deactivation with Cmd+Escape
         [:!Cescape [[\"leader_mode\" 0] [:shell \"\(deactivateCmd)\"]]]
         
         ;; ========== KEY FORWARDING ==========
         ;; Forward configured letter keys
      \(letterRules.isEmpty ? "   ;; No letter keys configured" : letterRules)
         
         ;; Forward configured number keys
      \(numberRules.isEmpty ? "   ;; No number keys configured" : numberRules)
         
         ;; Forward configured special keys
      \(specialKeyRules.isEmpty ? "   ;; No special keys configured" : specialKeyRules)
       ]
      }
      """
  }

  private static func collectKeysFromGroup(_ group: Group, into keys: inout Set<String>) {
    for item in group.actions {
      switch item {
      case .action(let action):
        if let key = action.key {
          keys.insert(key.lowercased())
        }
      case .group(let subgroup):
        if let key = subgroup.key {
          keys.insert(key.lowercased())
        }
        collectKeysFromGroup(subgroup, into: &keys)
      }
    }
  }
}
