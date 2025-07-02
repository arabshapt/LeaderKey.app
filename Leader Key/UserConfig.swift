import Cocoa
import Combine
import Defaults
import Foundation

let emptyRoot = Group(key: "🚫", label: "Config error", stickyMode: nil, actions: [])
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
        print("[UserConfig LOG] updateKey: Path \(path), newKey: '\(newKey)'")
        // To print the whole group, consider a more structured logging or a concise summary
        // print("[UserConfig LOG] updateKey: BEFORE currentlyEditingGroup: \(self.currentlyEditingGroup)")

        let updateLogic = {
            print("[UserConfig LOG] updateKey.updateLogic: Executing. Path \(path), newKey: '\(newKey)'")
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                let effectiveKey = newKey.isEmpty ? nil : newKey
                print("[UserConfig LOG] updateKey.closure: effectiveKey: '\(effectiveKey ?? "nil")' for path \(path)")
                
                switch item {
                case .action(var action):
                    let oldKey = action.key
                    print("[UserConfig LOG] updateKey.closure: ACTION at path \(path). Old key: '\(oldKey ?? "nil")'")
                    if oldKey != effectiveKey {
                        action.key = effectiveKey
                        item = .action(action)
                        print("[UserConfig LOG] updateKey.closure: Updated ACTION key at \(path) to '\(effectiveKey ?? "nil")'")
                    } else {
                        print("[UserConfig LOG] updateKey.closure: ACTION key at \(path) not changed (was '\(effectiveKey ?? "nil")')")
                    }
                case .group(var subGroup):
                    let oldKey = subGroup.key
                    print("[UserConfig LOG] updateKey.closure: GROUP at path \(path). Old key: '\(oldKey ?? "nil")'")
                    if oldKey != effectiveKey {
                        subGroup.key = effectiveKey
                        item = .group(subGroup)
                        print("[UserConfig LOG] updateKey.closure: Updated GROUP key at \(path) to '\(effectiveKey ?? "nil")'")
                    } else {
                        print("[UserConfig LOG] updateKey.closure: GROUP key at \(path) not changed (was '\(effectiveKey ?? "nil")')")
                    }
                @unknown default:
                   print("[UserConfig LOG] updateKey.closure: Unhandled case for path \(path)")
                }
            }
            self.currentlyEditingGroup = self.currentlyEditingGroup // Force SwiftUI update
            // print("[UserConfig LOG] updateKey.updateLogic: AFTER currentlyEditingGroup: \(self.currentlyEditingGroup)")
            print("[UserConfig LOG] updateKey.updateLogic: Finished for path \(path)")
        }

        if Thread.isMainThread {
            print("[UserConfig LOG] updateKey: Main thread. Executing directly for path \(path).")
            updateLogic()
        } else {
            print("[UserConfig LOG] updateKey: Background thread. Dispatching to main for path \(path).")
            DispatchQueue.main.async {
                print("[UserConfig LOG] updateKey: Dispatch main async block for path \(path).")
                updateLogic()
            }
        }
        print("[UserConfig LOG] updateKey: Finished method for path \(path)")
    }

    private func modifyItem(in group: inout Group, at path: [Int], update: (inout ActionOrGroup) -> Void) {
        let groupName = group.label ?? group.key ?? "RootG"
        print("[UserConfig LOG] modifyItem: Group '\(groupName)' (key: '\(group.key ?? "nil")'), path: \(path)")
        guard !path.isEmpty else {
            print("[UserConfig LOG] modifyItem: Path empty for group '\(groupName)'. Cannot modify.")
            return
        }

        var currentPath = path
        let index = currentPath.removeFirst()
        print("[UserConfig LOG] modifyItem: Group '\(groupName)', index \(index). Remaining path: \(currentPath)")

        guard index >= 0 && index < group.actions.count else {
            print("[UserConfig LOG] modifyItem: Index \(index) OOB (count \(group.actions.count)) for '\(groupName)', path \(path).")
            return
        }

        let itemKeyBefore = group.actions[index].item.key
        let itemTypeBefore = String(describing: group.actions[index].item.type)
        print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). BEFORE update. Key: '\(itemKeyBefore ?? "nil")', Type: \(itemTypeBefore)")

        if currentPath.isEmpty {
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Target reached. Applying update.")
            var itemToUpdate = group.actions[index]
            update(&itemToUpdate)
            group.actions[index] = itemToUpdate
            let itemKeyAfter = group.actions[index].item.key
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). AFTER update. New Key: '\(itemKeyAfter ?? "nil")'")
        } else {
            let currentItemType = String(describing: group.actions[index].item.type)
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Go deeper. Item type: \(currentItemType)")
            guard case .group(var subgroup) = group.actions[index] else {
                print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Error: Not a group (type \(currentItemType)) at path \(path).")
                return
            }
            let subGroupName = subgroup.label ?? subgroup.key ?? "SubG"
            let originalSubgroupKey = subgroup.key
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Recurse into '\(subGroupName)' (key '\(originalSubgroupKey ?? "nil")') with path \(currentPath).")
            modifyItem(in: &subgroup, at: currentPath, update: update)
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Recurse return from '\(subGroupName)' (orig key '\(originalSubgroupKey ?? "nil")').")
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Cont. New subkey: '\(subgroup.key ?? "nil")'. Updating parent.")
            group.actions[index] = .group(subgroup)
            print("[UserConfig LOG] modifyItem: Group '\(groupName)', Idx \(index). Parent updated with modified subgroup.")
        }
        print("[UserConfig LOG] modifyItem: Finished for group '\(groupName)', index \(index).")
    }
    
    // Remove the now unused finishEditingKey method if it exists
    // func finishEditingKey() { ... }
}

// MARK: - Action Type Update Logic (New Extension)
extension UserConfig {
    // Public method to update an action's type and reset its value
    func updateActionType(at path: [Int], newType: Type) {
        print("[UserConfig LOG] updateActionType: Path \(path), newType: \(newType)")
        // Ensure we're modifying the correct structure
        // print("[UserConfig LOG] updateActionType: BEFORE currentlyEditingGroup: \(self.currentlyEditingGroup)") 

        let updateLogic = { 
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                print("[UserConfig LOG] updateActionType.closure: Modifying item at path \(path)")
                guard case .action(var action) = item else {
                    print("[UserConfig LOG] updateActionType.closure: ERROR - Item at path \(path) is not an Action.")
                    return
                }
                
                if action.type != newType {
                    let oldType = action.type
                    let oldValue = action.value
                    action.type = newType
                    action.value = "" // Reset value when type changes
                    item = .action(action)
                    print("[UserConfig LOG] updateActionType.closure: Updated ACTION at \(path). Type: \(oldType) -> \(newType). Value: '\(oldValue)' -> ''")
                } else {
                    print("[UserConfig LOG] updateActionType.closure: ACTION at \(path) already has type \(newType). No change.")
                }
            }
            self.currentlyEditingGroup = self.currentlyEditingGroup // Force SwiftUI update if needed
            print("[UserConfig LOG] updateActionType: Finished update logic for path \(path).")
        }

        // Ensure execution on the main thread
        if Thread.isMainThread {
            updateLogic()
        } else {
            DispatchQueue.main.async {
                updateLogic()
            }
        }
        print("[UserConfig LOG] updateActionType: Finished method for path \(path).")
    }
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
  case toggleStickyMode
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
  var stickyMode: Bool?

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
  var stickyMode: Bool?
  var actions: [ActionOrGroup]

  var displayName: String {
    guard let labelValue = label else { return "Group" }
    if labelValue.isEmpty { return "Group" }
    return labelValue
  }

  static func == (lhs: Group, rhs: Group) -> Bool {
    return lhs.key == rhs.key && lhs.type == rhs.type && lhs.label == rhs.label
      && lhs.iconPath == rhs.iconPath && lhs.stickyMode == rhs.stickyMode && lhs.actions == rhs.actions
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
    case key, type, value, actions, label, iconPath, activates, stickyMode
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let key = try container.decode(String?.self, forKey: .key)
    let type = try container.decode(Type.self, forKey: .type)
    let label = try container.decodeIfPresent(String.self, forKey: .label)
    let iconPath = try container.decodeIfPresent(String.self, forKey: .iconPath)
    let activates = try container.decodeIfPresent(Bool.self, forKey: .activates)
    let stickyMode = try container.decodeIfPresent(Bool.self, forKey: .stickyMode)

    switch type {
    case .group:
      let actions = try container.decode([ActionOrGroup].self, forKey: .actions)
      self = .group(Group(key: key, label: label, iconPath: iconPath, stickyMode: stickyMode, actions: actions))
    default:
      let value = try container.decode(String.self, forKey: .value)
      self = .action(Action(key: key, type: type, label: label, value: value, iconPath: iconPath, activates: activates, stickyMode: stickyMode))
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
      try container.encodeIfPresent(action.stickyMode, forKey: .stickyMode)
    case .group(let group):
      try container.encode(group.key, forKey: .key)
      try container.encode(Type.group, forKey: .type)
      try container.encode(group.actions, forKey: .actions)
      if group.label != nil && !group.label!.isEmpty {
        try container.encodeIfPresent(group.label, forKey: .label)
      }
      try container.encodeIfPresent(group.iconPath, forKey: .iconPath)
      try container.encodeIfPresent(group.stickyMode, forKey: .stickyMode)
    }
  }
}
