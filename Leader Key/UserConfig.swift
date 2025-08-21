import Cocoa
import Combine
import Defaults
import Foundation
import AppKit

// MARK: - ClipboardManager
class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()

    @Published var copiedItem: ActionOrGroup?
    @Published var clipboardType: ClipboardType = .none
    @Published var sourceConfig: String? // Track which config the item was copied from

    enum ClipboardType {
        case none
        case action
        case group
    }

    private init() {}

    func copyItem(_ item: ActionOrGroup, fromConfig: String? = nil) {
        let duplicatedItem = item.makeTrueDuplicate()

        do {
            let jsonData = try JSONEncoder().encode(duplicatedItem)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setData(jsonData, forType: .string)

            copiedItem = duplicatedItem
            clipboardType = getCopyType(for: duplicatedItem)
            sourceConfig = fromConfig
        } catch {
            print("Failed to copy item to clipboard: \(error)")
        }
    }

    func pasteItem() -> ActionOrGroup? {
        guard let copiedItem = copiedItem else { return nil }
        return copiedItem.makeTrueDuplicate()
    }

    func canPaste() -> Bool {
        return copiedItem != nil
    }

    func clear() {
        copiedItem = nil
        clipboardType = .none
        sourceConfig = nil
    }

    private func getCopyType(for item: ActionOrGroup) -> ClipboardType {
        switch item {
        case .action:
            return .action
        case .group:
            return .group
        }
    }
}

let emptyRoot = Group(key: "🚫", label: "Config error", stickyMode: nil, actions: [])
let globalDefaultDisplayName = "Global"
let defaultAppConfigDisplayName = "Fallback App Config"

class UserConfig: ObservableObject {
  // Root for the default config (global-config.json)
  @Published var root = emptyRoot
  // Root for the config currently being edited in Settings
  @Published var currentlyEditingGroup = emptyRoot
  @Published var validationErrors: [ValidationError] = [] // Errors specific to the default config
  @Published var discoveredConfigFiles: [String: String] = [:] // Display Name -> File Path
  @Published var selectedConfigKeyForEditing: String = globalDefaultDisplayName // Initialize with the new default key
  @Published var isActivelyEditing: Bool = false // Track if user is actively editing vs ready to finalize

  let fileName = "global-config.json"
  let appConfigPrefix = "app."
  let defaultAppConfigFileName = "app-fallback-config.json" // Added default app config filename
  var appConfigs: [String: Group?] = [:] // Cache for app-specific configs
  let alertHandler: AlertHandler
  let fileManager: FileManager
  var suppressValidationAlerts = false // Internal flag
  // Cache app icons by bundle identifier to avoid repeated disk lookups & large NSImage payloads
  private let appBundleIconCache: NSCache<NSString, NSImage> = {
    let c = NSCache<NSString, NSImage>()
    c.countLimit = 256
    return c
  }()
  
  // Cache parsed configurations to avoid repeated JSON parsing
  internal let configCache = ConfigCache()

  init(
    alertHandler: AlertHandler = DefaultAlertHandler(),
    fileManager: FileManager = .default
  ) {
    self.alertHandler = alertHandler
    self.fileManager = fileManager
  }

  // MARK: - Public Interface
  
  // Helper function to extract bundle ID from config filename or display name
  func extractBundleId(from displayName: String) -> String? {
    // Check if this is an app-specific config
    guard displayName != globalDefaultDisplayName && displayName != defaultAppConfigDisplayName else {
      return nil
    }
    
    // First check if we have the file path for this display name
    if let filePath = discoveredConfigFiles[displayName] {
      let url = URL(fileURLWithPath: filePath)
      let filename = url.lastPathComponent
      
      // Extract bundle ID from filename (app.bundleId.json or app.bundleId.overlay.json)
      if filename.hasPrefix(appConfigPrefix) && filename.hasSuffix(".json") {
        var bundleId = String(filename.dropFirst(appConfigPrefix.count))
        
        // Handle overlay configs
        if bundleId.hasSuffix(".overlay.json") {
          bundleId = String(bundleId.dropLast(".overlay.json".count))
        } else {
          bundleId = String(bundleId.dropLast(".json".count))
        }
        
        return bundleId.isEmpty ? nil : bundleId
      }
    }
    
    // Fallback: try to extract from display name if it starts with "App: "
    if displayName.hasPrefix("App: ") {
      return String(displayName.dropFirst("App: ".count))
    }
    
    return nil
  }
  
  // Helper function to get app icon from bundle ID
  func getAppIcon(for bundleId: String) -> NSImage? {
    let cacheKey = bundleId as NSString
    if let cached = appBundleIconCache.object(forKey: cacheKey) {
      return cached
    }

    // Prefer running app icon if available
    var baseIcon: NSImage?
    if let runningApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleId }) {
      baseIcon = runningApp.icon
    } else if let appPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path {
      baseIcon = NSWorkspace.shared.icon(forFile: appPath)
    }

    guard let icon = baseIcon else { return nil }

    // Create a small resized representation (16x16) that matches sidebar usage
    let targetSize = NSSize(width: 16, height: 16)
    let resized = NSImage(size: targetSize, flipped: false) { rect in
      let iconRect = NSRect(origin: .zero, size: icon.size)
      icon.draw(in: rect, from: iconRect, operation: .sourceOver, fraction: 1)
      return true
    }
    appBundleIconCache.setObject(resized, forKey: cacheKey)
    return resized
  }

  func ensureAndLoad() {
    self.ensureValidConfigDirectory()
    self.ensureConfigFileExists() // Ensures default global-config.json exists
    self.ensureDefaultAppConfigExists() // Ensures default app-fallback-config.json exists
    self.discoverConfigFiles() // Discover after ensuring both files exist
    self.loadConfig() // Loads the default config into 'root'
    // Initially, load the default config for editing
    if let defaultPath = discoveredConfigFiles[globalDefaultDisplayName] {
        currentlyEditingGroup = self.decodeConfig(from: defaultPath, suppressAlerts: false, isDefaultConfig: true) ?? emptyRoot
        selectedConfigKeyForEditing = globalDefaultDisplayName
        // Set initial validation errors based on default config
        validationErrors = ConfigValidator.validate(group: root)
        // Start with sorted view when loading configs
        isActivelyEditing = false
    } else {
        // If default doesn't exist somehow, ensure editor has empty root
        currentlyEditingGroup = emptyRoot
        selectedConfigKeyForEditing = globalDefaultDisplayName
        isActivelyEditing = false
    }
  }

  func reloadConfig() {
    Events.send(.willReload)

    // Clear caches and reset state
    appConfigs = [:] // Clear app-specific cache
    configCache.clearCache() // Clear parsed config cache
    ConfigPreprocessor.shared.invalidateAll() // Clear preprocessed key lookup caches

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
        // Mark as actively editing when user makes changes
        isActivelyEditing = true
        
        let updateLogic = {
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                let effectiveKey = newKey.isEmpty ? nil : newKey

                switch item {
                case .action(var action):
                    let oldKey = action.key
                    if oldKey != effectiveKey {
                        action.key = effectiveKey
                        item = .action(action)
                    }
                case .group(var subGroup):
                    let oldKey = subGroup.key
                    if oldKey != effectiveKey {
                        subGroup.key = effectiveKey
                        item = .group(subGroup)
                    }
                @unknown default:
                   break
                }
            }
            self.currentlyEditingGroup = self.currentlyEditingGroup // Force SwiftUI update
        }

        updateLogic()
        
        // Trigger real-time validation after key update
        validateWithoutAlerts()
    }

    private func modifyItem(in group: inout Group, at path: [Int], update: (inout ActionOrGroup) -> Void) {
        guard !path.isEmpty else {
            return
        }

        var currentPath = path
        let index = currentPath.removeFirst()

        guard index >= 0 && index < group.actions.count else {
            return
        }

        if currentPath.isEmpty {
            var itemToUpdate = group.actions[index]
            update(&itemToUpdate)
            group.actions[index] = itemToUpdate
        } else {
            guard case .group(var subgroup) = group.actions[index] else {
                return
            }
            modifyItem(in: &subgroup, at: currentPath, update: update)
            group.actions[index] = .group(subgroup)
        }
    }

    // Remove the now unused finishEditingKey method if it exists
    // func finishEditingKey() { ... }
}

// MARK: - Action Type Update Logic (New Extension)
extension UserConfig {
    // Public method to update an entire action
    func updateAction(at path: [Int], newAction: Action) {
        // Mark as actively editing when user makes changes
        isActivelyEditing = true
        
        let updateLogic = {
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                guard case .action = item else {
                    return
                }
                item = .action(newAction)
            }
        }

        if Thread.isMainThread {
            updateLogic()
            // Trigger real-time validation after action update
            validateWithoutAlerts()
            saveCurrentlyEditingConfig()
        } else {
            DispatchQueue.main.async {
                updateLogic()
                // Trigger real-time validation after action update
                self.validateWithoutAlerts()
                self.saveCurrentlyEditingConfig()
            }
        }
    }

    // Public method to update an entire group
    func updateGroup(at path: [Int], newGroup: Group) {
        // Mark as actively editing when user makes changes
        isActivelyEditing = true
        
        let updateLogic = {
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                guard case .group = item else {
                    return
                }
                item = .group(newGroup)
            }
        }

        if Thread.isMainThread {
            updateLogic()
            // Trigger real-time validation after group update
            validateWithoutAlerts()
            saveCurrentlyEditingConfig()
        } else {
            DispatchQueue.main.async {
                updateLogic()
                // Trigger real-time validation after group update
                self.validateWithoutAlerts()
                self.saveCurrentlyEditingConfig()
            }
        }
    }

    // Public method to update an action's type and reset its value
    func updateActionType(at path: [Int], newType: Type) {
        // Mark as actively editing when user makes changes
        isActivelyEditing = true
        
        let updateLogic = {
            self.modifyItem(in: &self.currentlyEditingGroup, at: path) { item in
                guard case .action(var action) = item else {
                    return
                }

                if action.type != newType {
                    action.type = newType
                    action.value = "" // Reset value when type changes
                    item = .action(action)
                }
            }
            self.currentlyEditingGroup = self.currentlyEditingGroup // Force SwiftUI update if needed
        }

        updateLogic()
        
        // Trigger real-time validation after action type update
        validateWithoutAlerts()
    }
}

// MARK: - Copy/Paste Logic (New Extension)
extension UserConfig {
    func pasteItem(at path: [Int]) {
        guard let pastedItem = ClipboardManager.shared.pasteItem() else { return }

        let validatedItem = validateAndCleanItem(pastedItem, at: path)
        insertItem(validatedItem, at: path)
    }

    func insertItem(_ item: ActionOrGroup, at path: [Int]) {
        let insertLogic = {
            self.insertItemInGroup(item, in: &self.currentlyEditingGroup, at: path)
            self.currentlyEditingGroup = self.currentlyEditingGroup // Force SwiftUI update
        }

        insertLogic()
    }

    private func validateAndCleanItem(_ item: ActionOrGroup, at path: [Int]) -> ActionOrGroup {
        var cleanedItem = item

        // Check for duplicate keys at the same level
        let parentGroup = getParentGroup(at: path)
        let existingKeys = parentGroup.actions.compactMap { $0.item.key }

        switch cleanedItem {
        case .action(var action):
            if let key = action.key, existingKeys.contains(key) {
                action.key = generateUniqueKey(base: key, existingKeys: existingKeys)
            }
            cleanedItem = .action(action)
        case .group(var group):
            if let key = group.key, existingKeys.contains(key) {
                group.key = generateUniqueKey(base: key, existingKeys: existingKeys)
            }
            cleanedItem = .group(group)
        }

        return cleanedItem
    }

    private func getParentGroup(at path: [Int]) -> Group {
        var currentGroup = currentlyEditingGroup
        var pathCopy = path

        // Navigate to parent group
        if !pathCopy.isEmpty {
            pathCopy.removeLast() // Remove the insertion index

            for index in pathCopy {
                guard index >= 0 && index < currentGroup.actions.count,
                      case .group(let subgroup) = currentGroup.actions[index] else {
                    break
                }
                currentGroup = subgroup
            }
        }

        return currentGroup
    }

    private func generateUniqueKey(base: String, existingKeys: [String]) -> String {
        let baseKey = base.isEmpty ? "key" : base
        var counter = 1
        var newKey = baseKey

        while existingKeys.contains(newKey) {
            newKey = "\(baseKey)_\(counter)"
            counter += 1
        }

        return newKey
    }

    private func insertItemInGroup(_ item: ActionOrGroup, in group: inout Group, at path: [Int]) {
        guard !path.isEmpty else {
            group.actions.append(item)
            return
        }

        var currentPath = path
        let index = currentPath.removeFirst()

        guard index >= 0 && index <= group.actions.count else {
            return
        }

        if currentPath.isEmpty {
            group.actions.insert(item, at: index)
        } else {
            guard index < group.actions.count,
                  case .group(var subgroup) = group.actions[index] else {
                return
            }
            insertItemInGroup(item, in: &subgroup, at: currentPath)
            group.actions[index] = .group(subgroup)
        }
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

        // Search in all discovered configs
        for (configName, configPath) in discoveredConfigFiles {
            let groupToSearch: Group
            
            // If this is the currently loaded config, search in the merged version that's being edited
            if configName == selectedConfigKeyForEditing {
                groupToSearch = currentlyEditingGroup
            } else if configName == globalDefaultDisplayName {
                // For the default config, use root
                groupToSearch = root
            } else {
                // For other configs, load and merge them the same way loadConfigForEditing does
                guard let loadedGroup = decodeConfig(from: configPath, suppressAlerts: true, isDefaultConfig: false) else {
                    continue
                }
                
                // Apply the same merging logic as loadConfigForEditing
                if configPath.contains(appConfigPrefix) && !configPath.contains(defaultAppConfigFileName) {
                    // This is an app-specific config, merge with fallback
                    let bundleId = extractBundleIdFromSearchKey(key: configName)
                    let rawMergedGroup = mergeConfigWithFallback(appSpecificConfig: loadedGroup, bundleId: bundleId)
                    groupToSearch = sortGroupRecursively(group: rawMergedGroup)
                } else {
                    // This is the fallback app config or other config, use as-is
                    groupToSearch = loadedGroup
                }
            }
            
            let configResults = search(in: groupToSearch, query: lowercasedQuery, configName: configName, matchType: matchType, includeGroups: includeGroups)
            results.append(contentsOf: configResults)
        }

        return results.sorted { $0.keySequence < $1.keySequence } // Sort alphabetically by key sequence
    }
    
    // Helper to extract bundle ID from a display key (copied from extension for search use)
    private func extractBundleIdFromSearchKey(key: String) -> String {
        // If the key matches discovered config patterns, extract bundle ID from the file path
        if let filePath = discoveredConfigFiles[key] {
            let fileName = (filePath as NSString).lastPathComponent
            if fileName.hasPrefix(appConfigPrefix) && fileName.hasSuffix(".json") {
                let withoutPrefix = String(fileName.dropFirst(appConfigPrefix.count))
                let withoutSuffix = String(withoutPrefix.dropLast(".json".count))
                return withoutSuffix
            }
        }
        // Fallback: assume the key is the bundle ID if it contains dots
        if key.contains(".") {
            return key
        }
        // Last resort: return key as-is
        return key
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

  // Metadata for fallback system (not persisted to JSON)
  var isFromFallback: Bool = false
  var fallbackSource: String?

  enum CodingKeys: String, CodingKey {
    case key, type, label, value, iconPath, activates, stickyMode, macroSteps
    // Exclude isFromFallback and fallbackSource from JSON persistence
  }

  var displayName: String {
    guard let labelValue = label else { return bestGuessDisplayName }
    guard !labelValue.isEmpty else { return bestGuessDisplayName }
    return labelValue
  }

  static func == (lhs: Action, rhs: Action) -> Bool {
    return lhs.key == rhs.key && lhs.type == rhs.type && lhs.label == rhs.label
      && lhs.value == rhs.value && lhs.iconPath == rhs.iconPath && lhs.activates == rhs.activates
      && lhs.stickyMode == rhs.stickyMode && lhs.macroSteps == rhs.macroSteps
    // Intentionally exclude isFromFallback and fallbackSource from equality comparison
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

  // Metadata for fallback system (not persisted to JSON)
  var isFromFallback: Bool = false
  var fallbackSource: String?

  enum CodingKeys: String, CodingKey {
    case key, type, label, iconPath, stickyMode, actions
    // Exclude isFromFallback and fallbackSource from JSON persistence
  }

  var displayName: String {
    guard let labelValue = label else { return "Group" }
    if labelValue.isEmpty { return "Group" }
    return labelValue
  }

  static func == (lhs: Group, rhs: Group) -> Bool {
    return lhs.key == rhs.key && lhs.type == rhs.type && lhs.label == rhs.label
      && lhs.iconPath == rhs.iconPath && lhs.stickyMode == rhs.stickyMode && lhs.actions == rhs.actions
    // Intentionally exclude isFromFallback and fallbackSource from equality comparison
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

// MARK: - ActionOrGroup Extensions
extension ActionOrGroup {
    func makeTrueDuplicate() -> ActionOrGroup {
        switch self {
        case .action(let action):
            return .action(Action(
                key: action.key,
                type: action.type,
                label: action.label,
                value: action.value,
                iconPath: action.iconPath,
                activates: action.activates,
                stickyMode: action.stickyMode,
                macroSteps: action.macroSteps?.map { step in
                    MacroStep(
                        action: step.action,
                        delay: step.delay,
                        enabled: step.enabled
                    )
                }
            ))
        case .group(let group):
            return .group(Group(
                key: group.key,
                label: group.label,
                iconPath: group.iconPath,
                stickyMode: group.stickyMode,
                actions: group.actions.map { $0.makeTrueDuplicate() }
            ))
        }
    }
}
