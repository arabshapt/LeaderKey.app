import Cocoa
import Combine
import Defaults
import Foundation

let emptyRoot = Group(key: "🚫", label: "Config error", actions: [])
let globalDefaultDisplayName = "Global Default"
let defaultAppConfigDisplayName = "Default App Config"

class UserConfig: ObservableObject {
  // Root for the default config (config.json)
  @Published var root = emptyRoot
  // Root for the config currently being edited in Settings
  @Published var currentlyEditingGroup = emptyRoot
  @Published var validationErrors: [ValidationError] = [] // Errors specific to the default config
  @Published var discoveredConfigFiles: [String: String] = [:] // Display Name -> File Path
  @Published var selectedConfigKeyForEditing: String = globalDefaultDisplayName // Initialize with the new default key

  let fileName = "config.json"
  let appConfigPrefix = "app."
  let defaultAppConfigFileName = "app.default.json" // Added default app config filename
  var appConfigs: [String: Group?] = [:] // Cache for app-specific configs
  let alertHandler: AlertHandler
  let fileManager: FileManager
  var suppressValidationAlerts = false // Internal flag

  init(
    alertHandler: AlertHandler = DefaultAlertHandler(),
    fileManager: FileManager = .default
  ) {
    self.alertHandler = alertHandler
    self.fileManager = fileManager
  }

  // MARK: - Public Interface

  func ensureAndLoad() {
    self.ensureValidConfigDirectory()
    self.discoverConfigFiles() // Discover before ensuring/loading
    self.ensureConfigFileExists() // Ensures default config.json exists
    self.loadConfig() // Loads the default config into 'root'
    // Initially, load the default config for editing
    if let defaultPath = discoveredConfigFiles[globalDefaultDisplayName] {
        currentlyEditingGroup = self.decodeConfig(from: defaultPath, suppressAlerts: false, isDefaultConfig: true) ?? emptyRoot
        selectedConfigKeyForEditing = globalDefaultDisplayName
        // Set initial validation errors based on default config
        validationErrors = ConfigValidator.validate(group: root)
    } else {
        // If default doesn't exist somehow, ensure editor has empty root
        currentlyEditingGroup = emptyRoot
        selectedConfigKeyForEditing = globalDefaultDisplayName
    }
  }

  func reloadConfig() {
    Events.send(.willReload)
    
    // Clear caches and reset state
    appConfigs = [:] // Clear app-specific cache
    
    // Re-discover available config files
    self.discoverConfigFiles()
    
    // First reload default config with caution
    self.loadConfig(suppressAlerts: true) // Reload default config into 'root'
    
    // Then safely reload the currently selected config for editing 
    // Using a dispatch async to separate the state updates
    DispatchQueue.main.async {
      // Check if current selection is still valid
      if self.discoveredConfigFiles[self.selectedConfigKeyForEditing] != nil {
        self.loadConfigForEditing(key: self.selectedConfigKeyForEditing)
      } else {
        // If current selection is no longer valid, fallback to default
        self.loadConfigForEditing(key: globalDefaultDisplayName)
      }
      
      // Notify that reload is complete
      Events.send(.didReload)
    }
  }

  // Placeholder for methods moved to extensions
}

// MARK: - Key Update Logic (Add this new extension)
extension UserConfig {
    // Public method to initiate key update
    func updateKey(at path: [Int], newKey: String) {
        print("[UserConfig] Attempting to update key at path \(path) to '\(newKey)'")
        // Ensure update happens on main thread as it modifies @Published property
        DispatchQueue.main.async {
            // Modify the currentlyEditingGroup directly
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                 let effectiveKey = newKey.isEmpty ? nil : newKey // Handle empty string case
                 
                 switch item {
                 case .action(var action): // Use var to make action mutable locally
                     if action.key != effectiveKey { // Only update if changed
                         action.key = effectiveKey
                         item = .action(action) // IMPORTANT: Assign the modified action back to the inout item
                         print("[UserConfig updateKey Closure] Updated ACTION key at path \(path) to '\(effectiveKey ?? "nil")'")
                     }
                 case .group(var subGroup): // Use var to make subGroup mutable locally
                     if subGroup.key != effectiveKey { // Only update if changed
                         subGroup.key = effectiveKey
                         item = .group(subGroup) // IMPORTANT: Assign the modified group back to the inout item
                         print("[UserConfig updateKey Closure] Updated GROUP key at path \(path) to '\(effectiveKey ?? "nil")'")
                     }
                 @unknown default:
                    print("[UserConfig updateKey Closure] Warning: Unhandled ActionOrGroup case.")
                 }
             }
             // Since we modified the published property directly, SwiftUI's observation
             // mechanism should pick up the change. No need to reassign the whole group.
             // self.currentlyEditingGroup = groupToModify // REMOVED THIS LINE

             // Optional: Explicitly notify observers if direct modification doesn't trigger update (unlikely but possible)
             // self.objectWillChange.send()
             
             // print("[UserConfig] Updated key. Current editing group state: \(self.currentlyEditingGroup)") // Optional verbose logging
             // Optionally trigger validation or other side effects here
             // self.triggerValidationForEditingConfig() // Example
        }
    }

    // Recursive helper function to find and modify an item at a given path
    private func modifyItem(in group: inout Group, at path: [Int], update: (inout ActionOrGroup) -> Void) {
        guard !path.isEmpty else {
            // This case should ideally not be reached if called from updateKey which checks path
            print("[UserConfig modifyItem] Error: Path is empty, cannot modify item.")
            return
        }

        var currentPath = path
        let index = currentPath.removeFirst() // Get the index for the current level

        guard index >= 0 && index < group.actions.count else {
            print("[UserConfig modifyItem] Error: Index \(index) out of bounds for group actions (count: \(group.actions.count)) at path \(path).")
            return
        }

        if currentPath.isEmpty {
            // We've reached the target item at 'index', apply the update closure
            print("[UserConfig modifyItem] Reached target item at index \(index). Applying update.")
            
            // --- Apply Update Directly to Nested Value --- START ---
            // Get a mutable reference to the item
            var itemToUpdate = group.actions[index]
            // Pass the mutable reference to the update closure
            update(&itemToUpdate) 
            // Assign the potentially modified item back to the array
            group.actions[index] = itemToUpdate 
            // --- Apply Update Directly to Nested Value --- END ---
            
        } else {
            // Need to go deeper into a subgroup
            guard case .group(var subgroup) = group.actions[index] else {
                print("[UserConfig modifyItem] Error: Path \(path) attempts to traverse through a non-group item at index \(index).")
                return
            }
            // Recursively call modifyItem on the subgroup with the remaining path
            modifyItem(in: &subgroup, at: currentPath, update: update)
            // After the recursive call returns, update the original group's actions array
            // with the potentially modified subgroup
            group.actions[index] = .group(subgroup)
        }
    }
    
    // Remove the now unused finishEditingKey method if it exists
    // func finishEditingKey() { ... }
}

// MARK: - Config Data Structures (Keep in main file)

let defaultConfig = """
  {
      "type": "group",
      "actions": [
          { "key": "t", "type": "application", "value": "/System/Applications/Utilities/Terminal.app" },
          {
              "key": "o",
              "type": "group",
              "actions": [
                  { "key": "s", "type": "application", "value": "/Applications/Safari.app" },
                  { "key": "e", "type": "application", "value": "/Applications/Mail.app" },
                  { "key": "i", "type": "application", "value": "/System/Applications/Music.app" },
                  { "key": "m", "type": "application", "value": "/Applications/Messages.app" }
              ]
          },
          {
              "key": "r",
              "type": "group",
              "actions": [
                  { "key": "e", "type": "url", "value": "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols" },
                  { "key": "p", "type": "url", "value": "raycast://confetti" },
                  { "key": "c", "type": "url", "value": "raycast://extensions/raycast/system/open-camera" }
              ]
          }
      ]
  }
  """

enum Type: String, Codable {
  case group
  case application
  case url
  case command
  case folder
  case shortcut
  case text
}

protocol Item {
  var key: String? { get }
  var type: Type { get }
  var label: String? { get }
  var displayName: String { get }
  var iconPath: String? { get set }
}

struct Action: Item, Codable, Equatable, Identifiable {
  let id = UUID()
  var key: String?
  var type: Type
  var label: String?
  var value: String
  var iconPath: String?
  var activates: Bool?

  var displayName: String {
    guard let labelValue = label else { return bestGuessDisplayName }
    guard !labelValue.isEmpty else { return bestGuessDisplayName }
    return labelValue
  }

  var bestGuessDisplayName: String {
    switch type {
    case .application:
      return (value as NSString).lastPathComponent.replacingOccurrences(
        of: ".app", with: "")
    case .command:
      return value.components(separatedBy: " ").first ?? value
    case .folder:
      return (value as NSString).lastPathComponent
    case .url:
      return "URL"
    case .shortcut:
      return "Shortcut: \(value)"
    case .text:
      let snippet = value.prefix(20)
      let suffix = value.count > 20 ? "..." : ""
      return "Type: '\(snippet)\(suffix)'"
    default:
      return value
    }
  }
}

struct Group: Item, Codable, Equatable, Identifiable {
  let id = UUID()
  var key: String?
  var type: Type = .group
  var label: String?
  var iconPath: String?
  var actions: [ActionOrGroup]

  var displayName: String {
    guard let labelValue = label else { return "Group" }
    if labelValue.isEmpty { return "Group" }
    return labelValue
  }

  static func == (lhs: Group, rhs: Group) -> Bool {
    return lhs.key == rhs.key && lhs.type == rhs.type && lhs.label == rhs.label
      && lhs.actions == rhs.actions
  }
}

enum ActionOrGroup: Codable, Equatable, Identifiable {
  var id: UUID {
    switch self {
      case .action(let action): return action.id
      case .group(let group): return group.id
    }
  }

  case action(Action)
  case group(Group)

  var item: Item {
    switch self {
    case .group(let group): return group
    case .action(let action): return action
    }
  }

  private enum CodingKeys: String, CodingKey {
    case key, type, value, actions, label, iconPath, activates
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let key = try container.decode(String?.self, forKey: .key)
    let type = try container.decode(Type.self, forKey: .type)
    let label = try container.decodeIfPresent(String.self, forKey: .label)
    let iconPath = try container.decodeIfPresent(String.self, forKey: .iconPath)
    let activates = try container.decodeIfPresent(Bool.self, forKey: .activates)

    switch type {
    case .group:
      let actions = try container.decode([ActionOrGroup].self, forKey: .actions)
      self = .group(Group(key: key, label: label, iconPath: iconPath, actions: actions))
    default:
      let value = try container.decode(String.self, forKey: .value)
      self = .action(Action(key: key, type: type, label: label, value: value, iconPath: iconPath, activates: activates))
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .action(let action):
      try container.encode(action.key, forKey: .key)
      try container.encode(action.type, forKey: .type)
      try container.encode(action.value, forKey: .value)
      if action.label != nil && !action.label!.isEmpty {
        try container.encodeIfPresent(action.label, forKey: .label)
      }
      try container.encodeIfPresent(action.iconPath, forKey: .iconPath)
      try container.encodeIfPresent(action.activates, forKey: .activates)
    case .group(let group):
      try container.encode(group.key, forKey: .key)
      try container.encode(Type.group, forKey: .type)
      try container.encode(group.actions, forKey: .actions)
      if group.label != nil && !group.label!.isEmpty {
        try container.encodeIfPresent(group.label, forKey: .label)
      }
      try container.encodeIfPresent(group.iconPath, forKey: .iconPath)
    }
  }
}
