import Cocoa
import Combine
import Defaults

let emptyRoot = Group(key: "🚫", label: "Config error", actions: [])
let defaultEditKey = "Default"

class UserConfig: ObservableObject {
  // Root for the default config (config.json)
  @Published var root = emptyRoot
  // Root for the config currently being edited in Settings
  @Published var currentlyEditingGroup = emptyRoot
  @Published var validationErrors: [ValidationError] = [] // Errors specific to the default config
  @Published var discoveredConfigFiles: [String: String] = [:] // Key -> File Path
  @Published var selectedConfigKeyForEditing: String = defaultEditKey // "Default" or Bundle ID

  let fileName = "config.json"
  let appConfigPrefix = "app."
  let defaultAppConfigFileName = "app.default.json" // Added default app config filename
  private var appConfigs: [String: Group?] = [:] // Cache for app-specific configs
  private let alertHandler: AlertHandler
  private let fileManager: FileManager
  private var suppressValidationAlerts = false

  init(
    alertHandler: AlertHandler = DefaultAlertHandler(),
    fileManager: FileManager = .default
  ) {
    self.alertHandler = alertHandler
    self.fileManager = fileManager
  }

  // MARK: - Group Path Handling
  
  // Get a unique identifier for a group based on its path in the tree
  func getGroupPath(for group: Group) -> String {
    var path = ""
    // This should operate on the default config structure
    findGroupPathRecursive(root, [], group, &path)
    return path.isEmpty ? "root" : path
  }
  
  private func findGroupPathRecursive(_ current: Group, _ currentPath: [String], _ target: Group, _ result: inout String) {
    if current.key == target.key && current.label == target.label {
      result = currentPath.joined(separator: "/")
      return
    }
    
    for (index, item) in current.actions.enumerated() {
      if case .group(let subgroup) = item {
        var newPath = currentPath
        newPath.append("\(index)_\(subgroup.key ?? "")")
        findGroupPathRecursive(subgroup, newPath, target, &result)
      }
    }
  }
  
  // Find a group by its path
  func findGroupByPath(_ path: String) -> Group? {
    // This should operate on the default config structure
    if path == "root" {
      return root
    }

    let components = path.components(separatedBy: "/")
    // Start search from default root
    var currentGroup = root

    for component in components {
      let parts = component.components(separatedBy: "_")
      guard parts.count >= 2, let index = Int(parts[0]) else { return nil }
      
      if index < currentGroup.actions.count {
        if case .group(let subgroup) = currentGroup.actions[index] {
          currentGroup = subgroup
        } else {
          return nil
        }
      } else {
        return nil
      }
    }
    
    return currentGroup
  }

  // MARK: - Public Interface

  func ensureAndLoad() {
    ensureValidConfigDirectory()
    discoverConfigFiles() // Discover before ensuring/loading
    ensureConfigFileExists() // Ensures default config.json exists
    loadConfig() // Loads the default config into 'root'
    // Initially, load the default config for editing
    if let defaultPath = discoveredConfigFiles[defaultEditKey] {
        currentlyEditingGroup = decodeConfig(from: defaultPath, suppressAlerts: false, isDefaultConfig: true) ?? emptyRoot
        selectedConfigKeyForEditing = defaultEditKey
        // Set initial validation errors based on default config
        validationErrors = ConfigValidator.validate(group: root)
    } else {
        // If default doesn't exist somehow, ensure editor has empty root
        currentlyEditingGroup = emptyRoot
        selectedConfigKeyForEditing = defaultEditKey
    }
  }

  func reloadConfig() {
    Events.send(.willReload)
    appConfigs = [:] // Clear app-specific cache
    discoverConfigFiles() // Re-discover files
    loadConfig(suppressAlerts: true) // Reload default config into 'root'
    // Reload the currently selected config for editing
    loadConfigForEditing(key: selectedConfigKeyForEditing)
    Events.send(.didReload)
  }

  // Saves the configuration currently being edited in the Settings window
  func saveCurrentlyEditingConfig() {
    guard let filePath = discoveredConfigFiles[selectedConfigKeyForEditing] else {
        handleError(NSError(domain: "UserConfig", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not find file path for selected config key: \(selectedConfigKeyForEditing)"]), critical: true)
        return
    }

    // Validate the group being saved
    let errors = ConfigValidator.validate(group: currentlyEditingGroup)
    if !errors.isEmpty {
      // We might want a specific alert here, distinct from the default config validation alert
      let errorCount = errors.count
      alertHandler.showAlert(
        style: .warning,
        message:
          "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in the \'\(selectedConfigKeyForEditing)\' configuration. It will still be saved, but some keys may not work as expected."
      )
      // Update main validationErrors state only if we are saving the default config
      if selectedConfigKeyForEditing == defaultEditKey {
          self.validationErrors = errors
      } else {
          // Maybe store app-specific errors separately if needed?
          print("Validation issues found in \(selectedConfigKeyForEditing) config, but not setting main validationErrors.")
      }
    } else if selectedConfigKeyForEditing == defaultEditKey {
        // Clear errors if default config is now valid
        self.validationErrors = []
    }

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [
        .prettyPrinted, .withoutEscapingSlashes, .sortedKeys,
      ]
      let jsonData = try encoder.encode(currentlyEditingGroup)
      try jsonData.write(to: URL(fileURLWithPath: filePath)) // Write to the specific file path

      // If the saved config was the default one, update the main 'root' property as well
      if selectedConfigKeyForEditing == defaultEditKey {
          self.root = currentlyEditingGroup
      }
      // If the saved config was an app-specific one, clear its cache entry
      // so it gets reloaded fresh next time getConfig(for:) is called.
      if selectedConfigKeyForEditing != defaultEditKey {
          appConfigs[selectedConfigKeyForEditing] = nil
      }

    } catch {
      handleError(error, critical: true)
    }

    // No full reloadConfig() here to avoid resetting the UI state unnecessarily,
    // but we might need to signal that a save happened.
    Events.send(.didSaveConfig) // Send a specific event if needed elsewhere
  }

  // MARK: - Directory Management

  static func defaultDirectory() -> String {
    let appSupportDir = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let path = (appSupportDir.path as NSString).appendingPathComponent(
      "Leader Key")
    do {
      try FileManager.default.createDirectory(
        atPath: path, withIntermediateDirectories: true)
    } catch {
      fatalError("Failed to create config directory")
    }
    return path
  }

  private func ensureValidConfigDirectory() {
    let dir = Defaults[.configDir]
    let defaultDir = Self.defaultDirectory()

    if !fileManager.fileExists(atPath: dir) {
      alertHandler.showAlert(
        style: .warning,
        message:
          "Config directory does not exist: \(dir)\nResetting to default location."
      )
      Defaults[.configDir] = defaultDir
    }
  }

  // MARK: - File Operations

  var path: String {
    (Defaults[.configDir] as NSString).appendingPathComponent(fileName)
  }

  var url: URL {
    URL(fileURLWithPath: path)
  }

  var exists: Bool {
    fileManager.fileExists(atPath: path)
  }

  private func ensureConfigFileExists() {
    guard !exists else { return }

    do {
      try bootstrapConfig()
    } catch {
      handleError(error, critical: true)
    }
  }

  private func bootstrapConfig() throws {
    guard let data = defaultConfig.data(using: .utf8) else {
      throw NSError(
        domain: "UserConfig",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Failed to encode default config"]
      )
    }
    try writeFile(data: data)
  }

  private func writeFile(data: Data) throws {
    try data.write(to: url)
  }

  private func readFile() throws -> String {
    try String(contentsOfFile: path, encoding: .utf8)
  }

  // MARK: - Config Loading

  private func loadConfig(suppressAlerts: Bool = false) {
    let defaultPath = (Defaults[.configDir] as NSString).appendingPathComponent(fileName)
    // Use decodeConfig, indicating it's the default config
    if let loadedRoot = decodeConfig(from: defaultPath, suppressAlerts: suppressAlerts, isDefaultConfig: true) {
        self.root = loadedRoot
        // Update validationErrors state specifically for the default root
        self.validationErrors = ConfigValidator.validate(group: self.root)
        if !validationErrors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
          showValidationAlert()
        }
    } else {
        // If default config fails to load, reset root to emptyRoot
        self.root = emptyRoot
        self.validationErrors = []
        // Critical error shown by decodeConfig/handleError
    }
  }

  // Gets the config for a specific app bundle ID, falling back to app.default.json, then default config.json
  func getConfig(for bundleId: String?) -> Group {
      // 1. Try specific app config
      if let bundleId = bundleId, !bundleId.isEmpty {
          // Check cache first
          if let cachedConfig = appConfigs[bundleId] {
              return cachedConfig ?? root // Return cached config or default if cache entry is nil (load failed previously)
          }

          // Construct app-specific config path
          let appFileName = "\(appConfigPrefix)\(bundleId).json"
          let appConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(appFileName)

          if fileManager.fileExists(atPath: appConfigPath) {
              // Attempt to load and decode app-specific config
              if let appRoot = decodeConfig(from: appConfigPath, suppressAlerts: true, isDefaultConfig: false) {
                  appConfigs[bundleId] = appRoot // Cache successful load
                  return appRoot
              } else {
                  appConfigs[bundleId] = nil // Cache failed load explicitly as nil
                  // Fall through to try app.default.json
              }
          } else {
              // File doesn't exist, cache this fact by storing nil
              appConfigs[bundleId] = nil
              // Fall through to try app.default.json
          }
      }

      // 2. Try default app config (app.default.json)
      let defaultAppKey = "app.default"
      // Check cache first
      if let cachedDefaultAppConfig = appConfigs[defaultAppKey] {
          return cachedDefaultAppConfig ?? root // Return cached or default if nil
      }

      let defaultAppConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(defaultAppConfigFileName)
      if fileManager.fileExists(atPath: defaultAppConfigPath) {
          // Attempt to load and decode app.default.json
          if let defaultAppRoot = decodeConfig(from: defaultAppConfigPath, suppressAlerts: true, isDefaultConfig: false) {
              appConfigs[defaultAppKey] = defaultAppRoot // Cache successful load
              return defaultAppRoot
          } else {
              appConfigs[defaultAppKey] = nil // Cache failed load as nil
              // Fall through to default config.json
          }
      } else {
          // File doesn't exist, cache this fact
          appConfigs[defaultAppKey] = nil
      }

      // 3. Fallback to default config.json (already loaded into self.root)
      return root
  }

  // Helper to decode a config file from a given path
  // isDefaultConfig flag helps manage validation errors and critical error handling
  private func decodeConfig(from filePath: String, suppressAlerts: Bool = false, isDefaultConfig: Bool) -> Group? {
    guard fileManager.fileExists(atPath: filePath) else {
      // Only treat missing default config as potentially critical (handled by caller)
      if isDefaultConfig {
          print("Warning: Default config file not found at: \(filePath)")
      } // Don't show error for missing app-specific file here
      return nil
    }

    do {
      let configString = try String(contentsOfFile: filePath, encoding: .utf8)

      guard let jsonData = configString.data(using: .utf8) else {
        throw NSError(
          domain: "UserConfig",
          code: 1,
          userInfo: [
            NSLocalizedDescriptionKey: "Failed to encode config file as UTF-8: \(filePath)"
          ]
        )
      }

      let decoder = JSONDecoder()
      let decodedRoot = try decoder.decode(Group.self, from: jsonData)

      // Perform validation regardless, but only show alerts/update main state for default config
      let errors = ConfigValidator.validate(group: decodedRoot)
      if !errors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
           if isDefaultConfig {
              // Store errors only if it's the default config being decoded in a context
              // where we should update the main validationErrors state (e.g., initial load)
              // This assignment might be redundant if caller updates validationErrors anyway.
              // validationErrors = errors
              showValidationAlert() // Show alert only for default config
           } else {
              // Log validation issues for app-specific configs, but don't trigger primary alert/state
              print("Validation issues found in app-specific config: \(filePath)")
           }
      }
      return decodedRoot
    } catch {
      // Handle critical errors only for the default config.json
      handleError(error, critical: isDefaultConfig)
      return nil // Return nil on any decoding error
    }
  }

  private func showValidationAlert() {
      let errorCount = validationErrors.count
      alertHandler.showAlert(
        style: .warning,
        message:
          "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in your default configuration (config.json). Some keys may not work as expected."
      )
  }

  // MARK: - Config Loading

  // Loads the config identified by the key ("Default" or bundle ID) into currentlyEditingGroup
  func loadConfigForEditing(key: String) {
    guard let filePath = discoveredConfigFiles[key] else {
      print("Error: Config file path not found for key: \(key)")
      currentlyEditingGroup = emptyRoot
      selectedConfigKeyForEditing = defaultEditKey // Revert selection
      return
    }
    // Load and decode. Suppress validation alerts for non-default configs during this specific load.
    let isDefault = (key == defaultEditKey)
    if let loadedGroup = decodeConfig(from: filePath, suppressAlerts: !isDefault, isDefaultConfig: isDefault) {
        currentlyEditingGroup = loadedGroup
        selectedConfigKeyForEditing = key
        // Main validationErrors state is only updated when loading/saving the default config itself
    } else {
        handleError(NSError(domain: "UserConfig", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load config \'\(key)\' for editing from path: \(filePath)"]), critical: false)
        currentlyEditingGroup = emptyRoot
        // Consider reverting selectedConfigKeyForEditing? Or let UI show load failed?
        // For now, keep selection but show empty editor
    }
  }

  // MARK: - File Discovery

  private func discoverConfigFiles() {
      var discovered: [String: String] = [:]
      let configDir = Defaults[.configDir]
      let configDirUrl = URL(fileURLWithPath: configDir)

      // Add default config first
      let defaultPath = (configDir as NSString).appendingPathComponent(fileName)
      if fileManager.fileExists(atPath: defaultPath) {
          discovered[defaultEditKey] = defaultPath
      }

      do {
          let fileURLs = try fileManager.contentsOfDirectory(at: configDirUrl, includingPropertiesForKeys: nil)
          for fileURL in fileURLs {
              let fileName = fileURL.lastPathComponent
              if fileName.hasPrefix(appConfigPrefix) && fileName.hasSuffix(".json") {
                  // Extract bundle ID
                  let bundleId = String(fileName.dropFirst(appConfigPrefix.count).dropLast(".json".count))
                  if !bundleId.isEmpty {
                      discovered[bundleId] = fileURL.path
                  }
              }
          }
      } catch {
          handleError(NSError(domain: "UserConfig", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to list contents of config directory: \(configDir)"]), critical: false)
      }
      // Update the published property
      self.discoveredConfigFiles = discovered
  }

  // MARK: - Validation

  func validateWithoutAlerts() {
    validationErrors = ConfigValidator.validate(group: root)
  }

  func finishEditingKey() {
    validateWithoutAlerts()
  }

  // MARK: - Error Handling

  private func handleError(_ error: Error, critical: Bool) {
    alertHandler.showAlert(
      style: critical ? .critical : .warning, message: "\(error)")
    // Resetting root/currentlyEditingGroup on critical errors needs care
    if critical {
      root = emptyRoot
      currentlyEditingGroup = emptyRoot
      validationErrors = []
      // Maybe reset selection?
      selectedConfigKeyForEditing = defaultEditKey
      // Re-discover files? Might be problematic if dir access is the issue.
      discoverConfigFiles()
    }
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
}

protocol Item {
  var key: String? { get }
  var type: Type { get }
  var label: String? { get }
  var displayName: String { get }
  var iconPath: String? { get set }
}

struct Action: Item, Codable, Equatable {
  var key: String?
  var type: Type
  var label: String?
  var value: String
  var iconPath: String?

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
    default:
      return value
    }
  }
}

struct Group: Item, Codable, Equatable {
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

enum ActionOrGroup: Codable, Equatable {
  case action(Action)
  case group(Group)

  var item: Item {
    switch self {
    case .group(let group): return group
    case .action(let action): return action
    }
  }

  private enum CodingKeys: String, CodingKey {
    case key, type, value, actions, label, iconPath
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let key = try container.decode(String?.self, forKey: .key)
    let type = try container.decode(Type.self, forKey: .type)
    let label = try container.decodeIfPresent(String.self, forKey: .label)
    let iconPath = try container.decodeIfPresent(String.self, forKey: .iconPath)

    switch type {
    case .group:
      let actions = try container.decode([ActionOrGroup].self, forKey: .actions)
      self = .group(Group(key: key, label: label, iconPath: iconPath, actions: actions))
    default:
      let value = try container.decode(String.self, forKey: .value)
      self = .action(Action(key: key, type: type, label: label, value: value, iconPath: iconPath))
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
