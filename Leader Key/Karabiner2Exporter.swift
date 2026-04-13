import AppKit
import Defaults
import Foundation
import KeyboardShortcuts

final class Karabiner2Exporter {

  struct StateNode {
    let path: [String]
    let originalPath: [String]  // Store original keys for CLI commands
    let stateId: Int32
    let item: ActionOrGroup
    let isTerminal: Bool
    let parentGroupHasStickyMode: Bool  // Track if parent group has sticky mode enabled
  }
  
  struct AppMetadata: Codable {
    let customName: String?
    let createdAt: Double?
    let lastModified: Double?
  }
  
  // Structure to store state ID to action mapping
  struct StateMapping: Codable {
    enum Scope: String, Codable {
      case global
      case appShared
      case appOverride
      case appSuppress
      case fallbackOnly
    }

    let stateId: Int32
    let path: [String]          // Path in key notation (e.g., ["o", "a"])
    let scope: Scope
    let appAlias: String?        // App alias if app-specific
    let bundleId: String?        // Bundle ID if app-specific
    let actionType: String       // "action" or "group"
    let actionTypeRaw: String?   // The raw action type (.application, .command, .url, etc.)
    let actionValue: String?     // The actual action value to execute
    let actionLabel: String?     // Display label for the action
  }

  struct KarabinerTSExport {
    let managedRules: [[String: Any]]
    let stateMappings: [StateMapping]
  }

  private struct AppAliasConfig {
    let bundleId: String
    let alias: String
    let customName: String?
    let config: UserConfig
  }

  private enum ManagedBindingKind {
    case group
    case action
    case suppress
  }

  private struct ManagedBinding {
    let parentStateId: Int32
    let stateId: Int32?
    let path: [String]
    let originalPath: [String]
    let item: ActionOrGroup
    let kind: ManagedBindingKind
    let parentGroupHasStickyMode: Bool
    let scope: StateMapping.Scope
    let appAlias: String?
    let bundleId: String?
  }

  private struct ManagedExportModel {
    let appAliases: [AppAliasConfig]
    let rules: [[String: Any]]
    let stateMappings: [StateMapping]
    let globalBindings: [ManagedBinding]
    let sharedAppBindings: [ManagedBinding]
    let appBindingsByAlias: [String: [ManagedBinding]]
  }

  private struct StateIdentity: Equatable {
    let namespace: String
    let path: [String]
    let kind: String
    let scope: StateMapping.Scope
    let bundleId: String?

    var debugDescription: String {
      let pathDescription = path.isEmpty ? "<root>" : path.joined(separator: ".")
      let bundleDescription = bundleId.map { " bundle=\($0)" } ?? ""
      return "scope=\(scope.rawValue) namespace=\(namespace) kind=\(kind) path=\(pathDescription)\(bundleDescription)"
    }
  }

  private enum ExportBuildError: LocalizedError {
    case stateIdCollision(stateId: Int32, existing: StateIdentity, incoming: StateIdentity)

    var errorDescription: String? {
      switch self {
      case .stateIdCollision(let stateId, let existing, let incoming):
        return """
          LeaderKey export state-id collision for \(stateId):
          existing: \(existing.debugDescription)
          incoming: \(incoming.debugDescription)
          """
      }
    }
  }

  private final class StateIdRegistry {
    private var identities: [Int32: StateIdentity] = [:]

    func reserve(_ stateId: Int32, identity: StateIdentity) throws {
      if let existing = identities[stateId] {
        guard existing == identity else {
          let message = "LeaderKey export state-id collision for \(stateId): \(existing.debugDescription) vs \(identity.debugDescription)"
          if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            assertionFailure(message)
          }
          throw ExportBuildError.stateIdCollision(stateId: stateId, existing: existing, incoming: identity)
        }
        return
      }

      identities[stateId] = identity
    }

    func makeStateId(
      namespace: String,
      path: [String],
      kind: String,
      scope: StateMapping.Scope,
      bundleId: String?
    ) throws -> Int32 {
      let identity = StateIdentity(
        namespace: namespace,
        path: path,
        kind: kind,
        scope: scope,
        bundleId: bundleId
      )

      if let overriddenStateId = Karabiner2Exporter.stateIdOverride?(path, bundleId ?? namespace) {
        try reserve(overriddenStateId, identity: identity)
        return overriddenStateId
      }

      let pathString = ([namespace, kind] + path).joined(separator: ".")
      var hash: Int64 = 5381
      for byte in pathString.utf8 {
        hash = ((hash << 5) &+ hash) &+ Int64(byte)
      }

      let maxValue: Int32 = 2_147_483_647
      let minValue: Int32 = 3
      let positiveHash = abs(hash)
      let scaledHash = positiveHash % Int64(maxValue - minValue)
      let stateId = Int32(scaledHash) + minValue

      try reserve(stateId, identity: identity)
      return stateId
    }
  }

  private struct ManagedBindingCollections {
    var bindings: [ManagedBinding] = []
    var stateMappings: [StateMapping] = []
  }

  // Different initial states for different activation types
  private static let globalInitialStateId: Int32 = 1
  private static let fallbackInitialStateId: Int32 = 2
  private static let inactiveStateId: Int32 = 0
  private static let appStartMarker = ";;; LEADERKEY_APPLICATIONS_START"
  private static let appEndMarker = ";;; LEADERKEY_APPLICATIONS_END"
  private static let mainStartMarker = ";;; LEADERKEY_MAIN_START"
  private static let mainEndMarker = ";;; LEADERKEY_MAIN_END"
  private static let specificConfigsStartMarker = ";;; LEADERKEY_SPECIFIC_CONFIGS_START"
  private static let specificConfigsEndMarker = ";;; LEADERKEY_SPECIFIC_CONFIGS_END"

  static func generateGokuEDN(from config: UserConfig, bundleId: String? = nil) -> String {
    do {
      let managedModel: ManagedExportModel
      if let bundleId {
        managedModel = try buildManagedExportModel(
          globalConfig: UserConfig(),
          appConfigs: [(bundleId: bundleId, config: config, customName: nil)]
        )
      } else {
        managedModel = try buildManagedExportModel(
          globalConfig: config,
          appConfigs: []
        )
      }

      let managedRules = applyKarAlternativeMappings(
        to: compileKarIntermediateRules(managedModel.rules)
      )
      let applications = managedModel.appAliases.isEmpty
        ? ""
        : generateApplicationsSectionFromAliases(
          appAliases: managedModel.appAliases.map { ($0.bundleId, $0.alias, $0.config) }
        )

      return formatManagedGokuEDN(
        applications: applications,
        managedRules: managedRules,
        appAliases: managedModel.appAliases
      )
    } catch {
      debugLog("[Karabiner2Exporter] Failed to generate Goku EDN: \(error)")
      return formatManagedGokuEDN(applications: "", managedRules: [], appAliases: [])
    }
  }
  
  // Generate unified EDN with hierarchical organization and :condi grouping
  // Returns: (ednContent, stateMappings)
  static func generateUnifiedGokuEDNHierarchical(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) throws -> (edn: String, stateMappings: [StateMapping]) {
    debugLog("[Karabiner2Exporter] generateUnifiedGokuEDNHierarchical called with \(appConfigs.count) app configs")

    let managedModel = try buildManagedExportModel(
      globalConfig: globalConfig,
      appConfigs: appConfigs
    )
    let managedRules = applyKarAlternativeMappings(to: compileKarIntermediateRules(managedModel.rules))
    let applications = generateApplicationsSectionFromAliases(
      appAliases: managedModel.appAliases.map { ($0.bundleId, $0.alias, $0.config) }
    )
    let ednContent = formatManagedGokuEDN(
      applications: applications,
      managedRules: managedRules,
      appAliases: managedModel.appAliases
    )

    return (edn: ednContent, stateMappings: managedModel.stateMappings)
  }
  
  // Generate unified EDN with all app configs in a single file (legacy flat version)
  // Returns: (ednContent, stateMappings)
  static func generateUnifiedGokuEDN(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) -> (edn: String, stateMappings: [StateMapping]) {
    do {
      return try generateUnifiedGokuEDNHierarchical(
        globalConfig: globalConfig,
        appConfigs: appConfigs
      )
    } catch {
      debugLog("[Karabiner2Exporter] Failed to generate unified Goku EDN: \(error)")
      return (
        edn: formatManagedGokuEDN(applications: "", managedRules: [], appAliases: []),
        stateMappings: []
      )
    }
  }

  static func generateKarabinerTSExport(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) throws -> KarabinerTSExport {
    let tStart = CFAbsoluteTimeGetCurrent()
    let managedModel = try buildManagedExportModel(
      globalConfig: globalConfig,
      appConfigs: appConfigs
    )
    let tModel = CFAbsoluteTimeGetCurrent()

    let compiledRules = compileKarIntermediateRules(managedModel.rules)
    let tCompile = CFAbsoluteTimeGetCurrent()

    let managedRules = applyKarAlternativeMappings(to: compiledRules)
    let tAltMappings = CFAbsoluteTimeGetCurrent()

    debugLog("[Benchmark] karabiner.ts.gen shared-model (\(managedModel.appAliases.count) apps): \(String(format: "%.0f", (tModel - tStart) * 1000))ms")
    debugLog("[Benchmark] karabiner.ts.gen compile (\(managedModel.rules.count) intermediate → \(compiledRules.count) compiled): \(String(format: "%.0f", (tCompile - tModel) * 1000))ms")
    debugLog("[Benchmark] karabiner.ts.gen altMappings: \(String(format: "%.0f", (tAltMappings - tCompile) * 1000))ms")
    debugLog("[Benchmark] karabiner.ts.gen TOTAL (critical path): \(String(format: "%.0f", (tAltMappings - tStart) * 1000))ms")

    return KarabinerTSExport(
      managedRules: managedRules,
      stateMappings: managedModel.stateMappings)  // Unsorted — caller sorts on background thread
  }

  /// Generate the raw JSON data for managed rules.
  /// Call on background thread when possible.
  static func generateModuleJSON(managedRules: [[String: Any]]) -> Data {
    if let jsonData = try? JSONSerialization.data(
      withJSONObject: managedRules,
      options: [.sortedKeys])
    {
      return jsonData
    }
    debugLog("[Karabiner2Exporter] Failed to serialize managed rules; generating empty export")
    return Data("[]".utf8)
  }

  /// Sort state mappings for stable output.
  /// Moderately expensive (~24ms for 5700 mappings). Can be deferred.
  static func sortMappings(_ mappings: [StateMapping]) -> [StateMapping] {
    sortedStateMappings(mappings)
  }

  private static let managedRuleDescriptionPrefix = "LeaderKeyManaged/"

  private static func terminalActionHasStickyMode(for node: StateNode) -> Bool {
    if case .action(let action) = node.item {
      return node.parentGroupHasStickyMode || action.stickyMode == true || action.type == .toggleStickyMode
    }
    return node.parentGroupHasStickyMode
  }

  private static func makeKarRule(
    description: String,
    mappings: [[String: Any]],
    condition: Any? = nil
  ) -> [String: Any] {
    var rule: [String: Any] = [
      "description": description,
      "mappings": mappings
    ]
    if let condition {
      rule["condition"] = condition
    }
    return rule
  }

  private static func compileKarIntermediateRules(_ rules: [[String: Any]]) -> [[String: Any]] {
    compactCompiledRules(rules.compactMap(compileKarIntermediateRule))
  }

  private static func compactCompiledRules(_ rules: [[String: Any]]) -> [[String: Any]] {
    var compactedRules: [[String: Any]] = []
    var ruleIndexByDescription: [String: Int] = [:]

    for rule in rules {
      let description = compactManagedRuleDescription(
        rule["description"] as? String ?? managedRuleDescriptionPrefix + "Unnamed")
      let manipulators = rule["manipulators"] as? [[String: Any]] ?? []
      guard !manipulators.isEmpty else { continue }

      if let existingIndex = ruleIndexByDescription[description] {
        var existingRule = compactedRules[existingIndex]
        var existingManipulators = existingRule["manipulators"] as? [[String: Any]] ?? []
        existingManipulators.append(contentsOf: manipulators)
        existingRule["manipulators"] = existingManipulators
        compactedRules[existingIndex] = existingRule
        continue
      }

      var compactedRule = rule
      compactedRule["description"] = description
      ruleIndexByDescription[description] = compactedRules.count
      compactedRules.append(compactedRule)
    }

    return compactedRules
  }

  static var alternativeMappingsOverride: [AlternativeMapping]?
  static var stateIdOverride: (([String], String?) -> Int32?)?

  private static func currentAlternativeMappings() -> [AlternativeMapping] {
    alternativeMappingsOverride ?? AlternativeMappingsManager.shared.mappings
  }

  private static func applyKarAlternativeMappings(to rules: [[String: Any]]) -> [[String: Any]] {
    let mappings = currentAlternativeMappings()
    guard !mappings.isEmpty else { return rules }
    let mappingsByOriginalKey = Dictionary(grouping: mappings, by: \.originalKey)

    return rules.map { rule in
      let description = rule["description"] as? String ?? ""
      guard description != "\(managedRuleDescriptionPrefix)ActivationShortcuts",
        description != "\(managedRuleDescriptionPrefix)ModifierPassThrough"
      else {
        return rule
      }

      let manipulators = rule["manipulators"] as? [[String: Any]] ?? []
      var manipulatorsWithAlternatives: [[String: Any]] = []

      for manipulator in manipulators {
        let from = manipulator["from"] as? [String: Any]
        let keyCode = from?["key_code"] as? String
        let matchingMappings = mappingsByOriginalKey[keyCode ?? ""]?.filter { mapping in
          guard mapping.originalKey == keyCode else { return false }
          guard let appAlias = mapping.appAlias else { return true }
          return description.contains("/AppMode/\(appAlias)")
        } ?? []

        for mapping in matchingMappings {
          var alternativeManipulator = manipulator
          var alternativeFrom = from ?? [:]
          alternativeFrom["key_code"] = mapping.alternativeKey
          alternativeManipulator["from"] = alternativeFrom

          var conditions = alternativeManipulator["conditions"] as? [[String: Any]] ?? []
          conditions.append(contentsOf: mapping.conditions.map { [
            "type": "variable_if",
            "name": $0,
            "value": 1,
          ] })
          alternativeManipulator["conditions"] = conditions
          manipulatorsWithAlternatives.append(alternativeManipulator)
        }

        manipulatorsWithAlternatives.append(manipulator)
      }

      var updatedRule = rule
      updatedRule["manipulators"] = manipulatorsWithAlternatives
      return updatedRule
    }
  }

  private static func compactManagedRuleDescription(_ description: String) -> String {
    description.replacingOccurrences(
      of: #"/(State|CatchAll)/[^/]+$"#,
      with: "",
      options: .regularExpression
    )
  }

  private static func compileKarIntermediateRule(_ rule: [String: Any]) -> [String: Any]? {
    let description = rule["description"] as? String ?? managedRuleDescriptionPrefix + "Unnamed"
    let ruleConditions = compileKarCondition(rule["condition"])
    let mappings = rule["mappings"] as? [[String: Any]] ?? []

    let manipulators = mappings.compactMap { mapping -> [String: Any]? in
      guard let from = compileKarFrom(mapping["from"]) else {
        return nil
      }

      let mappingConditions = compileKarCondition(mapping["condition"])
      let conditions = ruleConditions + mappingConditions

      var manipulator: [String: Any] = [
        "type": "basic",
        "from": from,
        "to": compileKarToEvents(mapping["to"]),
      ]

      if !conditions.isEmpty {
        manipulator["conditions"] = conditions
      }

      return manipulator
    }

    guard !manipulators.isEmpty else {
      return nil
    }

    return [
      "description": description,
      "manipulators": manipulators,
    ]
  }

  private static func compileKarFrom(_ value: Any?) -> [String: Any]? {
    if let keyCode = value as? String {
      return ["key_code": keyCode]
    }

    guard let from = value as? [String: Any] else {
      return nil
    }

    var compiled: [String: Any]
    if let keyCode = from["key"] as? String {
      compiled = ["key_code": keyCode]
    } else if let any = from["any"] as? String {
      compiled = ["any": any]
    } else {
      return nil
    }

    var modifiers: [String: Any] = [:]

    if let mandatory = normalizedStringArray(from["modifiers"]), !mandatory.isEmpty {
      modifiers["mandatory"] = mandatory
    }

    if let optional = normalizedStringArray(from["optional"]), !optional.isEmpty {
      modifiers["optional"] = optional
    }

    if !modifiers.isEmpty {
      compiled["modifiers"] = modifiers
    }

    return compiled
  }

  private static func compileKarToEvents(_ value: Any?) -> [[String: Any]] {
    let rawEvents = value as? [Any] ?? []
    return rawEvents.compactMap { event in
      if let keyCode = event as? String {
        return ["key_code": keyCode]
      }

      guard let eventObject = event as? [String: Any] else {
        return nil
      }

      if let shell = eventObject["shell"] as? String {
        return ["shell_command": shell]
      }

      return eventObject
    }
  }

  private static func compileKarCondition(_ value: Any?) -> [[String: Any]] {
    if let conditions = value as? [[String: Any]] {
      return conditions.flatMap(compileKarCondition)
    }

    guard let condition = value as? [String: Any] else {
      return []
    }

    if let app = condition["app"] as? String {
      return [[
        "type": "frontmost_application_if",
        "bundle_identifiers": [app],
      ]]
    }

    if let variable = condition["variable"] as? String, let value = condition["value"] {
      return [[
        "type": "variable_if",
        "name": variable,
        "value": value,
      ]]
    }

    if let variable = condition["variable_unless"] as? String, let value = condition["value"] {
      return [[
        "type": "variable_unless",
        "name": variable,
        "value": value,
      ]]
    }

    if condition["type"] != nil {
      return [condition]
    }

    return []
  }

  private static func normalizedStringArray(_ value: Any?) -> [String]? {
    if let stringValue = value as? String {
      return [stringValue]
    }

    if let stringArray = value as? [String] {
      return stringArray
    }

    return nil
  }

  // karabinerTsModuleSource and javascriptStringLiteral removed — export now writes raw JSON directly

  private static func generateKarActivationMapping(
    keyCode: String,
    modifiers: [String],
    initialStateId: Int32,
    bundleId: String?,
    isAppSpecificMode: Bool,
    additionalConditions: [[String: Any]] = []
  ) -> [String: Any]? {
    let activateCommand = bundleId.map { "activate \($0)" } ?? "activate"
    let _ = isAppSpecificMode

    var toEvents: [Any] = [karSetVariable(name: "leaderkey_sticky", value: 0)]
    toEvents.append(karSetVariable(name: "leader_state", value: initialStateId))
    toEvents.append(karSendUserCommand(activateCommand))

    var mapping: [String: Any] = [
      "from": karFrom(keyCode: keyCode, modifiers: modifiers),
      "to": toEvents
    ]
    if !additionalConditions.isEmpty {
      mapping["condition"] = additionalConditions
    }
    return mapping
  }

  private static func generateKarEscapeMapping(
    additionalConditions: [[String: Any]] = []
  ) -> [String: Any]? {
    let toEvents: [Any] = [
      karSetVariable(name: "leaderkey_sticky", value: 0),
      karSetVariable(name: "leader_state", value: inactiveStateId),
      karSendUserCommand("deactivate")
    ]

    return [
      "from": "escape",
      "to": toEvents,
      "condition": [variableUnlessCondition(name: "leader_state", value: 0)] + additionalConditions
    ]
  }

  private static func generateKarSettingsMapping(
    additionalConditions: [[String: Any]] = []
  ) -> [String: Any]? {
    let toEvents: [Any] = [
      karSetVariable(name: "leaderkey_sticky", value: 0),
      karSetVariable(name: "leader_state", value: inactiveStateId),
      karSendUserCommand("deactivate"),
      karSendUserCommand("settings")
    ]

    return [
      "from": karFrom(keyCode: "comma", modifiers: ["command"]),
      "to": toEvents,
      "condition": [variableUnlessCondition(name: "leader_state", value: 0)] + additionalConditions
    ]
  }

  private static func generateKarModifierPassThroughMappings() -> [[String: Any]] {
    let modifiers = [
      "left_shift", "right_shift",
      "left_command", "right_command",
      "left_option", "right_option",
      "left_control", "right_control"
    ]

    return modifiers.map { keyCode in
      [
        "from": keyCode,
        "to": [keyCode],
        "condition": variableUnlessCondition(name: "leader_state", value: 0)
      ]
    }
  }

  private static func generateKarStateTransitionMapping(
    key: String,
    toState: Int32,
    hasStickyMode: Bool
  ) -> [String: Any]? {
    guard let (keyCode, modifiers) = parseKarKeySpec(key) else {
      return nil
    }

    var toEvents: [Any] = [
      karSetVariable(name: "leader_state", value: toState),
      karSendUserCommand("stateid \(toState)")
    ]
    if hasStickyMode {
      toEvents.append(karSetVariable(name: "leaderkey_sticky", value: 1))
    }

    return [
      "from": karFrom(keyCode: keyCode, modifiers: modifiers),
      "to": toEvents
    ]
  }

  private static func generateKarTerminalActionMapping(
    key: String,
    toState: Int32,
    hasStickyMode: Bool,
    node: StateNode
  ) -> [String: Any]? {
    guard let (keyCode, modifiers) = parseKarKeySpec(key) else {
      return nil
    }

    if case .action(let action) = node.item {
      switch action.type {
      case .url:
        let background = shouldUseBackgroundExecution(for: action)
        if hasStickyMode {
          return [
            "from": karFrom(keyCode: keyCode, modifiers: modifiers),
            "to": [
              karOpen(action.value, background: background),
              karSetVariable(name: "leaderkey_sticky", value: 1)
            ]
          ]
        }

        return [
          "from": karFrom(keyCode: keyCode, modifiers: modifiers),
          "to": [
            karOpen(action.value, background: background),
            karSendUserCommand("deactivate"),
            karSetVariable(name: "leader_state", value: inactiveStateId)
          ]
        ]

      case .application:
        if hasStickyMode {
          return [
            "from": karFrom(keyCode: keyCode, modifiers: modifiers),
            "to": [
              karOpenApp(action.value),
              karSetVariable(name: "leaderkey_sticky", value: 1)
            ]
          ]
        }

        return [
          "from": karFrom(keyCode: keyCode, modifiers: modifiers),
          "to": [
            karOpenApp(action.value),
            karSendUserCommand("deactivate"),
            karSetVariable(name: "leader_state", value: inactiveStateId)
          ]
        ]

      case .menu:
        let parts = action.value.components(separatedBy: " > ")
        if parts.count >= 2 {
          let appName = parts[0].trimmingCharacters(in: .whitespaces)
          let menuPath = parts.dropFirst().map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: " > ")
          if hasStickyMode {
            return [
              "from": karFrom(keyCode: keyCode, modifiers: modifiers),
              "to": [
                karMenu(app: appName, path: menuPath, fallbackPaths: action.menuFallbackPaths ?? []),
                karSetVariable(name: "leaderkey_sticky", value: 1)
              ]
            ]
          }
          return [
            "from": karFrom(keyCode: keyCode, modifiers: modifiers),
            "to": [
              karMenu(app: appName, path: menuPath, fallbackPaths: action.menuFallbackPaths ?? []),
              karSendUserCommand("deactivate"),
              karSetVariable(name: "leader_state", value: inactiveStateId)
            ]
          ]
        }

      case .intellij:
        if hasStickyMode {
          return [
            "from": karFrom(keyCode: keyCode, modifiers: modifiers),
            "to": [
              karIntelliJ(action: action.value),
              karSetVariable(name: "leaderkey_sticky", value: 1)
            ]
          ]
        }
        return [
          "from": karFrom(keyCode: keyCode, modifiers: modifiers),
          "to": [
            karIntelliJ(action: action.value),
            karSendUserCommand("deactivate"),
            karSetVariable(name: "leader_state", value: inactiveStateId)
          ]
        ]

      case .keystroke:
        let keystrokeValue = KeystrokeActionValue.parse(action.value)
        if hasStickyMode {
          return [
            "from": karFrom(keyCode: keyCode, modifiers: modifiers),
            "to": [
              karKeystroke(
                app: keystrokeValue.app,
                spec: keystrokeValue.spec,
                focusApp: keystrokeValue.focusTargetApp
              ),
              karSetVariable(name: "leaderkey_sticky", value: 1)
            ]
          ]
        }
        return [
          "from": karFrom(keyCode: keyCode, modifiers: modifiers),
          "to": [
            karKeystroke(
              app: keystrokeValue.app,
              spec: keystrokeValue.spec,
              focusApp: keystrokeValue.focusTargetApp
            ),
            karSendUserCommand("deactivate"),
            karSetVariable(name: "leader_state", value: inactiveStateId)
          ]
        ]

      case .command:
        let shellInvocation = buildShellInvocation(action.value)
        let shellCommand = hasStickyMode ? shellInvocation : "\(shellInvocation) &"
        if hasStickyMode {
          return [
            "from": karFrom(keyCode: keyCode, modifiers: modifiers),
            "to": [
              karShell(shellCommand),
              karSetVariable(name: "leaderkey_sticky", value: 1)
            ]
          ]
        }

        return [
          "from": karFrom(keyCode: keyCode, modifiers: modifiers),
          "to": [
            karShell(shellCommand),
            karSendUserCommand("deactivate"),
            karSetVariable(name: "leader_state", value: inactiveStateId)
          ]
        ]

      default:
        break
      }
    }

    let commandSuffix = hasStickyMode ? " sticky" : ""
    let stateCommand = "stateid \(toState)\(commandSuffix)"

    if hasStickyMode {
      return [
        "from": karFrom(keyCode: keyCode, modifiers: modifiers),
        "to": [
          karSendUserCommand(stateCommand),
          karSetVariable(name: "leaderkey_sticky", value: 1)
        ]
      ]
    }

    return [
      "from": karFrom(keyCode: keyCode, modifiers: modifiers),
      "to": [
        karSendUserCommand(stateCommand),
        karSetVariable(name: "leader_state", value: inactiveStateId)
      ]
    ]
  }

  private static func generateKarCatchAllMappings() -> [[String: Any]] {
    [[
      "from": [
        "any": "key_code",
        "modifiers": "any"
      ],
      "to": [
        karSendUserCommand("shake"),
        "vk_none"
      ],
      "condition": variableUnlessCondition(name: "leaderkey_sticky", value: 1)
    ]]
  }

  private static func karFrom(
    keyCode: String,
    modifiers: [String] = [],
    optionalAny: Bool = false
  ) -> Any {
    if modifiers.isEmpty && !optionalAny {
      return keyCode
    }

    var from: [String: Any] = ["key": keyCode]
    if !modifiers.isEmpty {
      from["modifiers"] = modifiers.count == 1 ? modifiers[0] : modifiers
    }
    if optionalAny {
      from["optional"] = ["any"]
    }
    return from
  }

  private static func karShell(_ command: String) -> [String: Any] {
    ["shell": command]
  }

  private static func karSendUserCommand(_ command: String) -> [String: Any] {
    ["send_user_command": ["payload": command]]
  }

  /// Generate Goku EDN for send_user_command (e.g. {:send_user_command "deactivate"})
  private static func gokuSendUserCommand(_ command: String) -> String {
    "{:send_user_command \"\(command)\"}"
  }

  /// Generate Goku EDN for send_user_command with v1 open_app payload
  private static func gokuOpenApp(_ appPath: String) -> String {
    "{:send_user_command {:payload {:v 1 :type \"open_app\" :app \"\(appPath)\"}}}"
  }

  /// Generate Goku EDN for send_user_command with v1 open payload (URLs, etc.)
  private static func gokuOpen(_ target: String, background: Bool = false) -> String {
    "{:send_user_command {:payload {:v 1 :type \"open\" :background \(background) :target \"\(target)\"}}}"
  }

  /// Generate Karabiner JSON for send_user_command with v1 open_app payload
  private static func karOpenApp(_ appPath: String) -> [String: Any] {
    ["send_user_command": ["payload": ["v": 1, "type": "open_app", "app": appPath]]]
  }

  /// Generate Karabiner JSON for send_user_command with v1 open payload (URLs, etc.)
  private static func karOpen(_ target: String, background: Bool = false) -> [String: Any] {
    ["send_user_command": ["payload": ["v": 1, "type": "open", "background": background, "target": target]]]
  }

  private static func ednEscapedString(_ value: String) -> String {
    value
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
  }

  private static func ednStringLiteral(_ value: String) -> String {
    "\"\(ednEscapedString(value))\""
  }

  private static func ednStringVector(_ values: [String]) -> String {
    "[\(values.map(ednStringLiteral).joined(separator: " "))]"
  }

  /// Generate Goku EDN for send_user_command with v1 menu payload
  private static func gokuMenu(app: String, path: String, fallbackPaths: [String] = []) -> String {
    let fallbackFragment = fallbackPaths.isEmpty ? "" : " :fallbackPaths \(ednStringVector(fallbackPaths))"
    return "{:send_user_command {:payload {:v 1 :type \"menu\" :app \(ednStringLiteral(app)) :path \(ednStringLiteral(path))\(fallbackFragment)}}}"
  }

  /// Generate Karabiner JSON for send_user_command with v1 menu payload
  private static func karMenu(app: String, path: String, fallbackPaths: [String] = []) -> [String: Any] {
    var payload: [String: Any] = ["v": 1, "type": "menu", "app": app, "path": path]
    if !fallbackPaths.isEmpty {
      payload["fallbackPaths"] = fallbackPaths
    }
    return ["send_user_command": ["payload": payload]]
  }

  /// Generate Goku EDN for send_user_command with v1 intellij payload
  private static func gokuIntelliJ(action: String) -> String {
    "{:send_user_command {:payload {:v 1 :type \"intellij\" :action \"\(action)\"}}}"
  }

  /// Generate Karabiner JSON for send_user_command with v1 intellij payload
  private static func karIntelliJ(action: String) -> [String: Any] {
    ["send_user_command": ["payload": ["v": 1, "type": "intellij", "action": action]]]
  }

  /// Generate Goku EDN for send_user_command with v1 keystroke payload
  private static func gokuKeystroke(app: String?, spec: String, focusApp: Bool = false) -> String {
    if let app = app {
      if focusApp {
        return "{:send_user_command {:payload {:v 1 :type \"keystroke\" :app \"\(app)\" :focus true :spec \"\(spec)\"}}}"
      }
      return "{:send_user_command {:payload {:v 1 :type \"keystroke\" :app \"\(app)\" :spec \"\(spec)\"}}}"
    }
    return "{:send_user_command {:payload {:v 1 :type \"keystroke\" :spec \"\(spec)\"}}}"
  }

  /// Generate Karabiner JSON for send_user_command with v1 keystroke payload
  private static func karKeystroke(app: String?, spec: String, focusApp: Bool = false) -> [String: Any] {
    var payload: [String: Any] = ["v": 1, "type": "keystroke", "spec": spec]
    if let app = app { payload["app"] = app }
    if app != nil && focusApp { payload["focus"] = true }
    return ["send_user_command": ["payload": payload]]
  }

  private static func karSetVariable(name: String, value: Any) -> [String: Any] {
    ["set_variable": ["name": name, "value": value]]
  }

  private static func variableCondition(name: String, value: Any) -> [String: Any] {
    ["variable": name, "value": value]
  }

  private static func variableUnlessCondition(name: String, value: Any) -> [String: Any] {
    ["variable_unless": name, "value": value]
  }

  private static func kinesisDeviceCondition() -> [String: Any] {
    [
      "type": "device_if",
      "identifiers": [
        ["product_id": 866, "vendor_id": 10730],
        ["product_id": 24926, "vendor_id": 7504],
        ["product_id": 10203, "vendor_id": 5824],
        ["product_id": 45074, "vendor_id": 1133],
      ],
    ]
  }

  private static func appleBuiltInDeviceCondition() -> [String: Any] {
    [
      "type": "device_if",
      "identifiers": [
        ["product_id": 0, "vendor_id": 0]
      ],
    ]
  }

  private static func builtInActivationConditions(appBundleId: String? = nil) -> [[String: Any]] {
    var conditions: [[String: Any]] = [
      variableUnlessCondition(name: "caps_lock-mode", value: 1),
      variableUnlessCondition(name: "f-mode", value: 1),
      variableUnlessCondition(name: "tilde-mode", value: 1),
    ]
    if let appBundleId {
      conditions.append(["app": appBundleId])
    }
    conditions.append(appleBuiltInDeviceCondition())
    return conditions
  }

  private static func bundleRegex(for bundleId: String) -> String {
    "^\(NSRegularExpression.escapedPattern(for: bundleId))$"
  }

  private static func resolveActivationShortcut(
    name: KeyboardShortcuts.Name,
    fallbackKeyCode: String,
    fallbackModifiers: [String]
  ) -> (keyCode: String, modifiers: [String]) {
    guard let shortcut = KeyboardShortcuts.getShortcut(for: name) else {
      return (fallbackKeyCode, fallbackModifiers)
    }

    guard let keyCode = karKeyCode(fromCarbonKeyCode: UInt32(shortcut.carbonKeyCode)) else {
      debugLog(
        "[Karabiner2Exporter] Unsupported shortcut keycode \(shortcut.carbonKeyCode) for \(name.rawValue). " +
          "Using fallback \(fallbackKeyCode)")
      return (fallbackKeyCode, fallbackModifiers)
    }

    let modifiers = karModifiers(from: shortcut.modifiers)
    return (keyCode, modifiers)
  }

  private static func gokuKeyExpression(keyCode: String, modifiers: [String]) -> String {
    if modifiers.isEmpty {
      return ":\(keyCode)"
    }

    let gokuModifiers = modifiers.map { ":\($0)" }
    if gokuModifiers.count == 1 {
      return "{:key :\(keyCode) :modi \(gokuModifiers[0])}"
    }

    return "{:key :\(keyCode) :modi [\(gokuModifiers.joined(separator: " "))]}"
  }

  private static func karModifiers(from modifiers: NSEvent.ModifierFlags) -> [String] {
    var values: [String] = []
    if modifiers.contains(.command) { values.append("command") }
    if modifiers.contains(.shift) { values.append("shift") }
    if modifiers.contains(.option) { values.append("option") }
    if modifiers.contains(.control) { values.append("control") }
    if modifiers.contains(.function) { values.append("fn") }
    return values
  }

  private static func karKeyCode(fromCarbonKeyCode keyCode: UInt32) -> String? {
    let map: [UInt32: String] = [
      0: "a",
      1: "s",
      2: "d",
      3: "f",
      4: "h",
      5: "g",
      6: "z",
      7: "x",
      8: "c",
      9: "v",
      11: "b",
      12: "q",
      13: "w",
      14: "e",
      15: "r",
      16: "y",
      17: "t",
      18: "1",
      19: "2",
      20: "3",
      21: "4",
      22: "6",
      23: "5",
      24: "equal_sign",
      25: "9",
      26: "7",
      27: "hyphen",
      28: "8",
      29: "0",
      30: "close_bracket",
      31: "o",
      32: "u",
      33: "open_bracket",
      34: "i",
      35: "p",
      36: "return_or_enter",
      37: "l",
      38: "j",
      39: "quote",
      40: "k",
      41: "semicolon",
      42: "backslash",
      43: "comma",
      44: "slash",
      45: "n",
      46: "m",
      47: "period",
      48: "tab",
      49: "spacebar",
      50: "grave_accent_and_tilde",
      51: "delete_or_backspace",
      53: "escape",
      54: "right_command",
      55: "left_command",
      56: "left_shift",
      57: "caps_lock",
      58: "left_option",
      59: "left_control",
      60: "right_shift",
      61: "right_option",
      62: "right_control",
      63: "fn",
      122: "f1",
      120: "f2",
      99: "f3",
      118: "f4",
      96: "f5",
      97: "f6",
      98: "f7",
      100: "f8",
      101: "f9",
      109: "f10",
      103: "f11",
      111: "f12",
      123: "left_arrow",
      124: "right_arrow",
      125: "down_arrow",
      126: "up_arrow"
    ]

    return map[keyCode]
  }

  private static func sortedStateMappings(_ mappings: [StateMapping]) -> [StateMapping] {
    mappings.sorted { lhs, rhs in
      if lhs.scope != rhs.scope {
        return lhs.scope.rawValue < rhs.scope.rawValue
      }
      if lhs.appAlias != rhs.appAlias {
        return (lhs.appAlias ?? "") < (rhs.appAlias ?? "")
      }
      if lhs.bundleId != rhs.bundleId {
        return (lhs.bundleId ?? "") < (rhs.bundleId ?? "")
      }
      if lhs.path != rhs.path {
        return lhs.path.lexicographicallyPrecedes(rhs.path)
      }
      if lhs.stateId != rhs.stateId {
        return lhs.stateId < rhs.stateId
      }
      if lhs.actionType != rhs.actionType {
        return lhs.actionType < rhs.actionType
      }
      if lhs.actionTypeRaw != rhs.actionTypeRaw {
        return (lhs.actionTypeRaw ?? "") < (rhs.actionTypeRaw ?? "")
      }
      if lhs.actionValue != rhs.actionValue {
        return (lhs.actionValue ?? "") < (rhs.actionValue ?? "")
      }
      return (lhs.actionLabel ?? "") < (rhs.actionLabel ?? "")
    }
  }

  private static func buildAppAliases(
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) -> [AppAliasConfig] {
    var appAliases: [AppAliasConfig] = []
    var usedAliases = Set<String>()

    for (bundleId, config, customName) in appConfigs {
      if bundleId.contains(".meta") {
        continue
      }

      var alias = generateAppAlias(from: bundleId, customName: customName)
      let baseAlias = alias
      var counter = 1
      while usedAliases.contains(alias) {
        alias = "\(baseAlias)_\(counter)"
        counter += 1
      }
      usedAliases.insert(alias)
      appAliases.append(
        AppAliasConfig(bundleId: bundleId, alias: alias, customName: customName, config: config))
    }

    appAliases.sort { lhs, rhs in
      if lhs.bundleId.count != rhs.bundleId.count {
        return lhs.bundleId.count > rhs.bundleId.count
      }
      if lhs.bundleId != rhs.bundleId {
        return lhs.bundleId < rhs.bundleId
      }
      return lhs.alias < rhs.alias
    }

    return appAliases
  }

  private static func stateIdNamespace(for scope: StateMapping.Scope, bundleId: String?) -> String {
    switch scope {
    case .global:
      return "global"
    case .appShared:
      return "app_shared"
    case .appOverride:
      return "app_override.\(bundleId ?? "unknown")"
    case .appSuppress:
      return "app_suppress.\(bundleId ?? "unknown")"
    case .fallbackOnly:
      return "fallback_only"
    }
  }

  private static let actionSignatureEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }()

  private static func actionSignature(for action: Action) -> String {
    if let data = try? actionSignatureEncoder.encode(action), let string = String(data: data, encoding: .utf8) {
      return string
    }

    return "\(action.type.rawValue)|\(action.label ?? "")|\(action.value)|\(action.stickyMode == true)"
  }

  private static func groupSignature(for group: Group) -> String {
    "\(group.label ?? "")|\(group.iconPath ?? "")|\(group.stickyMode == true)"
  }

  private static func groupMetadataMatches(_ lhs: Group, _ rhs: Group) -> Bool {
    lhs.key == rhs.key
      && lhs.label == rhs.label
      && lhs.iconPath == rhs.iconPath
      && lhs.stickyMode == rhs.stickyMode
  }

  private static func isSuppressionAction(_ action: Action) -> Bool {
    action.type == .shortcut && action.value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "vk_none"
  }

  private static func keyedItems(_ items: [ActionOrGroup]) -> [String: ActionOrGroup] {
    var keyed: [String: ActionOrGroup] = [:]

    for item in items {
      guard let key = item.item.key else { continue }
      let normalizedKey = normalizeKeyForPath(key)
      guard !normalizedKey.isEmpty else { continue }
      if keyed[normalizedKey] == nil {
        keyed[normalizedKey] = item
      }
    }

    return keyed
  }

  private static func makeStateMapping(
    stateId: Int32,
    path: [String],
    scope: StateMapping.Scope,
    appAlias: String?,
    bundleId: String?,
    actionType: String,
    actionTypeRaw: String?,
    actionValue: String?,
    actionLabel: String?
  ) -> StateMapping {
    StateMapping(
      stateId: stateId,
      path: path,
      scope: scope,
      appAlias: appAlias,
      bundleId: bundleId,
      actionType: actionType,
      actionTypeRaw: actionTypeRaw,
      actionValue: actionValue,
      actionLabel: actionLabel
    )
  }

  private static func appendFullBinding(
    item: ActionOrGroup,
    scope: StateMapping.Scope,
    appAlias: String?,
    bundleId: String?,
    parentStateId: Int32,
    parentPath: [String],
    originalParentPath: [String],
    parentGroupHasStickyMode: Bool,
    registry: StateIdRegistry,
    collections: inout ManagedBindingCollections
  ) throws {
    guard let originalKey = item.item.key, !originalKey.isEmpty else {
      return
    }

    let normalizedKey = normalizeKeyForPath(originalKey)
    guard !normalizedKey.isEmpty else {
      return
    }

    let path = parentPath + [normalizedKey]
    let originalPath = originalParentPath + [originalKey]
    let namespace = stateIdNamespace(for: scope, bundleId: bundleId)

    switch item {
    case .action(let action):
      if isSuppressionAction(action) {
        collections.bindings.append(
          ManagedBinding(
            parentStateId: parentStateId,
            stateId: nil,
            path: path,
            originalPath: originalPath,
            item: item,
            kind: .suppress,
            parentGroupHasStickyMode: parentGroupHasStickyMode,
            scope: .appSuppress,
            appAlias: appAlias,
            bundleId: bundleId
          ))
        return
      }

      let terminalStateId = try registry.makeStateId(
        namespace: namespace,
        path: path,
        kind: "action.\(actionSignature(for: action))",
        scope: scope,
        bundleId: bundleId
      )
      collections.bindings.append(
        ManagedBinding(
          parentStateId: parentStateId,
          stateId: terminalStateId,
          path: path,
          originalPath: originalPath,
          item: item,
          kind: .action,
          parentGroupHasStickyMode: parentGroupHasStickyMode,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId
        ))
      collections.stateMappings.append(
        makeStateMapping(
          stateId: terminalStateId,
          path: originalPath,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId,
          actionType: "action",
          actionTypeRaw: action.type.rawValue,
          actionValue: action.value,
          actionLabel: action.label
        ))

    case .group(let group):
      let groupStateId = try registry.makeStateId(
        namespace: namespace,
        path: path,
        kind: "group.\(groupSignature(for: group))",
        scope: scope,
        bundleId: bundleId
      )
      collections.bindings.append(
        ManagedBinding(
          parentStateId: parentStateId,
          stateId: groupStateId,
          path: path,
          originalPath: originalPath,
          item: item,
          kind: .group,
          parentGroupHasStickyMode: parentGroupHasStickyMode,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId
        ))
      collections.stateMappings.append(
        makeStateMapping(
          stateId: groupStateId,
          path: originalPath,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId,
          actionType: "group",
          actionTypeRaw: nil,
          actionValue: nil,
          actionLabel: group.label
        ))

      for child in group.actions {
        try appendFullBinding(
          item: child,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId,
          parentStateId: groupStateId,
          parentPath: path,
          originalParentPath: originalPath,
          parentGroupHasStickyMode: group.stickyMode ?? false,
          registry: registry,
          collections: &collections
        )
      }
    }
  }

  private static func collectFullBindings(
    from group: Group,
    scope: StateMapping.Scope,
    appAlias: String?,
    bundleId: String?,
    rootStateId: Int32,
    registry: StateIdRegistry
  ) throws -> ManagedBindingCollections {
    var collections = ManagedBindingCollections()
    let rootStickyMode = group.stickyMode ?? false

    for item in group.actions {
      try appendFullBinding(
        item: item,
        scope: scope,
        appAlias: appAlias,
        bundleId: bundleId,
        parentStateId: rootStateId,
        parentPath: [],
        originalParentPath: [],
        parentGroupHasStickyMode: rootStickyMode,
        registry: registry,
        collections: &collections
      )
    }

    return collections
  }

  private static func collectAppDeltaBindings(
    appGroup: Group,
    fallbackGroup: Group,
    appAlias: String,
    bundleId: String,
    parentStateId: Int32,
    parentPath: [String],
    originalParentPath: [String],
    registry: StateIdRegistry,
    collections: inout ManagedBindingCollections
  ) throws {
    let appItems = keyedItems(appGroup.actions)
    let fallbackItems = keyedItems(fallbackGroup.actions)
    let orderedKeys = Array(Set(appItems.keys).union(fallbackItems.keys)).sorted()

    for normalizedKey in orderedKeys {
      let appItem = appItems[normalizedKey]
      let fallbackItem = fallbackItems[normalizedKey]

      switch (appItem, fallbackItem) {
      case let (.some(.group(appSubgroup)), .some(.group(fallbackSubgroup))):
        let originalKey = appSubgroup.key ?? fallbackSubgroup.key ?? normalizedKey
        let path = parentPath + [normalizedKey]
        let originalPath = originalParentPath + [originalKey]

        if groupMetadataMatches(appSubgroup, fallbackSubgroup) {
          let sharedStateId = try registry.makeStateId(
            namespace: stateIdNamespace(for: .appShared, bundleId: nil),
            path: path,
            kind: "group.\(groupSignature(for: fallbackSubgroup))",
            scope: .appShared,
            bundleId: nil
          )
          try collectAppDeltaBindings(
            appGroup: appSubgroup,
            fallbackGroup: fallbackSubgroup,
            appAlias: appAlias,
            bundleId: bundleId,
            parentStateId: sharedStateId,
            parentPath: path,
            originalParentPath: originalPath,
            registry: registry,
            collections: &collections
          )
        } else {
          try appendFullBinding(
            item: .group(appSubgroup),
            scope: .appOverride,
            appAlias: appAlias,
            bundleId: bundleId,
            parentStateId: parentStateId,
            parentPath: parentPath,
            originalParentPath: originalParentPath,
            parentGroupHasStickyMode: appGroup.stickyMode ?? false,
            registry: registry,
            collections: &collections
          )
        }

      case let (.some(.action(appAction)), .some(.action(fallbackAction))):
        if isSuppressionAction(appAction) {
          try appendFullBinding(
            item: .action(appAction),
            scope: .appSuppress,
            appAlias: appAlias,
            bundleId: bundleId,
            parentStateId: parentStateId,
            parentPath: parentPath,
            originalParentPath: originalParentPath,
            parentGroupHasStickyMode: appGroup.stickyMode ?? false,
            registry: registry,
            collections: &collections
          )
        } else if appAction != fallbackAction {
          try appendFullBinding(
            item: .action(appAction),
            scope: .appOverride,
            appAlias: appAlias,
            bundleId: bundleId,
            parentStateId: parentStateId,
            parentPath: parentPath,
            originalParentPath: originalParentPath,
            parentGroupHasStickyMode: appGroup.stickyMode ?? false,
            registry: registry,
            collections: &collections
          )
        }

      case let (.some(item), .none):
        let scope: StateMapping.Scope
        if case .action(let action) = item, isSuppressionAction(action) {
          scope = .appSuppress
        } else {
          scope = .appOverride
        }
        try appendFullBinding(
          item: item,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId,
          parentStateId: parentStateId,
          parentPath: parentPath,
          originalParentPath: originalParentPath,
          parentGroupHasStickyMode: appGroup.stickyMode ?? false,
          registry: registry,
          collections: &collections
        )

      case let (.some(item), .some(_)):
        let scope: StateMapping.Scope
        if case .action(let action) = item, isSuppressionAction(action) {
          scope = .appSuppress
        } else {
          scope = .appOverride
        }
        try appendFullBinding(
          item: item,
          scope: scope,
          appAlias: appAlias,
          bundleId: bundleId,
          parentStateId: parentStateId,
          parentPath: parentPath,
          originalParentPath: originalParentPath,
          parentGroupHasStickyMode: appGroup.stickyMode ?? false,
          registry: registry,
          collections: &collections
        )

      case (.none, _):
        continue
      }
    }
  }

  private static func karIntermediateMappings(
    from bindings: [ManagedBinding]
  ) -> [[String: Any]] {
    bindings.sorted {
      if $0.parentStateId != $1.parentStateId {
        return $0.parentStateId < $1.parentStateId
      }
      if $0.path != $1.path {
        return $0.path.lexicographicallyPrecedes($1.path)
      }
      return ($0.originalPath.last ?? "") < ($1.originalPath.last ?? "")
    }.flatMap { binding -> [[String: Any]] in
      guard let key = binding.item.item.key else {
        return []
      }

      let mapping: [String: Any]?
      switch binding.kind {
      case .group:
        guard let stateId = binding.stateId else { return [] }
        let groupStickyMode: Bool
        if case .group(let group) = binding.item {
          groupStickyMode = group.stickyMode ?? false
        } else {
          groupStickyMode = false
        }
        mapping = generateKarStateTransitionMapping(
          key: key,
          toState: stateId,
          hasStickyMode: groupStickyMode
        )

      case .action:
        guard let stateId = binding.stateId else { return [] }
        let node = StateNode(
          path: binding.path,
          originalPath: binding.originalPath,
          stateId: stateId,
          item: binding.item,
          isTerminal: true,
          parentGroupHasStickyMode: binding.parentGroupHasStickyMode
        )
        let staticStickyMode = terminalActionHasStickyMode(for: node)
        if !staticStickyMode {
          guard
            var stickyMapping = generateKarTerminalActionMapping(
              key: key,
              toState: stateId,
              hasStickyMode: true,
              node: node
            ),
            var nonStickyMapping = generateKarTerminalActionMapping(
              key: key,
              toState: stateId,
              hasStickyMode: false,
              node: node
            )
          else {
            return []
          }

          stickyMapping["condition"] = [
            variableCondition(name: "leader_state", value: binding.parentStateId),
            variableCondition(name: "leaderkey_sticky", value: 1),
          ]
          nonStickyMapping["condition"] = [
            variableCondition(name: "leader_state", value: binding.parentStateId),
            variableUnlessCondition(name: "leaderkey_sticky", value: 1),
          ]

          return [stickyMapping, nonStickyMapping]
        }

        mapping = generateKarTerminalActionMapping(
          key: key,
          toState: stateId,
          hasStickyMode: true,
          node: node
        )

      case .suppress:
        guard let (keyCode, modifiers) = parseKarKeySpec(key) else {
          return []
        }
        mapping = [
          "from": karFrom(keyCode: keyCode, modifiers: modifiers),
          "to": ["vk_none"]
        ]
      }

      guard var conditioned = mapping else {
        return []
      }
      conditioned["condition"] = [variableCondition(name: "leader_state", value: binding.parentStateId)]
      return [conditioned]
    }
  }

  private static func universalKarCatchAllMapping() -> [String: Any] {
    [
      "from": [
        "any": "key_code",
        "modifiers": "any"
      ],
      "to": [
        karSendUserCommand("shake"),
        "vk_none"
      ],
      "condition": [
        variableUnlessCondition(name: "leader_state", value: 0),
        variableUnlessCondition(name: "leaderkey_sticky", value: 1),
      ]
    ]
  }

  private static func buildManagedExportModel(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) throws -> ManagedExportModel {
    let appAliases = buildAppAliases(appConfigs: appConfigs)
    let registry = StateIdRegistry()

    try registry.reserve(
      globalInitialStateId,
      identity: StateIdentity(
        namespace: "global",
        path: [],
        kind: "root",
        scope: .global,
        bundleId: nil
      ))
    try registry.reserve(
      fallbackInitialStateId,
      identity: StateIdentity(
        namespace: "app_shared",
        path: [],
        kind: "root",
        scope: .appShared,
        bundleId: nil
      ))

    var rules: [[String: Any]] = []
    var stateMappings: [StateMapping] = []

    var activationMappings: [[String: Any]] = []
    for aliasConfig in appAliases {
      if let kinesisActivation = generateKarActivationMapping(
        keyCode: "keypad_4",
        modifiers: ["left_command", "left_option", "left_control", "left_shift"],
        initialStateId: fallbackInitialStateId,
        bundleId: aliasConfig.bundleId,
        isAppSpecificMode: true,
        additionalConditions: [
          ["app": aliasConfig.bundleId],
          kinesisDeviceCondition(),
        ]
      ) {
        activationMappings.append(kinesisActivation)
      }

      if let builtInActivation = generateKarActivationMapping(
        keyCode: "semicolon",
        modifiers: [],
        initialStateId: fallbackInitialStateId,
        bundleId: aliasConfig.bundleId,
        isAppSpecificMode: true,
        additionalConditions: builtInActivationConditions(appBundleId: aliasConfig.bundleId)
      ) {
        activationMappings.append(builtInActivation)
      }
    }

    if let kinesisGlobalActivation = generateKarActivationMapping(
      keyCode: "keypad_7",
      modifiers: ["left_command", "left_option", "left_control", "left_shift"],
      initialStateId: globalInitialStateId,
      bundleId: nil,
      isAppSpecificMode: false,
      additionalConditions: [kinesisDeviceCondition()]
    ) {
      activationMappings.append(kinesisGlobalActivation)
    }

    if let builtInGlobalActivation = generateKarActivationMapping(
      keyCode: "right_command",
      modifiers: [],
      initialStateId: globalInitialStateId,
      bundleId: nil,
      isAppSpecificMode: false,
      additionalConditions: builtInActivationConditions()
    ) {
      activationMappings.append(builtInGlobalActivation)
    }

    if let kinesisFallbackActivation = generateKarActivationMapping(
      keyCode: "keypad_4",
      modifiers: ["left_command", "left_option", "left_control", "left_shift"],
      initialStateId: fallbackInitialStateId,
      bundleId: "__FALLBACK__",
      isAppSpecificMode: true,
      additionalConditions: [kinesisDeviceCondition()]
    ) {
      activationMappings.append(kinesisFallbackActivation)
    }

    if let builtInFallbackActivation = generateKarActivationMapping(
      keyCode: "semicolon",
      modifiers: [],
      initialStateId: fallbackInitialStateId,
      bundleId: "__FALLBACK__",
      isAppSpecificMode: true,
      additionalConditions: builtInActivationConditions()
    ) {
      activationMappings.append(builtInFallbackActivation)
    }

    if let escapeMapping = generateKarEscapeMapping() {
      activationMappings.append(escapeMapping)
    }
    if let settingsMapping = generateKarSettingsMapping() {
      activationMappings.append(settingsMapping)
    }

    rules.append(
      makeKarRule(
        description: "\(managedRuleDescriptionPrefix)ActivationShortcuts",
        mappings: activationMappings))

    rules.append(
      makeKarRule(
        description: "\(managedRuleDescriptionPrefix)ModifierPassThrough",
        mappings: generateKarModifierPassThroughMappings()))

    let globalCollections = try collectFullBindings(
      from: globalConfig.root,
      scope: .global,
      appAlias: nil,
      bundleId: nil,
      rootStateId: globalInitialStateId,
      registry: registry
    )
    stateMappings.append(contentsOf: globalCollections.stateMappings)
    let globalMappings = karIntermediateMappings(from: globalCollections.bindings)

    let fallbackRoot = globalConfig.getFallbackConfig()
    let sharedCollections = try collectFullBindings(
      from: fallbackRoot,
      scope: .appShared,
      appAlias: nil,
      bundleId: nil,
      rootStateId: fallbackInitialStateId,
      registry: registry
    )
    stateMappings.append(contentsOf: sharedCollections.stateMappings)
    let sharedMappings = karIntermediateMappings(from: sharedCollections.bindings)

    var appBindingsByAlias: [String: [ManagedBinding]] = [:]
    for aliasConfig in appAliases {
      var deltaCollections = ManagedBindingCollections()
      try collectAppDeltaBindings(
        appGroup: aliasConfig.config.root,
        fallbackGroup: fallbackRoot,
        appAlias: aliasConfig.alias,
        bundleId: aliasConfig.bundleId,
        parentStateId: fallbackInitialStateId,
        parentPath: [],
        originalParentPath: [],
        registry: registry,
        collections: &deltaCollections
      )

      appBindingsByAlias[aliasConfig.alias] = deltaCollections.bindings
      stateMappings.append(contentsOf: deltaCollections.stateMappings)

      let appMappings = karIntermediateMappings(from: deltaCollections.bindings)
      if !appMappings.isEmpty {
        rules.append(
          makeKarRule(
            description: "\(managedRuleDescriptionPrefix)AppMode/\(aliasConfig.alias)",
            mappings: appMappings,
            condition: [["app": aliasConfig.bundleId]]
          ))
      }
    }

    if !sharedMappings.isEmpty {
      rules.append(
        makeKarRule(
          description: "\(managedRuleDescriptionPrefix)FallbackMode",
          mappings: sharedMappings))
    }

    if !globalMappings.isEmpty {
      rules.append(
        makeKarRule(
          description: "\(managedRuleDescriptionPrefix)GlobalMode",
          mappings: globalMappings))
    }

    rules.append(
      makeKarRule(
        description: "\(managedRuleDescriptionPrefix)CatchAll",
        mappings: [universalKarCatchAllMapping()]))

    return ManagedExportModel(
      appAliases: appAliases,
      rules: rules,
      stateMappings: stateMappings,
      globalBindings: globalCollections.bindings,
      sharedAppBindings: sharedCollections.bindings,
      appBindingsByAlias: appBindingsByAlias
    )
  }

  private static func parseKarKeySpec(_ key: String) -> (keyCode: String, modifiers: [String])? {
    guard !key.isEmpty else { return nil }

    var modifiers: [String] = []
    var baseKey = key

    if key.count > 1 {
      let prefixes = key.prefix(while: { "CSOTF".contains($0) })
      if !prefixes.isEmpty {
        for char in prefixes {
          switch char {
          case "C":
            modifiers.append("command")
          case "S":
            modifiers.append("shift")
          case "O":
            modifiers.append("option")
          case "T":
            modifiers.append("control")
          case "F":
            modifiers.append("fn")
          default:
            break
          }
        }
        baseKey = String(key.dropFirst(prefixes.count))
      }
    }

    if baseKey.count == 1, let char = baseKey.first, char.isUppercase {
      if !modifiers.contains("shift") {
        modifiers.append("shift")
      }
      baseKey = baseKey.lowercased()
    }

    let shiftedKeyMap: [String: String] = [
      "!": "1",
      "@": "2",
      "#": "3",
      "$": "4",
      "%": "5",
      "^": "6",
      "&": "7",
      "*": "8",
      "(": "9",
      ")": "0",
      "_": "hyphen",
      "+": "equal_sign",
      "{": "open_bracket",
      "}": "close_bracket",
      "\"": "quote",
      "~": "grave_accent_and_tilde",
      "|": "backslash",
      "?": "slash",
      ":": "semicolon",
    ]

    if let shiftedKey = shiftedKeyMap[baseKey] {
      if !modifiers.contains("shift") {
        modifiers.append("shift")
      }
      baseKey = shiftedKey
    }

    let keyMap: [String: String] = [
      " ": "spacebar",
      "space": "spacebar",
      "spacebar": "spacebar",
      "return": "return_or_enter",
      "enter": "return_or_enter",
      "tab": "tab",
      "delete": "delete_or_backspace",
      "backspace": "delete_or_backspace",
      ".": "period",
      ",": "comma",
      ";": "semicolon",
      "/": "slash",
      "-": "hyphen",
      "=": "equal_sign",
      "[": "open_bracket",
      "]": "close_bracket",
      "'": "quote",
      "`": "grave_accent_and_tilde",
      "\\": "backslash",
      "↑": "up_arrow",
      "↓": "down_arrow",
      "←": "left_arrow",
      "→": "right_arrow",
      "up": "up_arrow",
      "down": "down_arrow",
      "left": "left_arrow",
      "right": "right_arrow",
      "escape": "escape",
      "esc": "escape",
    ]

    let keyCode = keyMap[baseKey.lowercased()] ?? baseKey.lowercased()
    return (keyCode: keyCode, modifiers: modifiers)
  }
  
  // Generate simple app alias from bundle ID or custom name
  private static func generateAppAlias(from bundleId: String, customName: String? = nil) -> String {
    // If we have a custom name from meta file, use it
    if let customName = customName, !customName.isEmpty {
      // Convert custom name to valid Goku alias:
      // - Lowercase
      // - Replace spaces and special chars with underscores
      // - Remove consecutive underscores
      let cleaned = customName
        .lowercased()
        .replacingOccurrences(of: " ", with: "_")
        .replacingOccurrences(of: "-", with: "_")
        .replacingOccurrences(of: ".", with: "_")
        .replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .replacingOccurrences(of: "[", with: "")
        .replacingOccurrences(of: "]", with: "")
        .replacingOccurrences(of: "{", with: "")
        .replacingOccurrences(of: "}", with: "")
        .replacingOccurrences(of: "&", with: "and")
        .replacingOccurrences(of: "+", with: "plus")
        .replacingOccurrences(of: "@", with: "at")
        .replacingOccurrences(of: "#", with: "")
        .replacingOccurrences(of: "%", with: "")
        .replacingOccurrences(of: "^", with: "")
        .replacingOccurrences(of: "*", with: "")
        .replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of: "|", with: "")
        .replacingOccurrences(of: "\\", with: "")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: ":", with: "")
        .replacingOccurrences(of: ";", with: "")
        .replacingOccurrences(of: "\"", with: "")
        .replacingOccurrences(of: "'", with: "")
        .replacingOccurrences(of: "<", with: "")
        .replacingOccurrences(of: ">", with: "")
        .replacingOccurrences(of: ",", with: "")
        .replacingOccurrences(of: "?", with: "")
        .replacingOccurrences(of: "!", with: "")
        .replacingOccurrences(of: "`", with: "")
        .replacingOccurrences(of: "~", with: "")
      
      // Remove consecutive underscores and trim
      let normalized = cleaned
        .split(separator: "_")
        .filter { !$0.isEmpty }
        .joined(separator: "_")
      
      return normalized.isEmpty ? bundleId.replacingOccurrences(of: ".", with: "_").lowercased() : normalized
    }
    
    // Fallback to hardcoded mappings for known apps without custom names
    let knownApps: [String: String] = [
      "com.microsoft.VSCode": "vscode",
      "com.apple.Terminal": "terminal",
      "com.apple.dt.Xcode": "xcode",
      "com.apple.finder": "finder",
      "com.google.Chrome": "chrome",
      "company.thebrowser.Browser": "arc",
      "company.thebrowser.dia": "dia",
      "com.jetbrains.intellij": "intellij",
      "dev.warp.Warp-Stable": "warp",
      "com.todesktop.230313mzl4w4u92": "cursor",
      "com.cocoatech.PathFinder": "pathfinder",
      "dev.zed.Zed": "zed",
      "com.raycast.macos": "raycast",
      "com.tinyspeck.slackmacgap": "slack",
      "org.videolan.vlc": "vlc",
      "com.apple.iCal": "calendar",
      "ai.perplexity.comet": "perplexity",
      "com.bitwarden.desktop": "bitwarden",
      "dev.kiro.desktop": "kiro"
    ]
    
    if let known = knownApps[bundleId] {
      return known
    }
    
    // For Chrome/Edge PWAs with long IDs
    if bundleId.contains("com.google.Chrome.app.") {
      return "chrome_app_" + bundleId.suffix(6).lowercased()
    }
    if bundleId.contains("com.google.Chrome.dev.app.") {
      return "chrome_dev_" + bundleId.suffix(6).lowercased()
    }
    if bundleId.contains("com.microsoft.edgemac.app.") {
      return "edge_app_" + bundleId.suffix(6).lowercased()
    }
    
    // Generic approach: take last meaningful component
    let components = bundleId.split(separator: ".")
    if components.count >= 3 {
      let lastComponent = String(components.last ?? "app")
      // Truncate very long components
      if lastComponent.count > 15 {
        return String(lastComponent.prefix(15)).lowercased()
      }
      return lastComponent.lowercased()
    }
    
    // Fallback: replace dots with underscores
    return bundleId.replacingOccurrences(of: ".", with: "_")
      .prefix(20)
      .lowercased()
  }
  
  // Generate :applications section for Goku with pre-computed unique aliases
  private static func generateApplicationsSectionFromAliases(appAliases: [(bundleId: String, alias: String, config: UserConfig)]) -> String {
    guard !appAliases.isEmpty else { return "" }
    
    var appLines: [String] = []
    for (bundleId, alias, _) in appAliases {
      appLines.append("   :\(alias) [\"\(bundleId)\"]")
    }
    
    return " :applications {\n\(appLines.joined(separator: "\n"))\n }"
  }
  
  private static func normalizeKeyForPath(_ key: String?) -> String {
    guard let key = key, !key.isEmpty else { return "" }

    // Special handling for space key
    if key == " " {
      return "space"
    }

    // Return the key as-is (preserves uppercase, modifiers, etc.)
    return key
  }

  /// Builds a shell command invocation respecting user's shell configuration settings
  private static func buildShellInvocation(_ command: String) -> String {
    // Get shell preference and path
    let shellPreference = Defaults[.commandShellPreference]
    var shellPath = shellPreference.path

    // Validate custom shell path if using custom shell
    if shellPreference == .custom {
      let customPath = Defaults[.customShellPath]
      if !customPath.isEmpty && ShellPreference.isValidShellPath(customPath) {
        shellPath = customPath
      } else {
        // Fall back to system shell
        shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
      }
    }

    // Check if we should load shell RC files
    let loadRCFiles = Defaults[.loadShellRCFiles]

    // Escape single quotes in the command for shell execution
    let escapedCommand = command.replacingOccurrences(of: "'", with: "'\\''")

    // Build the shell invocation
    let shellCommand: String
    if loadRCFiles {
      // Use login shell (-l) to load RC files (.zshrc, .bashrc, etc.)
      shellCommand = "\(shellPath) -l -c '\(escapedCommand)'"
    } else {
      // Don't load RC files, just execute
      shellCommand = "\(shellPath) -c '\(escapedCommand)'"
    }

    return shellCommand
  }

  // Helper to determine if an action should be executed in background (open -g)
  private static func shouldUseBackgroundExecution(for action: Action) -> Bool {
    // If explicitly set, respect the setting
    // Note: activates = true means foreground, activates = false means background
    if let activates = action.activates {
      return !activates
    }
    
    // Default behavior if not explicitly set
    switch action.type {
    case .url:
      // For URLs, default depends on scheme
      // http/https -> Foreground (activates=true) -> Background=false
      // custom schemes -> Background (activates=false) -> Background=true
      if let url = URL(string: action.value), let scheme = url.scheme {
        return !(scheme == "http" || scheme == "https")
      }
      return true // Default to background for invalid/no scheme
      
    case .application, .folder:
      // For Apps and Folders, default is Foreground (activates=true) -> Background=false
      return false
      
    default:
      return false
    }
  }
  

  
  private static func formatManagedGokuEDN(
    applications: String,
    managedRules: [[String: Any]],
    appAliases: [AppAliasConfig]
  ) -> String {
    let sections = managedRules.compactMap { rule -> String? in
      guard let description = rule["description"] as? String else {
        return nil
      }
      let manipulators = rule["manipulators"] as? [[String: Any]] ?? []
      guard !manipulators.isEmpty else {
        return nil
      }

      let sectionName = gokuSectionName(forManagedRuleDescription: description, appAliases: appAliases)
      let manipulatorLines = manipulators.map { "    " + gokuRawEDN(for: $0) }
      var section = "  {:des \"\(sectionName)\"\n"
      section += "   :rules [\n"
      section += manipulatorLines.joined(separator: "\n")
      section += "\n   ]}"
      return section
    }

    var edn = ";; Leader Key 2.0 Configuration with Shared Managed Export\n"
    edn += ";; Generated by Leader Key\n\n"
    edn += "{\n"

    if !applications.isEmpty {
      edn += applications
      edn += "\n"
    }

    edn += " :input-sources {\n"
    edn += "   :leaderkey {:input_source_id \"^com.apple.keylayout.US$\"}\n"
    edn += " }\n\n"
    edn += " :main [\n"
    edn += sections.joined(separator: "\n\n")
    edn += "\n ]\n"
    edn += "}"

    return edn
  }

  private static func gokuSectionName(
    forManagedRuleDescription description: String,
    appAliases: [AppAliasConfig]
  ) -> String {
    let suffix = description.replacingOccurrences(of: managedRuleDescriptionPrefix, with: "")

    switch suffix {
    case "ActivationShortcuts":
      return "Leader Key - Activation Shortcuts"
    case "ModifierPassThrough":
      return "Leader Key - Modifier Pass-Through"
    case "GlobalMode":
      return "Leader Key - Global Mode"
    case "FallbackMode":
      return "Leader Key - Fallback Mode"
    case "CatchAll":
      return "Leader Key - Catch All"
    default:
      break
    }

    if suffix.hasPrefix("AppMode/") {
      let alias = String(suffix.dropFirst("AppMode/".count))
      if let appAlias = appAliases.first(where: { $0.alias == alias }) {
        return "Leader Key - \(appAlias.customName ?? appAlias.alias)"
      }
      return "Leader Key - \(alias)"
    }

    return description
  }

  private static func gokuRawEDN(for value: Any, keyContext: String? = nil) -> String {
    if let dictionary = value as? [String: Any] {
      return gokuRawEDNMap(dictionary)
    }

    if let array = value as? [Any] {
      return "[\(array.map { gokuRawEDN(for: $0) }.joined(separator: " "))]"
    }

    if let stringValue = value as? String {
      if keyContext == "type" {
        return ":\(stringValue)"
      }
      return ednStringLiteral(stringValue)
    }

    if let number = value as? NSNumber {
      if CFGetTypeID(number) == CFBooleanGetTypeID() {
        return number.boolValue ? "true" : "false"
      }
      return number.stringValue
    }

    if let boolValue = value as? Bool {
      return boolValue ? "true" : "false"
    }

    return ednStringLiteral(String(describing: value))
  }

  private static func gokuRawEDNMap(_ dictionary: [String: Any]) -> String {
    let preferredOrder = [
      "type", "from", "to", "to_if_alone", "to_if_held_down", "to_after_key_up", "conditions",
      "parameters", "key_code", "any", "modifiers", "mandatory", "optional", "set_variable",
      "name", "value", "send_user_command", "payload", "endpoint", "shell_command",
      "bundle_identifiers", "identifiers", "vendor_id", "product_id",
    ]
    let orderedKeys = dictionary.keys.sorted { lhs, rhs in
      let lhsIndex = preferredOrder.firstIndex(of: lhs) ?? Int.max
      let rhsIndex = preferredOrder.firstIndex(of: rhs) ?? Int.max
      if lhsIndex != rhsIndex {
        return lhsIndex < rhsIndex
      }
      return lhs < rhs
    }

    let items = orderedKeys.map { key in
      ":\(key) \(gokuRawEDN(for: dictionary[key]!, keyContext: key))"
    }
    return "{\(items.joined(separator: " "))}"
  }
  
  // MARK: - EDN Injection into Main Karabiner Config
  
  enum InjectionResult {
    case success
    case noMarkersFound
    case partialMarkersFound(missing: [String])
    case fileNotFound
    case error(String)
  }

  static func shouldPreserveActivationShortcuts(in content: String) -> Bool {
    guard let activationSection = extractActivationSection(from: content) else {
      return false
    }

    return !containsLegacyLeaderModeVariable(in: activationSection)
  }

  private static func containsLegacyLeaderModeVariable(in content: String) -> Bool {
    [
      "leaderkey_active",
      "leaderkey_global",
      "leaderkey_appspecific",
      "leaderkey_mode",
    ].contains { content.contains($0) }
  }

  private static func canonicalActivationManagedRule(
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) -> [String: Any] {
    let appAliases = buildAppAliases(appConfigs: appConfigs)
    var activationMappings: [[String: Any]] = []

    for aliasConfig in appAliases {
      if let kinesisActivation = generateKarActivationMapping(
        keyCode: "keypad_4",
        modifiers: ["left_command", "left_option", "left_control", "left_shift"],
        initialStateId: fallbackInitialStateId,
        bundleId: aliasConfig.bundleId,
        isAppSpecificMode: true,
        additionalConditions: [
          ["app": aliasConfig.bundleId],
          kinesisDeviceCondition(),
        ]
      ) {
        activationMappings.append(kinesisActivation)
      }

      if let builtInActivation = generateKarActivationMapping(
        keyCode: "semicolon",
        modifiers: [],
        initialStateId: fallbackInitialStateId,
        bundleId: aliasConfig.bundleId,
        isAppSpecificMode: true,
        additionalConditions: builtInActivationConditions(appBundleId: aliasConfig.bundleId)
      ) {
        activationMappings.append(builtInActivation)
      }
    }

    if let kinesisGlobalActivation = generateKarActivationMapping(
      keyCode: "keypad_7",
      modifiers: ["left_command", "left_option", "left_control", "left_shift"],
      initialStateId: globalInitialStateId,
      bundleId: nil,
      isAppSpecificMode: false,
      additionalConditions: [kinesisDeviceCondition()]
    ) {
      activationMappings.append(kinesisGlobalActivation)
    }

    if let builtInGlobalActivation = generateKarActivationMapping(
      keyCode: "right_command",
      modifiers: [],
      initialStateId: globalInitialStateId,
      bundleId: nil,
      isAppSpecificMode: false,
      additionalConditions: builtInActivationConditions()
    ) {
      activationMappings.append(builtInGlobalActivation)
    }

    if let kinesisFallbackActivation = generateKarActivationMapping(
      keyCode: "keypad_4",
      modifiers: ["left_command", "left_option", "left_control", "left_shift"],
      initialStateId: fallbackInitialStateId,
      bundleId: "__FALLBACK__",
      isAppSpecificMode: true,
      additionalConditions: [kinesisDeviceCondition()]
    ) {
      activationMappings.append(kinesisFallbackActivation)
    }

    if let builtInFallbackActivation = generateKarActivationMapping(
      keyCode: "semicolon",
      modifiers: [],
      initialStateId: fallbackInitialStateId,
      bundleId: "__FALLBACK__",
      isAppSpecificMode: true,
      additionalConditions: builtInActivationConditions()
    ) {
      activationMappings.append(builtInFallbackActivation)
    }

    if let escapeMapping = generateKarEscapeMapping() {
      activationMappings.append(escapeMapping)
    }
    if let settingsMapping = generateKarSettingsMapping() {
      activationMappings.append(settingsMapping)
    }

    return makeKarRule(
      description: "\(managedRuleDescriptionPrefix)ActivationShortcuts",
      mappings: activationMappings
    )
  }

  static func generateCanonicalSpecificConfigRules(
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) -> String {
    let activationRule = canonicalActivationManagedRule(appConfigs: appConfigs)
    let compiledRule = compileKarIntermediateRule(activationRule)
    let manipulators = compiledRule?["manipulators"] as? [[String: Any]] ?? []

    return manipulators
      .map { canonicalRule(gokuRawEDN(for: $0)) }
      .joined(separator: "\n")
  }
  
  static func injectIntoMainKarabinerEDN(
    applications: String,
    mainRules: [String],
    specificConfigRules: String? = nil,
    autoAddMarkers: Bool = false,
    preserveActivationShortcuts: Bool = false
  ) -> InjectionResult {
    let configPath = NSHomeDirectory() + "/.config/karabiner.edn"

    // Check if config file exists
    guard FileManager.default.fileExists(atPath: configPath) else {
      debugLog("[Karabiner2Exporter] karabiner.edn not found at \(configPath)")
      return .fileNotFound
    }
    
    // Read the file efficiently
    let content: String
    do {
      content = try String(contentsOfFile: configPath, encoding: .utf8)
    } catch {
      debugLog("[Karabiner2Exporter] Failed to read karabiner.edn: \(error)")
      return .error("Failed to read file: \(error.localizedDescription)")
    }

    let injection = injectIntoKarabinerEDNContent(
      content: content,
      applications: applications,
      mainRules: mainRules,
      specificConfigRules: specificConfigRules,
      autoAddMarkers: autoAddMarkers,
      preserveActivationShortcuts: preserveActivationShortcuts
    )

    switch injection.result {
    case .success:
      break
    default:
      return injection.result
    }

    guard let modifiedContent = injection.updatedContent else {
      return .noMarkersFound
    }
    
    // Create backup only if we're going to modify the file
    let backupPath = configPath + ".backup.\(Int(Date().timeIntervalSince1970))"
    do {
      try content.write(toFile: backupPath, atomically: true, encoding: .utf8)
      debugLog("[Karabiner2Exporter] Created backup at \(backupPath)")
    } catch {
      debugLog("[Karabiner2Exporter] Failed to create backup: \(error)")
      // Continue anyway, backup is not critical
    }

    // Rotate backups: keep only the 2 most recent
    let directory = (configPath as NSString).deletingLastPathComponent
    let baseName = (configPath as NSString).lastPathComponent
    if let files = try? FileManager.default.contentsOfDirectory(atPath: directory) {
      let backups = files.filter { $0.hasPrefix(baseName + ".backup.") }.sorted().reversed()
      for (index, file) in backups.enumerated() {
        if index >= 2 {
          try? FileManager.default.removeItem(atPath: (directory as NSString).appendingPathComponent(file))
        }
      }
    }

    do {
      try modifiedContent.write(toFile: configPath, atomically: true, encoding: .utf8)
      debugLog("[Karabiner2Exporter] Successfully updated karabiner.edn")
      return .success
    } catch {
      debugLog("[Karabiner2Exporter] Failed to write updated content: \(error)")
      return .error("Failed to write file: \(error.localizedDescription)")
    }
  }

  static func injectIntoKarabinerEDNContent(
    content: String,
    applications: String,
    mainRules: [String],
    specificConfigRules: String? = nil,
    autoAddMarkers: Bool = false,
    preserveActivationShortcuts: Bool = false
  ) -> (result: InjectionResult, updatedContent: String?) {
    let hasAppStart = content.contains(appStartMarker)
    let hasAppEnd = content.contains(appEndMarker)
    let hasMainStart = content.contains(mainStartMarker)
    let hasMainEnd = content.contains(mainEndMarker)
    let hasSpecificStart = content.contains(specificConfigsStartMarker)
    let hasSpecificEnd = content.contains(specificConfigsEndMarker)

    let hasAppMarkers = hasAppStart && hasAppEnd
    let hasMainMarkers = hasMainStart && hasMainEnd
    let hasSpecificMarkers = hasSpecificStart && hasSpecificEnd

    var missingMarkers: [String] = []
    if hasAppStart && !hasAppEnd { missingMarkers.append(appEndMarker) }
    if !hasAppStart && hasAppEnd { missingMarkers.append(appStartMarker) }
    if hasMainStart && !hasMainEnd { missingMarkers.append(mainEndMarker) }
    if !hasMainStart && hasMainEnd { missingMarkers.append(mainStartMarker) }
    if hasSpecificStart && !hasSpecificEnd { missingMarkers.append(specificConfigsEndMarker) }
    if !hasSpecificStart && hasSpecificEnd { missingMarkers.append(specificConfigsStartMarker) }

    if !missingMarkers.isEmpty {
      debugLog("[Karabiner2Exporter] Partial markers found, missing: \(missingMarkers)")
      return (.partialMarkersFound(missing: missingMarkers), nil)
    }

    if !hasAppMarkers && !hasMainMarkers && !hasSpecificMarkers {
      if autoAddMarkers {
        debugLog("[Karabiner2Exporter] No markers found, attempting to add them automatically")
        let contentWithMarkers = insertMarkersIfMissing(content: content)
        if contentWithMarkers != content {
          debugLog("[Karabiner2Exporter] Added missing markers to karabiner.edn content")
          return injectIntoKarabinerEDNContent(
            content: contentWithMarkers,
            applications: applications,
            mainRules: mainRules,
            specificConfigRules: specificConfigRules,
            autoAddMarkers: false,
            preserveActivationShortcuts: preserveActivationShortcuts
          )
        }
      }

      debugLog("[Karabiner2Exporter] No markers found in karabiner.edn content")
      return (.noMarkersFound, nil)
    }

    var modifiedContent = content
    var injectedSomething = false

    if hasAppMarkers {
      if replaceContentBetweenMarkers(
        in: &modifiedContent,
        startMarker: appStartMarker,
        endMarker: appEndMarker,
        replacementContent: applications
      ) {
        debugLog("[Karabiner2Exporter] Injected applications section")
        injectedSomething = true
      }
    }

    if hasMainMarkers,
       let mainStartRange = modifiedContent.range(of: mainStartMarker),
       let mainEndRange = modifiedContent.range(
         of: mainEndMarker,
         range: mainStartRange.upperBound..<modifiedContent.endIndex)
    {
      let replaceRange = mainStartRange.upperBound..<mainEndRange.lowerBound
      var preservedActivation: String? = nil

      if preserveActivationShortcuts {
        let existingContent = String(modifiedContent[replaceRange])
        if shouldPreserveActivationShortcuts(in: existingContent) {
          preservedActivation = extractActivationSection(from: existingContent)
        } else if extractActivationSection(from: existingContent) != nil {
          debugLog("[Karabiner2Exporter] Replacing legacy activation shortcuts from within markers")
        }
        if preservedActivation != nil {
          debugLog("[Karabiner2Exporter] Preserving existing activation shortcuts from within markers")
        }
      }

      var injectedMainParts: [String] = []
      if let preservedActivation = preservedActivation {
        injectedMainParts.append("  " + preservedActivation)
      }
      injectedMainParts.append(contentsOf: mainRules)

      let replacementIndent = lineIndentation(at: mainEndRange.lowerBound, in: modifiedContent)
      let injectedMain = "\n" + injectedMainParts.joined(separator: "\n\n") + "\n" + replacementIndent
      modifiedContent.replaceSubrange(replaceRange, with: injectedMain)
      debugLog("[Karabiner2Exporter] Injected main rules section")
      injectedSomething = true
    }

    if hasSpecificMarkers,
       replaceContentBetweenMarkers(
         in: &modifiedContent,
         startMarker: specificConfigsStartMarker,
         endMarker: specificConfigsEndMarker,
         replacementContent: specificConfigRules ?? ""
       )
    {
      debugLog("[Karabiner2Exporter] Injected specific configs activation block")
      injectedSomething = true
    }

    if injectedSomething {
      return (.success, modifiedContent)
    }

    debugLog("[Karabiner2Exporter] No injection performed")
    return (.noMarkersFound, nil)
  }
  
  // Helper method to extract sections from unified EDN for injection
  static func extractSectionsForInjection(from unifiedEDN: String, includeActivationShortcuts: Bool = true) -> (applications: String, mainRules: [String], activationShortcuts: String?) {
    var applications = ""
    var mainRules: [String] = []
    var activationShortcuts: String? = nil
    
    // Extract applications section
    if let appStart = unifiedEDN.range(of: ":applications {"),
       let appEnd = unifiedEDN.range(of: "\n }", range: appStart.upperBound..<unifiedEDN.endIndex) {
      let appContent = String(unifiedEDN[appStart.lowerBound...appEnd.upperBound])
      // Extract just the app definitions (without the :applications wrapper)
      if let innerStart = appContent.range(of: "{"),
         let innerEnd = appContent.range(of: "}", options: .backwards) {
        let innerContent = String(appContent[appContent.index(after: innerStart.lowerBound)..<innerEnd.lowerBound])
        applications = "  " + innerContent.trimmingCharacters(in: .whitespacesAndNewlines)
      }
    }
    
    // Extract main rules - get each {:des ...} block
    if let mainStart = unifiedEDN.range(of: ":main [") {
      let mainContent = String(unifiedEDN[mainStart.upperBound...])
      
      // Find all {:des blocks
      var searchRange = mainContent.startIndex..<mainContent.endIndex
      while let desStart = mainContent.range(of: "{:des", range: searchRange) {
        // Find the matching closing brace for this {:des block
        var braceCount = 0
        var foundEnd = false
        var currentIndex = desStart.lowerBound
        
        while currentIndex < mainContent.endIndex && !foundEnd {
          let char = mainContent[currentIndex]
          if char == "{" {
            braceCount += 1
          } else if char == "}" {
            braceCount -= 1
            if braceCount == 0 {
              foundEnd = true
              let ruleContent = String(mainContent[desStart.lowerBound...currentIndex])
              
              // Check if this is the activation shortcuts section
              if ruleContent.contains("\"Leader Key - Activation Shortcuts\"") {
                if includeActivationShortcuts {
                  activationShortcuts = "  " + ruleContent
                }
                // Don't add to mainRules - handle separately
              } else {
                // Add all other Leader Key sections
                mainRules.append("  " + ruleContent)
              }
            }
          }
          currentIndex = mainContent.index(after: currentIndex)
        }
        
        if foundEnd {
          searchRange = currentIndex..<mainContent.endIndex
        } else {
          break
        }
      }
    }
    
    return (applications: applications, mainRules: mainRules, activationShortcuts: activationShortcuts)
  }
  
  // Helper method to insert markers into karabiner.edn if they're missing
  private static func insertMarkersIfMissing(content: String) -> String {
    var modifiedContent = content
    
    // Check if applications section exists and add markers if missing
    if !content.contains(appStartMarker) && !content.contains(appEndMarker) {
      // Find :applications section
      if let appRange = modifiedContent.range(of: ":applications") {
        // Find the closing brace of :applications section
        var braceCount = 0
        var foundStart = false
        var currentIndex = appRange.upperBound
        
        while currentIndex < modifiedContent.endIndex {
          let char = modifiedContent[currentIndex]
          if char == "{" {
            if !foundStart {
              foundStart = true
            }
            braceCount += 1
          } else if char == "}" {
            braceCount -= 1
            if braceCount == 0 && foundStart {
              // Found the closing brace, insert markers before it
              let insertPoint = currentIndex
              let markersToInsert = "\n   \(appStartMarker)\n   ;; Leader Key applications will be injected here\n   \(appEndMarker)\n "
              modifiedContent.insert(contentsOf: markersToInsert, at: insertPoint)
              debugLog("[Karabiner2Exporter] Added application markers to karabiner.edn")
              break
            }
          }
          currentIndex = modifiedContent.index(after: currentIndex)
        }
      }
    }
    
    // Check if main section exists and add markers if missing
    if !content.contains(mainStartMarker) && !content.contains(mainEndMarker) {
      // Find :main section
      if let mainRange = modifiedContent.range(of: ":main") {
        // Find the opening bracket of :main array
        if let bracketRange = modifiedContent.range(of: "[", range: mainRange.upperBound..<modifiedContent.endIndex) {
          // Find the closing bracket of :main array
          var bracketCount = 0
          var currentIndex = bracketRange.lowerBound
          
          while currentIndex < modifiedContent.endIndex {
            let char = modifiedContent[currentIndex]
            if char == "[" {
              bracketCount += 1
            } else if char == "]" {
              bracketCount -= 1
              if bracketCount == 0 {
                // Found the closing bracket, insert markers before it
                let insertPoint = currentIndex
                let markersToInsert = "\n   \(mainStartMarker)\n   ;; Leader Key main rules will be injected here\n   \(mainEndMarker)\n "
                modifiedContent.insert(contentsOf: markersToInsert, at: insertPoint)
                debugLog("[Karabiner2Exporter] Added main markers to karabiner.edn")
                break
              }
            }
            currentIndex = modifiedContent.index(after: currentIndex)
          }
        }
      }
    }
    
    return modifiedContent
  }

  private static func replaceContentBetweenMarkers(
    in content: inout String,
    startMarker: String,
    endMarker: String,
    replacementContent: String
  ) -> Bool {
    guard let startRange = content.range(of: startMarker),
          let endRange = content.range(of: endMarker, range: startRange.upperBound..<content.endIndex)
    else {
      return false
    }

    let replaceRange = startRange.upperBound..<endRange.lowerBound
    let indent = lineIndentation(at: endRange.lowerBound, in: content)
    let replacement = "\n" + replacementContent + "\n" + indent
    content.replaceSubrange(replaceRange, with: replacement)
    return true
  }

  private static func lineIndentation(at index: String.Index, in content: String) -> String {
    let lineStart = content[..<index].lastIndex(of: "\n").map { content.index(after: $0) } ?? content.startIndex
    let prefix = content[lineStart..<index]
    return String(prefix.prefix { $0 == " " || $0 == "\t" })
  }

  private static func canonicalRule(_ rule: String) -> String {
    rule.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func extractActivationSection(from content: String) -> String? {
    guard let activationStart = content.range(of: "{:des \"Leader Key - Activation Shortcuts\"") else {
      return nil
    }

    var braceCount = 0
    var currentIndex = activationStart.lowerBound

    while currentIndex < content.endIndex {
      let char = content[currentIndex]
      if char == "{" {
        braceCount += 1
      } else if char == "}" {
        braceCount -= 1
        if braceCount == 0 {
          return String(content[activationStart.lowerBound...currentIndex])
        }
      }
      currentIndex = content.index(after: currentIndex)
    }

    return nil
  }
  
  // MARK: - Alternative Mappings
  
  // Apply alternative key mappings by placing alternative rules with conditions first
  // but respecting :condi group boundaries
  static func applyAlternativeKeyMappings(to rules: [String]) -> [String] {
    let manager = AlternativeMappingsManager.shared
    guard !manager.mappings.isEmpty else { return rules }
    
    var result: [String] = []
    var currentStateRules: [String] = []
    var currentStateAlternatives: [String] = []
    var inStateCondition = false
    
    for rule in rules {
      let trimmed = rule.trimmingCharacters(in: .whitespaces)
      
      // Check if this is a :condi line with state condition
      if trimmed.hasPrefix("[:condi") && trimmed.contains("\"leader_state\"") {
        // This is a state condition line
        // First, flush any accumulated rules from previous state
        if !currentStateAlternatives.isEmpty || !currentStateRules.isEmpty {
          result.append(contentsOf: currentStateAlternatives)
          result.append(contentsOf: currentStateRules)
          currentStateAlternatives.removeAll()
          currentStateRules.removeAll()
        }
        
        // Add the state condition line
        result.append(rule)
        inStateCondition = true
        continue
      }
      
      // Check if this is a :condi line without state (mode condition)
      if trimmed.hasPrefix("[:condi") && !trimmed.contains("\"leader_state\"") {
        // Mode condition - just pass through
        result.append(rule)
        inStateCondition = false
        continue
      }
      
      // For empty lines and comments, preserve them
      if trimmed.isEmpty || trimmed.hasPrefix(";;") || trimmed.hasPrefix("#") {
        if inStateCondition {
          currentStateRules.append(rule)
        } else {
          result.append(rule)
        }
        continue
      }
      
      // Process regular rules
      if inStateCondition {
        // Check if this rule needs alternatives
        var foundAlternative = false
        for mapping in manager.mappings {
          let originalKeyPattern = ":\(mapping.originalKey)"
          
          if rule.contains(originalKeyPattern) {
            if let alternativeRule = createAlternativeRule(
              from: rule,
              originalKey: mapping.originalKey,
              alternativeKey: mapping.alternativeKey,
              additionalConditions: mapping.conditions
            ) {
              currentStateAlternatives.append(alternativeRule)
              foundAlternative = true
            }
          }
        }
        
        // Always add the original rule
        currentStateRules.append(rule)
      } else {
        // Not in a state condition, just pass through
        result.append(rule)
      }
    }
    
    // Flush any remaining accumulated rules
    if !currentStateAlternatives.isEmpty || !currentStateRules.isEmpty {
      result.append(contentsOf: currentStateAlternatives)
      result.append(contentsOf: currentStateRules)
    }
    
    return result
  }
  
  // Helper to create an alternative rule from an original rule
  private static func createAlternativeRule(
    from originalRule: String,
    originalKey: String,
    alternativeKey: String,
    additionalConditions: [String]
  ) -> String? {
    // Only replace the key in the trigger (first element), not in the action part
    // Rule format: [trigger [actions] conditions]
    // We need to replace only the first occurrence which is the trigger key

    // Find the first occurrence of :\(originalKey) - this should be the trigger
    guard let firstKeyRange = originalRule.range(of: ":\(originalKey)") else {
      return nil  // Original key not found
    }

    // Replace only this first occurrence
    var alternativeRule = originalRule
    alternativeRule.replaceSubrange(firstKeyRange, with: ":\(alternativeKey)")
    
    // Add additional conditions if provided
    if !additionalConditions.isEmpty {
      // Format additional conditions for insertion
      let conditionsToAdd = additionalConditions.map { ":\($0)" }.joined(separator: " ")
      
      // Find the last closing bracket of the condition array
      // The structure is: [key action conditions] where conditions might be like [:app ["leader_state" X]]
      
      // Find the last ]] pattern which indicates the end of the condition array
      if let lastDoubleCloseBracket = alternativeRule.range(of: "]]", options: .backwards) {
        // Check if this is really a condition array by looking for state or app conditions
        let beforeDoubleBracket = alternativeRule[..<lastDoubleCloseBracket.lowerBound]
        
        // Look for the pattern that indicates a condition array (e.g., [:app [...]] or ["leader_state" ...])
        if beforeDoubleBracket.contains("leader_state") || beforeDoubleBracket.contains("[:") {
          // Find the closing bracket of the inner condition array to insert before it
          let insertPosition = lastDoubleCloseBracket.lowerBound
          
          // Insert the conditions before the last closing bracket of the condition array
          alternativeRule.insert(contentsOf: " " + conditionsToAdd, at: insertPosition)
        }
      } else if let lastSingleBracket = alternativeRule.range(of: "]", options: .backwards) {
        // Fallback: if there's just a single bracket at the end (simple condition)
        // Check if this looks like a condition by checking what comes before
        let beforeBracket = alternativeRule[..<lastSingleBracket.lowerBound]
        if beforeBracket.hasSuffix("\"leader_state\" \(inactiveStateId)") || 
           beforeBracket.contains("[\"leader_state\"") {
          // This is likely a simple state condition, add our conditions before the closing bracket
          alternativeRule.insert(contentsOf: " " + conditionsToAdd, at: lastSingleBracket.lowerBound)
        }
      }
    }
    
    // Add a comment to indicate this is an alternative mapping
    let indent = originalRule.prefix(while: { $0 == " " })
    alternativeRule = "\(indent);; Alternative: \(alternativeKey) for \(originalKey)\n\(alternativeRule)"
    
    return alternativeRule
  }
}
