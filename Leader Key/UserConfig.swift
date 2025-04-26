import Cocoa
import Combine
import Defaults

let emptyRoot = Group(key: "🚫", label: "Config error", actions: [])

class UserConfig: ObservableObject {
  @Published var root = emptyRoot
  @Published var validationErrors: [ValidationError] = []

  let fileName = "config.json"
  let appConfigPrefix = "app."
  private var appConfigs: [String: Group?] = [:]
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
    if path == "root" {
      return root
    }
    
    let components = path.components(separatedBy: "/")
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
    ensureConfigFileExists()
    loadConfig()
  }

  func reloadConfig() {
    Events.send(.willReload)
    appConfigs = [:]
    loadConfig(suppressAlerts: true)
    Events.send(.didReload)
  }

  func saveConfig() {
    validationErrors = ConfigValidator.validate(group: root)

    if !validationErrors.isEmpty {
      let errorCount = validationErrors.count
      alertHandler.showAlert(
        style: .warning,
        message:
          "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in your configuration. The configuration will still be saved, but some keys may not work as expected."
      )
    }

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [
        .prettyPrinted, .withoutEscapingSlashes, .sortedKeys,
      ]
      let jsonData = try encoder.encode(root)
      try writeFile(data: jsonData)
    } catch {
      handleError(error, critical: true)
    }

    reloadConfig()
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
    if let loadedRoot = decodeConfig(from: defaultPath, suppressAlerts: suppressAlerts) {
        self.root = loadedRoot
        self.validationErrors = ConfigValidator.validate(group: self.root)
        if !validationErrors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
          showValidationAlert()
        }
    } else {
        self.root = emptyRoot
        self.validationErrors = []
    }
  }

  func getConfig(for bundleId: String?) -> Group {
      guard let bundleId = bundleId, !bundleId.isEmpty else {
          return root
      }

      if let cachedConfig = appConfigs[bundleId] {
          return cachedConfig ?? root
      }

      let appFileName = "\(appConfigPrefix)\(bundleId).json"
      let appConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(appFileName)

      if fileManager.fileExists(atPath: appConfigPath) {
          if let appRoot = decodeConfig(from: appConfigPath, suppressAlerts: true) {
              appConfigs[bundleId] = appRoot
              return appRoot
          } else {
              appConfigs[bundleId] = nil
          }
      } else {
          appConfigs[bundleId] = nil
      }

      return root
  }

  private func decodeConfig(from filePath: String, suppressAlerts: Bool = false) -> Group? {
    guard fileManager.fileExists(atPath: filePath) else {
      if !filePath.contains(appConfigPrefix) {
          handleError(NSError(domain: "UserConfig", code: 2, userInfo: [NSLocalizedDescriptionKey: "Config file not found at: \(filePath)"]), critical: false)
      }
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

      let errors = ConfigValidator.validate(group: decodedRoot)
      if !errors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
           if !filePath.contains(appConfigPrefix) {
              validationErrors = errors
              showValidationAlert()
           } else {
              print("Validation issues found in app-specific config: \(filePath)")
           }
      }
      return decodedRoot
    } catch {
      let isCritical = !filePath.contains(appConfigPrefix)
      handleError(error, critical: isCritical)
      return nil
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
    if critical {
      root = emptyRoot
      validationErrors = []
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
