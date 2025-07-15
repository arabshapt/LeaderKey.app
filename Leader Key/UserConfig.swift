import Cocoa
import Combine
import Defaults
import Foundation

let emptyRoot = Group(key: "🚫", label: "Config error", stickyMode: nil, actions: [])
let globalDefaultDisplayName = "Global"
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
    self.ensureConfigFileExists() // Ensures default config.json exists
    self.ensureDefaultAppConfigExists() // Ensures default app.default.json exists
    self.discoverConfigFiles() // Discover after ensuring both files exist
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

// MARK: - Search Data Structures
enum SearchMatchType: String, Hashable, CaseIterable {
    case all = "All"
    case key = "Key"
    case label = "Label"
    case value = "Value"
    case appName = "App Name"
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let keySequence: String  // e.g., "o → s" or "r → w → f"
    let item: ActionOrGroup
    let path: [Int]
    let configName: String
    let matchType: SearchMatchType
    let matchReason: String
    
    var displayName: String {
        return item.item.displayName
    }
    
    var typeDescription: String {
        switch item {
        case .action(let action):
            return action.type.rawValue.capitalized
        case .group:
            return "Group"
        }
    }
    
    var valueDescription: String {
        switch item {
        case .action(let action):
            switch action.type {
            case .application:
                return (action.value as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")
            case .url:
                return action.value
            case .command:
                return action.value
            case .folder:
                return (action.value as NSString).lastPathComponent
            case .text:
                let snippet = action.value.prefix(30)
                return snippet.count < action.value.count ? "\(snippet)..." : String(snippet)
            default:
                return action.value
            }
        case .group(let group):
            return "Contains \(group.actions.count) items"
        }
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension UserConfig {
    // Public method to initiate a search across all configurations
    func searchSequences(query: String, matchType: SearchMatchType, includeGroups: Bool) -> [SearchResult] {
        let lowercasedQuery = query.lowercased()
        var results: [SearchResult] = []

        // Search in the default config (config.json)
        let defaultResults = search(in: root, query: lowercasedQuery, configName: globalDefaultDisplayName, matchType: matchType, includeGroups: includeGroups)
        results.append(contentsOf: defaultResults)

        // Search in all discovered app-specific configs
        for (configName, configPath) in discoveredConfigFiles where configName != globalDefaultDisplayName {
            if let configGroup = decodeConfig(from: configPath, suppressAlerts: true, isDefaultConfig: false) {
                let appResults = search(in: configGroup, query: lowercasedQuery, configName: configName, matchType: matchType, includeGroups: includeGroups)
                results.append(contentsOf: appResults)
            }
        }
        
        return results.sorted { $0.keySequence < $1.keySequence } // Sort alphabetically by key sequence
    }

    // Recursive helper function to search within a specific group
    private func search(
        in group: Group,
        query: String,
        configName: String,
        matchType: SearchMatchType,
        includeGroups: Bool,
        currentPath: [Int] = [],
        keySequence: [String] = []
    ) -> [SearchResult] {
        var findings: [SearchResult] = []

        for (index, actionOrGroup) in group.actions.enumerated() {
            let newPath = currentPath + [index]
            let newKeySequence = keySequence + [actionOrGroup.item.key ?? ""]
            let keySequenceString = newKeySequence.filter { !$0.isEmpty }.joined(separator: " → ")

            var matchReason: String?
            let item = actionOrGroup.item

            // Determine if the item matches the query
            if matchType == .all || matchType == .key {
                if let key = item.key, key.lowercased().contains(query) {
                    matchReason = "Matched key: '\(key)'"
                }
            }
            if matchReason == nil && (matchType == .all || matchType == .label) {
                if let label = item.label, label.lowercased().contains(query) {
                    matchReason = "Matched label: '\(label)'"
                }
            }
            if matchReason == nil && (matchType == .all || matchType == .value) {
                if case .action(let action) = actionOrGroup, action.value.lowercased().contains(query) {
                    matchReason = "Matched value: '\(action.value)'"
                }
            }
            if matchReason == nil && (matchType == .all || matchType == .appName) {
                 if case .action(let action) = actionOrGroup, action.type == .application {
                    let appName = (action.value as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "").lowercased()
                    if appName.contains(query) {
                        matchReason = "Matched app name: '\(appName.capitalized)'"
                    }
                }
            }

            // If a match is found, create a SearchResult
            if let reason = matchReason {
                let result = SearchResult(
                    keySequence: keySequenceString,
                    item: actionOrGroup,
                    path: newPath,
                    configName: configName,
                    matchType: .key, // This should be more specific based on what matched
                    matchReason: reason
                )
                findings.append(result)
            }

            // Recurse into subgroups if necessary
            if case .group(let subGroup) = actionOrGroup {
                if includeGroups || matchReason == nil { // Also search inside if the group itself didn't match
                    let subGroupFindings = search(
                        in: subGroup,
                        query: query,
                        configName: configName,
                        matchType: matchType,
                        includeGroups: includeGroups,
                        currentPath: newPath,
                        keySequence: newKeySequence
                    )
                    findings.append(contentsOf: subGroupFindings)
                }
            }
        }

        return findings
    }
}

    

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
  case macro
}

struct MacroStep: Codable, Equatable, Identifiable {
  let id = UUID()
  var action: Action
  var delay: Double // Delay in seconds before executing this step
  var enabled: Bool = true
  
  private enum CodingKeys: String, CodingKey {
    case action, delay, enabled
  }
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
  var macroSteps: [MacroStep]?

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
    case .macro:
      let stepCount = macroSteps?.count ?? 0
      return "Macro: \(stepCount) steps"
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
    case key, type, value, actions, label, iconPath, activates, stickyMode, macroSteps
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
      let macroSteps = try container.decodeIfPresent([MacroStep].self, forKey: .macroSteps)
      self = .action(Action(key: key, type: type, label: label, value: value, iconPath: iconPath, activates: activates, stickyMode: stickyMode, macroSteps: macroSteps))
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
      try container.encodeIfPresent(action.macroSteps, forKey: .macroSteps)
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
