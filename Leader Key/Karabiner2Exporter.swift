import Foundation

final class Karabiner2Exporter {

  struct StateNode {
    let path: [String]
    let originalPath: [String]  // Store original keys for CLI commands
    let stateId: Int32
    let item: ActionOrGroup
    let isTerminal: Bool
  }
  
  struct AppMetadata: Codable {
    let customName: String?
    let createdAt: Double?
    let lastModified: Double?
  }
  
  // Structure to store state ID to action mapping
  struct StateMapping: Codable {
    let stateId: Int32
    let path: [String]          // Path in key notation (e.g., ["o", "a"])
    let appAlias: String?        // App alias if app-specific
    let bundleId: String?        // Bundle ID if app-specific
    let actionType: String       // "action" or "group"
    let actionTypeRaw: String?   // The raw action type (.application, .command, .url, etc.)
    let actionValue: String?     // The actual action value to execute
    let actionLabel: String?     // Display label for the action
  }

  // Different initial states for different activation types
  private static let globalInitialStateId: Int32 = 1
  private static let fallbackInitialStateId: Int32 = 2
  private static let inactiveStateId: Int32 = 0
  
  // Legacy constant for backward compatibility
  private static let initialStateId: Int32 = globalInitialStateId

  static func generateGokuEDN(from config: UserConfig, bundleId: String? = nil) -> String {
    let (stateTree, _) = buildStateTree(from: config.root, appAlias: nil, bundleId: bundleId)
    let manipulators = generateManipulators(from: stateTree, bundleId: bundleId)

    return formatGokuEDN(manipulators: manipulators, bundleId: bundleId)
  }
  
  // Generate unified EDN with hierarchical organization and :condi grouping
  // Returns: (ednContent, stateMappings)
  static func generateUnifiedGokuEDNHierarchical(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) -> (edn: String, stateMappings: [StateMapping]) {
    debugLog("[Karabiner2Exporter] generateUnifiedGokuEDNHierarchical called with \(appConfigs.count) app configs")
    
    // 1. Generate app aliases
    var appAliases: [(bundleId: String, alias: String, config: UserConfig)] = []
    var usedAliases = Set<String>()
    
    for (bundleId, config, customName) in appConfigs {
      if bundleId.contains(".meta") {
        debugLog("[Karabiner2Exporter] WARNING: Skipping bundle ID with .meta: \(bundleId)")
        continue
      }
      
      var alias = generateAppAlias(from: bundleId, customName: customName)
      
      // Ensure uniqueness
      var counter = 1
      let baseAlias = alias
      while usedAliases.contains(alias) {
        alias = "\(baseAlias)_\(counter)"
        counter += 1
      }
      usedAliases.insert(alias)
      
      debugLog("[Karabiner2Exporter] Generated alias: bundleId=\(bundleId) → alias=\(alias)")
      appAliases.append((bundleId: bundleId, alias: alias, config: config))
    }
    
    // 2. Generate applications section
    let applications = generateApplicationsSectionFromAliases(appAliases: appAliases)
    
    // 3. Structure to hold all :des sections
    var desSections: [(name: String, groups: [ManipulatorGroup])] = []
    var allStateMappings: [StateMapping] = []
    
    // 4. Generate global mode section
    let (globalStateTree, globalMappings) = buildStateTree(
      from: globalConfig.root,
      appAlias: nil,
      bundleId: nil,
      initialStateId: globalInitialStateId
    )
    allStateMappings.append(contentsOf: globalMappings)
    
    let globalGroups = generateManipulatorsForUnifiedHierarchical(
      from: globalStateTree,
      appAlias: nil,
      bundleId: nil,
      activationKey: "{:key :k :modi :command}",
      initialStateId: globalInitialStateId
    )
    desSections.append((name: "Leader Key - Global Mode", groups: globalGroups))
    
    // 5. Generate fallback mode section
    let fallbackGroups = [
      ManipulatorGroup(
        condition: nil,
        rules: [generateUnifiedActivationManipulator(
          appAlias: nil,
          bundleId: "__FALLBACK__",
          activationKey: "{:key :k :modi [:command :option]}",
          initialStateId: fallbackInitialStateId
        )]
      )
    ]
    desSections.append((name: "Leader Key - Fallback Mode", groups: fallbackGroups))
    
    // 6. Generate app-specific sections
    for (bundleId, alias, config) in appAliases {
      let appInitialStateId = generateAppInitialStateId(appAlias: alias)
      let (appStateTree, appMappings) = buildStateTree(
        from: config.root,
        appAlias: alias,
        bundleId: bundleId,
        initialStateId: appInitialStateId
      )
      allStateMappings.append(contentsOf: appMappings)
      
      let appGroups = generateManipulatorsForUnifiedHierarchical(
        from: appStateTree,
        appAlias: alias,
        bundleId: bundleId,
        activationKey: "{:key :k :modi [:command :shift]}",
        initialStateId: appInitialStateId
      )
      
      // Find custom name from original appConfigs
      let customName = appConfigs.first(where: { $0.bundleId == bundleId })?.customName
      let appName = customName ?? alias
      desSections.append((name: "Leader Key - \(appName)", groups: appGroups))
    }
    
    // 7. Format as hierarchical EDN
    let ednContent = formatUnifiedGokuEDNHierarchical(
      applications: applications,
      desSections: desSections
    )
    
    return (edn: ednContent, stateMappings: allStateMappings)
  }
  
  // Generate unified EDN with all app configs in a single file (legacy flat version)
  // Returns: (ednContent, stateMappings)
  static func generateUnifiedGokuEDN(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) -> (edn: String, stateMappings: [StateMapping]) {
    debugLog("[Karabiner2Exporter] generateUnifiedGokuEDN called with \(appConfigs.count) app configs")
    for (bundleId, _, customName) in appConfigs {
      debugLog("[Karabiner2Exporter] Received appConfig: bundleId=\(bundleId), customName=\(customName ?? "nil")")
    }
    // 1. First generate all unique aliases
    var appAliases: [(bundleId: String, alias: String, config: UserConfig)] = []
    var usedAliases = Set<String>()
    
    for (bundleId, config, customName) in appConfigs {
      // Skip any bundle IDs that contain .meta (defensive check)
      if bundleId.contains(".meta") {
        debugLog("[Karabiner2Exporter] WARNING: Skipping bundle ID with .meta: \(bundleId)")
        continue
      }
      
      var alias = generateAppAlias(from: bundleId, customName: customName)
      
      // Ensure uniqueness
      var counter = 1
      let baseAlias = alias
      while usedAliases.contains(alias) {
        alias = "\(baseAlias)_\(counter)"
        counter += 1
      }
      usedAliases.insert(alias)
      
      debugLog("[Karabiner2Exporter] Generated alias: bundleId=\(bundleId) → alias=\(alias)")
      appAliases.append((bundleId: bundleId, alias: alias, config: config))
    }
    
    // 2. Generate applications section with unique aliases
    let applications = generateApplicationsSectionFromAliases(appAliases: appAliases)
    
    // 3. Generate global manipulators (no app condition, Cmd+K activation)
    var allStateMappings: [StateMapping] = []
    let (globalStateTree, globalMappings) = buildStateTree(from: globalConfig.root, appAlias: nil, bundleId: nil, initialStateId: globalInitialStateId)
    allStateMappings.append(contentsOf: globalMappings)
    let globalManipulators = generateManipulatorsForUnified(
      from: globalStateTree,
      appAlias: nil,
      bundleId: nil,
      activationKey: "{:key :k :modi :command}",  // Cmd+K for global
      initialStateId: globalInitialStateId
    )
    
    // 4. Generate app-specific manipulators (Cmd+Shift+K activation)
    var appSections: [(alias: String, manipulators: [String])] = []
    for (bundleId, alias, config) in appAliases {
      let appInitialStateId = generateAppInitialStateId(appAlias: alias)
      let (appStateTree, appMappings) = buildStateTree(from: config.root, appAlias: alias, bundleId: bundleId, initialStateId: appInitialStateId)
      allStateMappings.append(contentsOf: appMappings)
      let manipulators = generateManipulatorsForUnified(
        from: appStateTree,
        appAlias: alias,
        bundleId: bundleId,
        activationKey: "{:key :k :modi [:command :shift]}",  // Cmd+Shift+K for app-specific
        initialStateId: appInitialStateId
      )
      appSections.append((alias: alias, manipulators: manipulators))
    }
    
    // 5. Generate fallback-only activation manipulator (Cmd+Option+K)
    let fallbackManipulator = generateUnifiedActivationManipulator(
      appAlias: nil,
      bundleId: "__FALLBACK__",
      activationKey: "{:key :k :modi [:command :option]}",  // Cmd+Option+K for fallback-only
      initialStateId: fallbackInitialStateId
    )
    
    // 6. Format unified EDN
    let ednContent = formatUnifiedGokuEDN(
      applications: applications,
      globalManipulators: globalManipulators,
      appSections: appSections,
      fallbackManipulator: fallbackManipulator
    )
    
    return (edn: ednContent, stateMappings: allStateMappings)
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
  
  // Legacy function kept for backward compatibility (not used in unified generation)
  private static func generateApplicationsSection(from appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]) -> String {
    guard !appConfigs.isEmpty else { return "" }
    
    var appLines: [String] = []
    for (bundleId, _, customName) in appConfigs {
      let alias = generateAppAlias(from: bundleId, customName: customName)
      appLines.append("   :\(alias) [\"\(bundleId)\"]")
    }
    
    return " :applications {\n\(appLines.joined(separator: "\n"))\n }"
  }

  private static func buildStateTree(from group: Group, appAlias: String? = nil, bundleId: String? = nil, initialStateId: Int32 = globalInitialStateId) -> ([StateNode], [StateMapping]) {
    var nodes: [StateNode] = []
    var stateMappings: [StateMapping] = []
    var queue: [(item: ActionOrGroup, path: [String], originalPath: [String], parentStateId: Int32)] = []

    for item in group.actions {
      queue.append((item: item, path: [], originalPath: [], parentStateId: initialStateId))
    }

    while !queue.isEmpty {
      let current = queue.removeFirst()
      guard let originalKey = current.item.item.key, !originalKey.isEmpty else { continue }  // Skip items without keys
      
      // Normalize the key for state ID generation
      let keyForPath = normalizeKeyForPath(originalKey)
      guard !keyForPath.isEmpty else { continue }
      
      let currentPath = current.path + [keyForPath]
      let currentOriginalPath = current.originalPath + [originalKey]
      let stateId = generateStateId(from: currentPath, appAlias: appAlias)

      switch current.item {
      case .action(let action):
        // For terminal actions, include action value in state ID to ensure uniqueness
        let terminalStateId = generateStateId(from: currentPath + [action.value], appAlias: appAlias)
        nodes.append(
          StateNode(
            path: currentPath,
            originalPath: currentOriginalPath,
            stateId: terminalStateId,
            item: .action(action),
            isTerminal: true
          ))
        
        // Create state mapping for this action
        let mapping = StateMapping(
          stateId: terminalStateId,  // Use terminal's own unique state ID
          path: currentOriginalPath,
          appAlias: appAlias,
          bundleId: bundleId,
          actionType: "action",
          actionTypeRaw: action.type.rawValue,
          actionValue: action.value,
          actionLabel: action.label
        )
        stateMappings.append(mapping)
      case .group(let subgroup):
        nodes.append(
          StateNode(
            path: currentPath,
            originalPath: currentOriginalPath,
            stateId: stateId,
            item: .group(subgroup),
            isTerminal: false
          ))
        
        // Create state mapping for this group to enable UI navigation
        let groupMapping = StateMapping(
          stateId: stateId,
          path: currentOriginalPath,
          appAlias: appAlias,
          bundleId: bundleId,
          actionType: "group",
          actionTypeRaw: nil,
          actionValue: nil,
          actionLabel: subgroup.label
        )
        stateMappings.append(groupMapping)

        for subItem in subgroup.actions {
          queue.append((item: subItem, path: currentPath, originalPath: currentOriginalPath, parentStateId: stateId))
        }
      }
    }

    return (nodes, stateMappings)
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
  
  private static func generateStateId(from path: [String], appAlias: String? = nil) -> Int32 {
    guard !path.isEmpty else { return initialStateId }

    // Include app alias in the path to ensure state isolation between apps
    let fullPath = appAlias != nil ? [appAlias!] + path : path
    let pathString = fullPath.filter { !$0.isEmpty }.joined(separator: ".")
    
    // Use djb2 hash algorithm for stability across runs
    var hash: Int64 = 5381
    for byte in pathString.utf8 {
      hash = ((hash << 5) &+ hash) &+ Int64(byte)
    }

    let maxValue: Int32 = 2_147_483_647
    let minValue: Int32 = 2

    let positiveHash = abs(hash)
    let scaledHash = positiveHash % Int64(maxValue - minValue)

    return Int32(scaledHash) + minValue
  }
  
  // Generate unique initial state ID for app-specific activations
  private static func generateAppInitialStateId(appAlias: String) -> Int32 {
    // Generate unique state ID based on app alias
    // Starting from 1000 to avoid conflicts with global (1) and fallback (2)
    let baseId = generateStateId(from: ["app_initial", appAlias])
    // Keep it in a reasonable range (1000-99999) to avoid conflicts
    return 1000 + (abs(baseId) % 99000)
  }

  private static func generateManipulators(from nodes: [StateNode], bundleId: String? = nil) -> [String] {
    var manipulators: [String] = []

    manipulators.append(generateActivationManipulator(bundleId: bundleId))
    
    // Collect all unique state IDs for escape handlers
    var allStateIds = Set<Int32>([initialStateId])

    var stateTransitions: [Int32: [String: Int32]] = [:]
    var terminalActions: [Int32: [String: (path: String, terminalStateId: Int32)]] = [:]
    // Track processed keys to avoid duplicates
    var processedKeys: Set<String> = []

    for node in nodes {
      guard let key = node.item.item.key else { continue }

      let parentStateId =
        node.path.count <= 1 ? initialStateId : generateStateId(from: Array(node.path.dropLast()))

      // Create unique identifier for this key at this state
      let keyStateIdentifier = "\(parentStateId):\(key)"
      
      // Skip if we've already processed this key at this state
      if processedKeys.contains(keyStateIdentifier) {
        continue
      }
      processedKeys.insert(keyStateIdentifier)

      // Collect state IDs for escape handlers
      allStateIds.insert(parentStateId)
      
      if node.isTerminal {
        if terminalActions[parentStateId] == nil {
          terminalActions[parentStateId] = [:]
        }

        // Convert each key in path to Karabiner notation for CLI commands
        let karabinerPath = node.originalPath.map { convertToKarabinerKey($0) }
        let pathString = karabinerPath.joined(separator: " ")
        terminalActions[parentStateId]?[key] = (path: pathString, terminalStateId: node.stateId)
      } else {
        if stateTransitions[parentStateId] == nil {
          stateTransitions[parentStateId] = [:]
        }
        stateTransitions[parentStateId]?[key] = node.stateId
        allStateIds.insert(node.stateId)  // Also collect target state IDs
      }
    }

    for (fromState, transitions) in stateTransitions {
      for (key, toState) in transitions {
        manipulators.append(
          generateStateTransition(key: key, fromState: fromState, toState: toState, bundleId: bundleId))
      }
    }

    for (fromState, actions) in terminalActions {
      for (key, actionData) in actions {
        manipulators.append(
          generateTerminalAction(key: key, fromState: fromState, toState: actionData.terminalStateId, actionPath: actionData.path, bundleId: bundleId))
      }
    }
    
    // Add escape handlers for each active state
    for stateId in allStateIds.sorted() {
      manipulators.append(generateEscapeHandler(forState: stateId, bundleId: bundleId))
    }

    return manipulators
  }
  
  // Structure to represent grouped manipulators with conditions
  private struct ManipulatorGroup {
    let condition: String?  // :condi statement, nil for no condition
    let rules: [String]     // Rules that share this condition
  }
  
  // Generate manipulators for unified EDN with hierarchical :condi grouping
  private static func generateManipulatorsForUnifiedHierarchical(
    from nodes: [StateNode],
    appAlias: String?,
    bundleId: String?,
    activationKey: String,
    initialStateId: Int32
  ) -> [ManipulatorGroup] {
    var groups: [ManipulatorGroup] = []
    
    // 1. Activation group (no condition needed for activation)
    let activationRule = generateUnifiedActivationManipulator(
      appAlias: appAlias,
      bundleId: bundleId,
      activationKey: activationKey,
      initialStateId: initialStateId
    )
    groups.append(ManipulatorGroup(condition: nil, rules: [activationRule]))
    
    // Collect and organize rules by state
    var stateTransitions: [Int32: [String: Int32]] = [:]
    var terminalActions: [Int32: [String: (path: String, terminalStateId: Int32)]] = [:]
    var allStateIds = Set<Int32>([initialStateId])
    var processedKeys: Set<String> = []
    
    for node in nodes {
      guard let key = node.item.item.key else { continue }
      
      let parentStateId = node.path.count <= 1 
        ? initialStateId 
        : generateStateId(from: Array(node.path.dropLast()), appAlias: appAlias)
      
      let keyStateIdentifier = "\(parentStateId):\(key)"
      
      if processedKeys.contains(keyStateIdentifier) {
        continue
      }
      processedKeys.insert(keyStateIdentifier)
      
      allStateIds.insert(parentStateId)
      
      if node.isTerminal {
        if terminalActions[parentStateId] == nil {
          terminalActions[parentStateId] = [:]
        }
        
        let karabinerPath = node.originalPath.map { convertToKarabinerKey($0) }
        let pathString = karabinerPath.joined(separator: " ")
        terminalActions[parentStateId]?[key] = (path: pathString, terminalStateId: node.stateId)
      } else {
        if stateTransitions[parentStateId] == nil {
          stateTransitions[parentStateId] = [:]
        }
        stateTransitions[parentStateId]?[key] = node.stateId
        allStateIds.insert(node.stateId)
      }
    }
    
    // 2. Mode-level condition group
    let modeCondition: String
    if bundleId == "__FALLBACK__" {
      modeCondition = "[:condi :leaderkey_fallback]"
    } else if let alias = appAlias {
      modeCondition = "[:condi :\(alias) :leaderkey_active :!leaderkey_global :!leaderkey_fallback]"
    } else {
      modeCondition = "[:condi :leaderkey_global]"
    }
    
    // Generate escape handler for all states (under mode condition)
    var modeRules: [String] = []
    for stateId in allStateIds.sorted() {
      modeRules.append(generateUnifiedEscapeHandler(forState: stateId, appAlias: appAlias))
    }
    
    // 3. Group rules by state with nested conditions
    for stateId in allStateIds.sorted() {
      var stateRules: [String] = []
      
      // Add transitions from this state
      if let transitions = stateTransitions[stateId] {
        for (key, toState) in transitions.sorted(by: { $0.key < $1.key }) {
          stateRules.append(
            generateUnifiedStateTransition(key: key, fromState: stateId, toState: toState, appAlias: appAlias)
          )
        }
      }
      
      // Add terminal actions from this state
      if let actions = terminalActions[stateId] {
        for (key, actionData) in actions.sorted(by: { $0.key < $1.key }) {
          stateRules.append(
            generateUnifiedTerminalAction(
              key: key,
              fromState: stateId,
              toState: actionData.terminalStateId,
              actionPath: actionData.path,
              appAlias: appAlias
            )
          )
        }
      }
      
      if !stateRules.isEmpty {
        // Add state-specific condition
        let stateCondition: String
        if bundleId == "__FALLBACK__" {
          stateCondition = "[:condi :leaderkey_fallback [\"leader_state\" \(stateId)]]"
        } else if let alias = appAlias {
          stateCondition = "[:condi :\(alias) :leaderkey_active :!leaderkey_global :!leaderkey_fallback [\"leader_state\" \(stateId)]]"
        } else {
          stateCondition = "[:condi :leaderkey_global [\"leader_state\" \(stateId)]]"
        }
        
        modeRules.append(stateCondition)
        modeRules.append(contentsOf: stateRules)
      }
    }
    
    if !modeRules.isEmpty {
      groups.append(ManipulatorGroup(condition: modeCondition, rules: modeRules))
    }
    
    return groups
  }
  
  // Generate manipulators for unified EDN with cleaner app alias conditions (legacy flat version)
  private static func generateManipulatorsForUnified(
    from nodes: [StateNode],
    appAlias: String?,
    bundleId: String?,
    activationKey: String,
    initialStateId: Int32
  ) -> [String] {
    var manipulators: [String] = []
    
    // Add activation manipulator with specified key
    manipulators.append(generateUnifiedActivationManipulator(appAlias: appAlias, bundleId: bundleId, activationKey: activationKey, initialStateId: initialStateId))
    
    // Collect all unique state IDs for escape handlers
    var allStateIds = Set<Int32>([initialStateId])
    
    var stateTransitions: [Int32: [String: Int32]] = [:]
    var terminalActions: [Int32: [String: (path: String, terminalStateId: Int32)]] = [:]
    var processedKeys: Set<String> = []
    
    for node in nodes {
      guard let key = node.item.item.key else { continue }
      
      let parentStateId = node.path.count <= 1 
        ? initialStateId 
        : generateStateId(from: Array(node.path.dropLast()), appAlias: appAlias)
      
      let keyStateIdentifier = "\(parentStateId):\(key)"
      
      if processedKeys.contains(keyStateIdentifier) {
        continue
      }
      processedKeys.insert(keyStateIdentifier)
      
      allStateIds.insert(parentStateId)
      
      if node.isTerminal {
        if terminalActions[parentStateId] == nil {
          terminalActions[parentStateId] = [:]
        }
        
        let karabinerPath = node.originalPath.map { convertToKarabinerKey($0) }
        let pathString = karabinerPath.joined(separator: " ")
        terminalActions[parentStateId]?[key] = (path: pathString, terminalStateId: node.stateId)
      } else {
        if stateTransitions[parentStateId] == nil {
          stateTransitions[parentStateId] = [:]
        }
        stateTransitions[parentStateId]?[key] = node.stateId
        allStateIds.insert(node.stateId)
      }
    }
    
    // Generate state transitions with cleaner app conditions
    for (fromState, transitions) in stateTransitions {
      for (key, toState) in transitions {
        manipulators.append(
          generateUnifiedStateTransition(key: key, fromState: fromState, toState: toState, appAlias: appAlias)
        )
      }
    }
    
    // Generate terminal actions with cleaner app conditions
    for (fromState, actions) in terminalActions {
      for (key, actionData) in actions {
        manipulators.append(
          generateUnifiedTerminalAction(key: key, fromState: fromState, toState: actionData.terminalStateId, actionPath: actionData.path, appAlias: appAlias)
        )
      }
    }
    
    // Add escape handlers for each active state
    for stateId in allStateIds.sorted() {
      manipulators.append(generateUnifiedEscapeHandler(forState: stateId, appAlias: appAlias))
    }
    
    return manipulators
  }

  private static func generateActivationManipulator(bundleId: String? = nil) -> String {
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let activateCmd =
      FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) activate" : "echo 'activate' | nc -U /tmp/leaderkey.sock"

    if let bundleId = bundleId {
      // Add condition for specific app
      return """
           [{:key :k :modi :command} 
            [[\"leader_state\" \(initialStateId)] [:shell "\(activateCmd)"]]
            {:conditions [:frontmost_application_is ["\(bundleId)"]]}]
        """
    } else {
      // No condition - works everywhere
      return """
           [{:key :k :modi :command} [[\"leader_state\" \(initialStateId)] [:shell "\(activateCmd)"]]]
        """
    }
  }

  private static func generateEscapeHandler(forState stateId: Int32, bundleId: String? = nil) -> String {
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let deactivateCmd =
      FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) deactivate" : "echo 'deactivate' | nc -U /tmp/leaderkey.sock"

    if let bundleId = bundleId {
      return """
           [:escape 
            [[\"leader_state\" \(inactiveStateId)] [:shell "\(deactivateCmd)"]] 
            {:conditions [[:frontmost_application_is ["\(bundleId)"]] [\"leader_state\" \(stateId)]]}]
        """
    } else {
      return """
           [:escape [[\"leader_state\" \(inactiveStateId)] [:shell "\(deactivateCmd)"]] [\"leader_state\" \(stateId)]]
        """
    }
  }

  private static func generateStateTransition(key: String, fromState: Int32, toState: Int32, bundleId: String? = nil)
    -> String
  {
    let karabinerKey = convertToKarabinerKey(key)
    if let bundleId = bundleId {
      return """
           [\(karabinerKey) 
            [[\"leader_state\" \(toState)]] 
            {:conditions [[:frontmost_application_is ["\(bundleId)"]] [\"leader_state\" \(fromState)]]}]
        """
    } else {
      return """
           [\(karabinerKey) [[\"leader_state\" \(toState)]] [\"leader_state\" \(fromState)]]
        """
    }
  }

  private static func generateTerminalAction(key: String, fromState: Int32, toState: Int32, actionPath: String, bundleId: String? = nil)
    -> String
  {
    let karabinerKey = convertToKarabinerKey(key)
    let cliPath = "/usr/local/bin/leaderkey-cli"
    // Use stateid command with the terminal state ID
    let sequenceCmd =
      FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) stateid \(toState)"
      : "echo 'stateid \(toState)' | nc -U /tmp/leaderkey.sock"

    if let bundleId = bundleId {
      return """
           [\(karabinerKey) 
            [[:shell "\(sequenceCmd)"] [\"leader_state\" \(inactiveStateId)]] 
            {:conditions [[:frontmost_application_is ["\(bundleId)"]] [\"leader_state\" \(fromState)]]}]
        """
    } else {
      return """
           [\(karabinerKey) [[:shell "\(sequenceCmd)"] [\"leader_state\" \(inactiveStateId)]] [\"leader_state\" \(fromState)]]
        """
    }
  }

  private static func convertToKarabinerKey(_ key: String) -> String {
    // Handle empty key
    guard !key.isEmpty else { return key }
    
    // Parse modifier prefixes (C=cmd, S=shift, O=option, T=ctrl)
    var modifierList: [String] = []
    var baseKey = key
    
    // Check for modifier prefixes at the start of the key
    if key.count > 1 {
      let prefixes = key.prefix(while: { "CSOT".contains($0) })
      if !prefixes.isEmpty {
        // Build modifier list for expanded notation
        for char in prefixes {
          switch char {
          case "C": modifierList.append(":command")
          case "S": modifierList.append(":shift")
          case "O": modifierList.append(":option")
          case "T": modifierList.append(":control")
          default: break
          }
        }
        baseKey = String(key.dropFirst(prefixes.count))
      }
    }
    
    // Check if baseKey is a single uppercase letter (implies Shift modifier)
    if baseKey.count == 1, let char = baseKey.first, char.isUppercase {
      // Add Shift modifier if not already present
      if !modifierList.contains(":shift") {
        modifierList.append(":shift")
      }
      // Convert to lowercase
      baseKey = baseKey.lowercased()
    }
    
    // Map special keys to Karabiner notation
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
      // Unicode arrow symbols
      "↑": "up_arrow",
      "↓": "down_arrow",
      "←": "left_arrow",
      "→": "right_arrow",
      // Text representations
      "up": "up_arrow",
      "down": "down_arrow",
      "left": "left_arrow",
      "right": "right_arrow",
      "escape": "escape",
      "esc": "escape",
    ]
    
    // Special characters that require Shift modifier
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
    
    // Check if it's a shifted special character
    if let shiftedKey = shiftedKeyMap[baseKey] {
      // Add Shift modifier if not already present
      if !modifierList.contains(":shift") {
        modifierList.append(":shift")
      }
      baseKey = shiftedKey
    }
    
    // Get the mapped key or use the base key lowercased
    let mappedKey = keyMap[baseKey.lowercased()] ?? baseKey.lowercased()
    
    // Return in expanded format
    if modifierList.isEmpty {
      // No modifiers, just return the key with colon prefix
      return ":\(mappedKey)"
    } else if modifierList.count == 1 {
      // Single modifier
      return "{:key :\(mappedKey) :modi \(modifierList[0])}"
    } else {
      // Multiple modifiers - use array notation
      let modifiersStr = "[" + modifierList.joined(separator: " ") + "]"
      return "{:key :\(mappedKey) :modi \(modifiersStr)}"
    }
  }

  // Unified manipulator generators with cleaner app alias conditions
  private static func generateUnifiedActivationManipulator(appAlias: String?, bundleId: String?, activationKey: String, initialStateId: Int32) -> String {
    let cliPath = "/usr/local/bin/leaderkey-cli"
    
    // Include bundleId in activation command for app-specific activations
    let activateCmd: String
    if let bundleId = bundleId {
      // App-specific activation with bundleId
      activateCmd = FileManager.default.fileExists(atPath: cliPath)
        ? "\(cliPath) activate \(bundleId)" : "echo 'activate \(bundleId)' | nc -U /tmp/leaderkey.sock"
    } else {
      // Global activation without bundleId
      activateCmd = FileManager.default.fileExists(atPath: cliPath)
        ? "\(cliPath) activate" : "echo 'activate' | nc -U /tmp/leaderkey.sock"
    }
    
    // Determine which mode variables to set
    let modeVars: String
    if bundleId == "__FALLBACK__" {
      // Fallback mode
      modeVars = "[\"leaderkey_active\" 1] [\"leaderkey_fallback\" 1] [\"leaderkey_global\" 0]"
    } else if appAlias != nil {
      // App-specific mode
      modeVars = "[\"leaderkey_active\" 1] [\"leaderkey_fallback\" 0] [\"leaderkey_global\" 0]"
    } else {
      // Global mode
      modeVars = "[\"leaderkey_active\" 1] [\"leaderkey_global\" 1] [\"leaderkey_fallback\" 0]"
    }
    
    if let alias = appAlias {
      // App-specific activation with simple app alias condition
      return "   [\(activationKey) [\(modeVars) [\"leader_state\" \(initialStateId)] [:shell \"\(activateCmd)\"]] :\(alias)]"
    } else {
      // Global or fallback activation with no app condition
      return "   [\(activationKey) [\(modeVars) [\"leader_state\" \(initialStateId)] [:shell \"\(activateCmd)\"]]]"
    }
  }
  
  private static func generateUnifiedEscapeHandler(forState stateId: Int32, appAlias: String?) -> String {
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let deactivateCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) deactivate" : "echo 'deactivate' | nc -U /tmp/leaderkey.sock"
    
    // Clear all mode variables on escape
    let clearVars = "[\"leaderkey_active\" 0] [\"leaderkey_global\" 0] [\"leaderkey_fallback\" 0] [\"leader_state\" \(inactiveStateId)]"
    
    if let alias = appAlias {
      // App-specific escape with combined conditions
      return "   [:escape [\(clearVars) [:shell \"\(deactivateCmd)\"]] [:\(alias) [\"leader_state\" \(stateId)]]]"
    } else {
      // Global escape with just state condition
      return "   [:escape [\(clearVars) [:shell \"\(deactivateCmd)\"]] [\"leader_state\" \(stateId)]]"
    }
  }
  
  private static func generateUnifiedStateTransition(key: String, fromState: Int32, toState: Int32, appAlias: String?) -> String {
    let karabinerKey = convertToKarabinerKey(key)
    let cliPath = "/usr/local/bin/leaderkey-cli"
    
    // Send state change notification to update UI
    let stateCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) stateid \(toState)"
      : "echo 'stateid \(toState)' | nc -U /tmp/leaderkey.sock"
    
    if let alias = appAlias {
      // App-specific transition with combined conditions
      return "   [\(karabinerKey) [[\"leader_state\" \(toState)] [:shell \"\(stateCmd)\"]] [:\(alias) [\"leader_state\" \(fromState)]]]"
    } else {
      // Global transition with just state condition
      return "   [\(karabinerKey) [[\"leader_state\" \(toState)] [:shell \"\(stateCmd)\"]] [\"leader_state\" \(fromState)]]"
    }
  }
  
  private static func generateUnifiedTerminalAction(key: String, fromState: Int32, toState: Int32, actionPath: String, appAlias: String?) -> String {
    let karabinerKey = convertToKarabinerKey(key)
    let cliPath = "/usr/local/bin/leaderkey-cli"
    // Use stateid command with the terminal state ID
    let sequenceCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) stateid \(toState)"
      : "echo 'stateid \(toState)' | nc -U /tmp/leaderkey.sock"
    
    // Clear all mode variables when executing terminal action
    let clearVars = "[\"leaderkey_active\" 0] [\"leaderkey_global\" 0] [\"leaderkey_fallback\" 0] [\"leader_state\" \(inactiveStateId)]"
    
    if let alias = appAlias {
      // App-specific terminal action with combined conditions
      return "   [\(karabinerKey) [[:shell \"\(sequenceCmd)\"] \(clearVars)] [:\(alias) [\"leader_state\" \(fromState)]]]"
    } else {
      // Global terminal action with just state condition
      return "   [\(karabinerKey) [[:shell \"\(sequenceCmd)\"] \(clearVars)] [\"leader_state\" \(fromState)]]"
    }
  }
  
  private static func formatGokuEDN(manipulators: [String], bundleId: String? = nil) -> String {
    // Split manipulators into sections for better organization
    let activation = manipulators.first ?? ""
    let statesAndActions = manipulators.dropFirst()
    
    let appComment = bundleId != nil ? " for \(bundleId!)" : ""
    let description = "Leader Key 2.0 State Machine\(appComment)"
    
    return """
      ;; Goku Configuration for Leader Key 2.0
      ;; Generated state machine with numeric state tracking
      ;; State 0 = inactive, State 1 = leader active, Other states = navigation states

      {
       :main [{:des "\(description)"
               :rules [
                 ;; ========== ACTIVATION ==========
      \(activation)
                 
                 ;; ========== STATE TRANSITIONS & ESCAPE HANDLERS ==========
      \(statesAndActions.joined(separator: "\n"))
               ]}]
      }
      """
  }
  
  // Format unified EDN with all app configs in a single file
  private static func formatUnifiedGokuEDNHierarchical(
    applications: String,
    desSections: [(name: String, groups: [ManipulatorGroup])]
  ) -> String {
    var mainSections: [String] = []
    
    // Generate each :des section
    for (sectionName, groups) in desSections {
      var rules: [String] = []
      
      for group in groups {
        // Add condition if present
        if let condition = group.condition {
          rules.append("   \(condition)")
        }
        
        // Add all rules in this group
        rules.append(contentsOf: group.rules)
      }
      
      if !rules.isEmpty {
        var section = "  {:des \"\(sectionName)\"\n"
        section += "   :rules [\n"
        section += rules.joined(separator: "\n")
        section += "\n   ]}"
        mainSections.append(section)
      }
    }
    
    // Build final EDN
    var edn = ";; Leader Key 2.0 Configuration with Hierarchical Organization\n"
    edn += ";; Generated by Leader Key\n\n"
    edn += "{\n"
    
    // Add applications section
    edn += applications
    edn += "\n"
    
    // Add input sources
    edn += " :input-sources {\n"
    edn += "   :leaderkey {:input_source_id \"^com\\.apple\\.keylayout\\.US$\"}\n"
    edn += " }\n\n"
    
    // Add main sections
    edn += " :main [\n"
    edn += mainSections.joined(separator: "\n\n")
    edn += "\n ]"
    
    edn += "\n}"
    
    return edn
  }
  
  private static func formatUnifiedGokuEDN(
    applications: String,
    globalManipulators: [String],
    appSections: [(alias: String, manipulators: [String])],
    fallbackManipulator: String? = nil
  ) -> String {
    var rules: [String] = []
    
    // 1. Create Activation section with all activation keys
    var activationRules: [String] = []
    
    // Extract global activation (first item is always activation)
    if !globalManipulators.isEmpty {
      activationRules.append(globalManipulators[0])
    }
    
    // Add fallback-only activation if provided
    if let fallbackManipulator = fallbackManipulator {
      activationRules.append(fallbackManipulator)
    }
    
    // Extract app-specific activations (first item of each app section)
    for (_, manipulators) in appSections {
      if !manipulators.isEmpty {
        activationRules.append(manipulators[0])
      }
    }
    
    // Add activation section if we have any activations
    if !activationRules.isEmpty {
      var activationSection = "  {:des \"Leader Key 2.0 - Activation\"\n"
      activationSection += "   :rules [\n"
      activationSection += activationRules.joined(separator: "\n")
      activationSection += "\n   ]}"
      rules.append(activationSection)
    }
    
    // 2. Create Global section (without activation)
    let globalRulesWithoutActivation = Array(globalManipulators.dropFirst())
    if !globalRulesWithoutActivation.isEmpty {
      var globalSection = "  {:des \"Leader Key 2.0 - Global\"\n"
      globalSection += "   :rules [\n"
      globalSection += globalRulesWithoutActivation.joined(separator: "\n")
      globalSection += "\n   ]}"
      rules.append(globalSection)
    }
    
    // 3. Create app-specific sections (without activations)
    for (alias, manipulators) in appSections {
      let appRulesWithoutActivation = Array(manipulators.dropFirst())
      if !appRulesWithoutActivation.isEmpty {
        var appSection = "  {:des \"Leader Key 2.0 - \(alias)\"\n"
        appSection += "   :rules [\n"
        appSection += appRulesWithoutActivation.joined(separator: "\n")
        appSection += "\n   ]}"
        rules.append(appSection)
      }
    }
    
    // Build final EDN structure
    var result = ";; Goku Configuration for Leader Key 2.0 - Unified\n"
    result += ";; Generated state machine with all app configs\n"
    result += ";; Global: Cmd+K | App-specific: Cmd+Shift+K\n\n"
    result += "{\n"
    
    // Add templates section for shell commands
    result += " :templates {\n"
    result += "   :shell \"%s\"\n"
    result += " }\n\n"
    
    // Add applications section if we have app configs
    if !applications.isEmpty {
      result += applications + "\n\n"
    }
    
    // Add main section with multiple rule objects
    result += " :main [\n"
    result += rules.joined(separator: "\n\n")
    result += "\n ]\n"
    result += "}"
    
    return result
  }
}
