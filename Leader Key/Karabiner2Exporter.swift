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
    let stateId: Int32
    let path: [String]          // Path in key notation (e.g., ["o", "a"])
    let profileId: UUID?        // Profile ID this mapping belongs to
    let appAlias: String?        // App alias if app-specific
    let bundleId: String?        // Bundle ID if app-specific
    let actionType: String       // "action" or "group"
    let actionTypeRaw: String?   // The raw action type (.application, .command, .url, etc.)
    let actionValue: String?     // The actual action value to execute
    let actionLabel: String?     // Display label for the action
  }

  // Different initial states for different activation types
  // Note: Global activation is deprecated - use profile-based shortcuts
  private static let fallbackInitialStateId: Int32 = 2
  private static let inactiveStateId: Int32 = 0

  // Legacy constant for backward compatibility (previously globalInitialStateId)
  private static let initialStateId: Int32 = 1

  static func generateGokuEDN(from config: UserConfig, bundleId: String? = nil) -> String {
    let (stateTree, _) = buildStateTree(from: config.root, appAlias: nil, bundleId: bundleId, profileId: nil)
    let manipulators = generateManipulators(from: stateTree, bundleId: bundleId)

    return formatGokuEDN(manipulators: manipulators, bundleId: bundleId)
  }

  // Generate unified EDN for all profiles at once
  static func generateAllProfilesEDN(
    allProfileConfigs: [(profile: LeaderKeyProfile, fallbackConfig: UserConfig, appConfigs: [(bundleId: String, config: UserConfig, customName: String?)])]
  ) -> (edn: String, stateMappings: [StateMapping]) {
    debugLog("[Karabiner2Exporter] generateAllProfilesEDN called with \(allProfileConfigs.count) profiles")

    var allSections: [(name: String, groups: [ManipulatorGroup])] = []
    var allStateMappings: [StateMapping] = []
    var allActivationRules: [String] = []
    var allApplications: [(bundleId: String, alias: String)] = []
    var globalUsedAliases = Set<String>()

    // Process each profile
    for (profileIndex, profileConfig) in allProfileConfigs.enumerated() {
      let profile = profileConfig.profile
      let fallbackConfig = profileConfig.fallbackConfig
      let appConfigs = profileConfig.appConfigs

      debugLog("[Karabiner2Exporter] Processing profile \(profileIndex): \(profile.name)")

      // Generate app aliases for this profile
      var appAliases: [(bundleId: String, alias: String, config: UserConfig)] = []

      for (bundleId, config, customName) in appConfigs {
        if bundleId.contains(".meta") {
          continue
        }

        var alias = generateAppAlias(from: bundleId, customName: customName)

        // Ensure global uniqueness across all profiles
        var counter = 1
        let baseAlias = alias
        while globalUsedAliases.contains(alias) {
          alias = "\(baseAlias)_\(counter)"
          counter += 1
        }
        globalUsedAliases.insert(alias)

        appAliases.append((bundleId: bundleId, alias: alias, config: config))
        allApplications.append((bundleId: bundleId, alias: alias))
      }

      // Generate app-specific sections for this profile
      for (bundleId, alias, config) in appAliases {
        let appInitialStateId = generateAppInitialStateIdForProfile(appAlias: alias, profileIndex: profileIndex)
        let (appStateTree, appMappings) = buildStateTree(
          from: config.root,
          appAlias: alias,
          bundleId: bundleId,
          profileId: profile.id,
          initialStateId: appInitialStateId
        )
        allStateMappings.append(contentsOf: appMappings)

        let (appActivation, appGroups) = generateManipulatorsForUnifiedHierarchical(
          from: appStateTree,
          appAlias: alias,
          bundleId: bundleId,
          activationKey: profileShortcutToGokuKey(profile: profile),
          initialStateId: appInitialStateId,
          profile: profile
        )
        allActivationRules.append(appActivation)

        // Find custom name from original appConfigs
        let customName = appConfigs.first(where: { $0.bundleId == bundleId })?.customName
        let appName = customName ?? alias
        allSections.append((name: "Leader Key - \(profile.name) - \(appName)", groups: appGroups))
      }

      // Generate fallback section for this profile
      let fallbackRoot = fallbackConfig.getFallbackConfig()
      let (profileRangeStart, _) = getProfileStateIdRange(profileIndex: profileIndex)
      let fallbackInitialId = profileRangeStart + 2 // Unique fallback ID within profile's range

      let (fallbackStateTree, fallbackMappings) = buildStateTree(
        from: fallbackRoot,
        appAlias: nil,
        bundleId: "__FALLBACK__",
        profileId: profile.id,
        initialStateId: fallbackInitialId
      )
      allStateMappings.append(contentsOf: fallbackMappings)

      let (fallbackActivation, fallbackGroups) = generateManipulatorsForUnifiedHierarchical(
        from: fallbackStateTree,
        appAlias: nil,
        bundleId: "__FALLBACK__",
        activationKey: profileShortcutToGokuKey(profile: profile),
        initialStateId: fallbackInitialId,
        profile: profile
      )
      allActivationRules.append(fallbackActivation)
      allSections.append((name: "Leader Key - \(profile.name) - Fallback", groups: fallbackGroups))
    }

    // Create unified activation section with all profiles' activations
    if !allActivationRules.isEmpty {
      // Add escape and settings rules for all profiles
      for profileConfig in allProfileConfigs {
        let profile = profileConfig.profile
        let varNames = getProfileVariableNames(profile: profile)

        // Clear both global and profile-specific variables on escape/settings
        let escapeRule = "   [:escape [[\"leaderkey_active\" 0] [\"\(varNames.activeVar)\" 0] [\"\(varNames.appSpecificVar)\" 0] [\"\(varNames.stickyVar)\" 0] [\"\(varNames.stateVar)\" 0] [:shell \"/usr/local/bin/leaderkey-cli deactivate\"]] :\(varNames.activeVar)]"
        let settingsRule = "   [{:key :comma :modi :command} [[\"leaderkey_active\" 0] [\"\(varNames.activeVar)\" 0] [\"\(varNames.appSpecificVar)\" 0] [\"\(varNames.stickyVar)\" 0] [\"\(varNames.stateVar)\" 0] [:shell \"/usr/local/bin/leaderkey-cli deactivate\"] [:shell \"/usr/local/bin/leaderkey-cli settings\"]] :\(varNames.activeVar)]"

        allActivationRules.append(escapeRule)
        allActivationRules.append(settingsRule)
      }

      let activationSection = (
        name: "Leader Key - Activation Shortcuts",
        groups: [ManipulatorGroup(condition: nil, rules: allActivationRules)]
      )

      // Insert activation section at the beginning
      allSections.insert(activationSection, at: 0)
    }

    // Add modifier pass-through section
    let modifierPassThroughSection = (
      name: "Leader Key - Modifier Pass-Through",
      groups: [ManipulatorGroup(
        condition: nil,
        rules: generateModifierPassThroughRules(profiles: allProfileConfigs.map { $0.profile })
      )]
    )
    allSections.insert(modifierPassThroughSection, at: 1)

    // Generate applications section
    let applications = generateApplicationsSectionFromPairs(allApplications)

    // Format the final EDN
    let ednContent = formatHierarchicalEDN(
      applications: applications,
      sections: allSections
    )

    return (edn: ednContent, stateMappings: allStateMappings)
  }
  
  // Generate unified EDN with hierarchical organization and :condi grouping
  // Returns: (ednContent, stateMappings)
  static func generateUnifiedGokuEDNHierarchical(
    fallbackConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)],
    profile: LeaderKeyProfile? = nil
  ) -> (edn: String, stateMappings: [StateMapping]) {
    debugLog("[Karabiner2Exporter] generateUnifiedGokuEDNHierarchical called with \(appConfigs.count) app configs, profile: \(profile?.name ?? "default")")
    
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
    
    // 3. Structure to hold all :des sections and activations
    var desSections: [(name: String, groups: [ManipulatorGroup])] = []
    var allStateMappings: [StateMapping] = []
    var allActivations: [String] = []  // Collect all activation rules
    
    // 4. Skip global mode section - we only use fallback and app-specific configs now
    
    // 5. Generate app-specific sections FIRST (most specific)
    for (bundleId, alias, config) in appAliases {
      let appInitialStateId = generateAppInitialStateId(appAlias: alias)
      let (appStateTree, appMappings) = buildStateTree(
        from: config.root,
        appAlias: alias,
        bundleId: bundleId,
        profileId: profile?.id,
        initialStateId: appInitialStateId
      )
      allStateMappings.append(contentsOf: appMappings)
      
      // App-specific configs no longer use separate shortcuts - they're always activated through the profile shortcut
      // The app becomes active when it's frontmost
      let (appActivation, appGroups) = generateManipulatorsForUnifiedHierarchical(
        from: appStateTree,
        appAlias: alias,
        bundleId: bundleId,
        activationKey: profileShortcutToGokuKey(profile: profile),  // Use profile's shortcut
        initialStateId: appInitialStateId,
        profile: profile
      )
      allActivations.append(appActivation)
      
      // Find custom name from original appConfigs
      let customName = appConfigs.first(where: { $0.bundleId == bundleId })?.customName
      let appName = customName ?? alias
      desSections.append((name: "Leader Key - \(appName)", groups: appGroups))
    }
    
    // 6. Generate fallback mode section
    // Load the fallback config using UserConfig's method
    let fallbackRoot = fallbackConfig.getFallbackConfig()
    
    // Build state tree for fallback config
    let (fallbackStateTree, fallbackMappings) = buildStateTree(
      from: fallbackRoot,
      appAlias: nil,
      bundleId: "__FALLBACK__",
      profileId: profile?.id,
      initialStateId: fallbackInitialStateId
    )
    allStateMappings.append(contentsOf: fallbackMappings)
    
    // Generate manipulators for fallback - uses same profile shortcut
    let (fallbackActivation, fallbackGroups) = generateManipulatorsForUnifiedHierarchical(
      from: fallbackStateTree,
      appAlias: nil,
      bundleId: "__FALLBACK__",
      activationKey: profileShortcutToGokuKey(profile: profile),  // Use profile's shortcut
      initialStateId: fallbackInitialStateId,
      profile: profile
    )
    allActivations.append(fallbackActivation)
    desSections.append((name: "Leader Key - Fallback Mode", groups: fallbackGroups))
    
    // 8. Create activation section at the beginning with escape and settings rules
    // Get profile-specific variable names
    let varNames = getProfileVariableNames(profile: profile)
    
    // Add single escape rule that works when any Leader Key mode is active (also resets sticky mode and global active)
    let escapeRule = "   [:escape [[\"leaderkey_active\" 0] [\"\(varNames.activeVar)\" 0] [\"\(varNames.appSpecificVar)\" 0] [\"\(varNames.stickyVar)\" 0] [\"\(varNames.stateVar)\" 0] [:shell \"/usr/local/bin/leaderkey-cli deactivate\"]] :\(varNames.activeVar)]"
    // Add cmd+comma rule to deactivate Leader Key and open settings from any active layer
    let settingsRule = "   [{:key :comma :modi :command} [[\"leaderkey_active\" 0] [\"\(varNames.activeVar)\" 0] [\"\(varNames.appSpecificVar)\" 0] [\"\(varNames.stickyVar)\" 0] [\"\(varNames.stateVar)\" 0] [:shell \"/usr/local/bin/leaderkey-cli deactivate\"] [:shell \"/usr/local/bin/leaderkey-cli settings\"]] :\(varNames.activeVar)]"
    
    var activationRules = allActivations
    activationRules.append(escapeRule)
    activationRules.append(settingsRule)
    
    let activationSection = (
      name: "Leader Key - Activation Shortcuts",
      groups: [ManipulatorGroup(condition: nil, rules: activationRules)]
    )
    
    // Insert activation section at the beginning
    var allSections = [activationSection]
    
    // Add modifier pass-through section right after activation
    let modifierPassThroughSection = (
      name: "Leader Key - Modifier Pass-Through",
      groups: [ManipulatorGroup(
        condition: nil,
        rules: [
          "   [:##left_shift :left_shift :\(varNames.activeVar)]",
          "   [:##right_shift :right_shift :\(varNames.activeVar)]",
          "   [:##left_command :left_command :\(varNames.activeVar)]",
          "   [:##right_command :right_command :\(varNames.activeVar)]",
          "   [:##left_option :left_option :\(varNames.activeVar)]",
          "   [:##right_option :right_option :\(varNames.activeVar)]",
          "   [:##left_control :left_control :\(varNames.activeVar)]",
          "   [:##right_control :right_control :\(varNames.activeVar)]"
        ]
      )]
    )
    allSections.append(modifierPassThroughSection)
    
    allSections.append(contentsOf: desSections)
    
    // 8. Format as hierarchical EDN
    let ednContent = formatUnifiedGokuEDNHierarchical(
      applications: applications,
      desSections: allSections
    )
    
    return (edn: ednContent, stateMappings: allStateMappings)
  }
  
  // Generate unified EDN with all app configs in a single file (legacy flat version)
  // DEPRECATED: Use generateUnifiedGokuEDNHierarchical instead
  // Returns: (ednContent, stateMappings)
  static func generateUnifiedGokuEDN(
    fallbackConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)],
    profile: LeaderKeyProfile? = nil
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
    
    // 3. Skip global manipulators - we only use fallback and app-specific configs now
    var allStateMappings: [StateMapping] = []

    // 4. Generate app-specific manipulators using profile shortcuts
    var appSections: [(alias: String, manipulators: [String])] = []
    for (bundleId, alias, config) in appAliases {
      let appInitialStateId = generateAppInitialStateId(appAlias: alias)
      let (appStateTree, appMappings) = buildStateTree(from: config.root, appAlias: alias, bundleId: bundleId, profileId: profile?.id, initialStateId: appInitialStateId)
      allStateMappings.append(contentsOf: appMappings)
      let manipulators = generateManipulatorsForUnified(
        from: appStateTree,
        appAlias: alias,
        bundleId: bundleId,
        activationKey: profileShortcutToGokuKey(profile: profile),  // Use profile's shortcut
        initialStateId: appInitialStateId
      )
      appSections.append((alias: alias, manipulators: manipulators))
    }
    
    // 5. Generate fallback-only activation manipulator using profile shortcut
    // Using app-specific variables but with __FALLBACK__ bundleId
    let fallbackManipulator = generateUnifiedActivationManipulator(
      appAlias: nil,
      bundleId: "__FALLBACK__",
      activationKey: profileShortcutToGokuKey(profile: profile),  // Use profile's shortcut
      initialStateId: fallbackInitialStateId
    )
    
    // 6. Format unified EDN
    let ednContent = formatUnifiedGokuEDN(
      applications: applications,
      globalManipulators: [],  // No global manipulators anymore
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

  // Generate applications section from bundle ID and alias pairs
  private static func generateApplicationsSectionFromPairs(_ pairs: [(bundleId: String, alias: String)]) -> String {
    guard !pairs.isEmpty else { return "" }

    var appLines: [String] = []
    for (bundleId, alias) in pairs {
      appLines.append("   :\(alias) [\"\(bundleId)\"]")
    }

    return " :applications {\n\(appLines.joined(separator: "\n"))\n }"
  }

  // Generate modifier pass-through rules for multiple profiles
  private static func generateModifierPassThroughRules(profiles: [LeaderKeyProfile]) -> [String] {
    var rules: [String] = []

    // Use the global leaderkey_active variable for simpler conditions
    // This applies to ANY active Leader Key profile
    let modifiers = ["left_shift", "right_shift", "left_command", "right_command",
                    "left_option", "right_option", "left_control", "right_control"]

    for modifier in modifiers {
      // Use global variable so modifiers pass through when ANY profile is active
      let rule = "   [:##\(modifier) :\(modifier) :leaderkey_active]"
      rules.append(rule)
    }

    return rules
  }

  // Format the final hierarchical EDN with sections
  private static func formatHierarchicalEDN(applications: String, sections: [(name: String, groups: [ManipulatorGroup])]) -> String {
    var ednContent = ""

    // Add applications section if not empty
    if !applications.isEmpty {
      ednContent += applications + "\n\n"
    }

    // Add main rules
    ednContent += " :main [\n"

    // Convert sections to EDN format
    var formattedSections: [String] = []
    for section in sections {
      var sectionContent = "  {:des \"\(section.name)\"\n"
      sectionContent += "   :rules [\n"

      // Convert ManipulatorGroup rules to strings
      var allRules: [String] = []
      for group in section.groups {
        allRules.append(contentsOf: group.rules)
      }

      sectionContent += allRules.joined(separator: "\n")
      sectionContent += "\n   ]}"
      formattedSections.append(sectionContent)
    }

    ednContent += formattedSections.joined(separator: "\n\n")
    ednContent += "\n ]"

    return ednContent
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

  private static func buildStateTree(from group: Group, appAlias: String? = nil, bundleId: String? = nil, profileId: UUID? = nil, initialStateId: Int32 = initialStateId) -> ([StateNode], [StateMapping]) {
    var nodes: [StateNode] = []
    var stateMappings: [StateMapping] = []
    var queue: [(item: ActionOrGroup, path: [String], originalPath: [String], parentStateId: Int32, parentGroupHasStickyMode: Bool)] = []

    // The root group's sticky mode applies to its direct children
    let rootHasStickyMode = group.stickyMode ?? false
    for item in group.actions {
      queue.append((item: item, path: [], originalPath: [], parentStateId: initialStateId, parentGroupHasStickyMode: rootHasStickyMode))
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
            isTerminal: true,
            parentGroupHasStickyMode: current.parentGroupHasStickyMode
          ))
        
        // Create state mapping for this action
        let mapping = StateMapping(
          stateId: terminalStateId,  // Use terminal's own unique state ID
          path: currentOriginalPath,
          profileId: profileId,
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
            isTerminal: false,
            parentGroupHasStickyMode: current.parentGroupHasStickyMode
          ))
        
        // Create state mapping for this group to enable UI navigation
        let groupMapping = StateMapping(
          stateId: stateId,
          path: currentOriginalPath,
          profileId: profileId,
          appAlias: appAlias,
          bundleId: bundleId,
          actionType: "group",
          actionTypeRaw: nil,
          actionValue: nil,
          actionLabel: subgroup.label
        )
        stateMappings.append(groupMapping)

        // Check if this subgroup has sticky mode enabled
        let subgroupHasStickyMode = subgroup.stickyMode ?? false
        for subItem in subgroup.actions {
          queue.append((item: subItem, path: currentPath, originalPath: currentOriginalPath, parentStateId: stateId, parentGroupHasStickyMode: subgroupHasStickyMode))
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

  // Generate profile-specific state ID range
  private static func getProfileStateIdRange(profileIndex: Int) -> (start: Int32, end: Int32) {
    // Each profile gets 100,000 state IDs for better distribution and no collision risk
    // Profile 0: 100,000-199,999, Profile 1: 200,000-299,999, etc.
    let start = Int32(100_000 + (profileIndex * 100_000))
    let end = start + 99_999
    return (start, end)
  }

  // Generate app initial state ID with profile-specific range
  private static func generateAppInitialStateIdForProfile(appAlias: String, profileIndex: Int) -> Int32 {
    let (rangeStart, rangeEnd) = getProfileStateIdRange(profileIndex: profileIndex)
    let baseId = generateStateId(from: ["app_initial", appAlias])
    // Keep within profile's range
    let offset = abs(baseId) % Int32(rangeEnd - rangeStart)
    return rangeStart + offset
  }

  private static func generateManipulators(from nodes: [StateNode], bundleId: String? = nil) -> [String] {
    var manipulators: [String] = []

    manipulators.append(generateActivationManipulator(bundleId: bundleId))
    
    // Collect all unique state IDs for escape handlers
    var allStateIds = Set<Int32>([initialStateId])

    var stateTransitions: [Int32: [String: (toState: Int32, hasStickyMode: Bool)]] = [:]
    var terminalActions: [Int32: [String: (path: String, terminalStateId: Int32, hasStickyMode: Bool, node: StateNode)]] = [:]
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
        terminalActions[parentStateId]?[key] = (path: pathString, terminalStateId: node.stateId, hasStickyMode: node.parentGroupHasStickyMode, node: node)
      } else {
        if stateTransitions[parentStateId] == nil {
          stateTransitions[parentStateId] = [:]
        }
        // Check if the target group has sticky mode
        let groupHasStickyMode: Bool
        if case .group(let targetGroup) = node.item {
          groupHasStickyMode = targetGroup.stickyMode ?? false
        } else {
          groupHasStickyMode = false
        }
        stateTransitions[parentStateId]?[key] = (toState: node.stateId, hasStickyMode: groupHasStickyMode)
        allStateIds.insert(node.stateId)  // Also collect target state IDs
      }
    }

    for (fromState, transitions) in stateTransitions {
      for (key, transitionData) in transitions {
        manipulators.append(
          generateStateTransition(key: key, fromState: fromState, toState: transitionData.toState, bundleId: bundleId))
      }
    }

    for (fromState, actions) in terminalActions {
      for (key, actionData) in actions {
        manipulators.append(
          generateTerminalAction(key: key, fromState: fromState, toState: actionData.terminalStateId, actionPath: actionData.path, hasStickyMode: actionData.hasStickyMode, bundleId: bundleId, node: actionData.node))
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
  // Returns: (activationRule, modeGroups) - activation separated from mode rules
  private static func generateManipulatorsForUnifiedHierarchical(
    from nodes: [StateNode],
    appAlias: String?,
    bundleId: String?,
    activationKey: String,
    initialStateId: Int32,
    profile: LeaderKeyProfile? = nil
  ) -> (activation: String, groups: [ManipulatorGroup]) {
    var groups: [ManipulatorGroup] = []
    
    // 1. Generate activation rule separately (will be returned, not added to groups)
    let activationRule = generateUnifiedActivationManipulator(
      appAlias: appAlias,
      bundleId: bundleId,
      activationKey: activationKey,
      initialStateId: initialStateId,
      profile: profile
    )
    
    // Collect and organize rules by state
    var stateTransitions: [Int32: [String: (toState: Int32, hasStickyMode: Bool)]] = [:]
    var terminalActions: [Int32: [String: (path: String, terminalStateId: Int32, hasStickyMode: Bool, node: StateNode)]] = [:]
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
        terminalActions[parentStateId]?[key] = (path: pathString, terminalStateId: node.stateId, hasStickyMode: node.parentGroupHasStickyMode, node: node)
      } else {
        if stateTransitions[parentStateId] == nil {
          stateTransitions[parentStateId] = [:]
        }
        // Check if the target group has sticky mode
        let groupHasStickyMode: Bool
        if case .group(let targetGroup) = node.item {
          groupHasStickyMode = targetGroup.stickyMode ?? false
        } else {
          groupHasStickyMode = false
        }
        stateTransitions[parentStateId]?[key] = (toState: node.stateId, hasStickyMode: groupHasStickyMode)
        allStateIds.insert(node.stateId)
      }
    }
    
    // Get profile-specific variable names
    let varNames = getProfileVariableNames(profile: profile)
    
    // 2. Mode-level condition group
    let modeCondition: String
    if let alias = appAlias {
      // App-specific mode
      modeCondition = "[:condi :\(alias) :\(varNames.appSpecificVar)]"
    } else if bundleId == "__FALLBACK__" {
      // Fallback is now treated as app-specific
      modeCondition = "[:condi :\(varNames.appSpecificVar)]"
    } else {
      // This case shouldn't happen anymore - we only have app-specific and fallback
      modeCondition = "[:condi :\(varNames.appSpecificVar)]"
    }
    
    // No longer generating escape handlers per state - using single global escape
    var modeRules: [String] = []
    
    // 3. Group rules by state with nested conditions
    for stateId in allStateIds.sorted() {
      var stateRules: [String] = []
      var definedKeys = Set<String>()
      
      // Add transitions from this state
      if let transitions = stateTransitions[stateId] {
        for (key, transitionData) in transitions.sorted(by: { $0.key < $1.key }) {
          definedKeys.insert(key.lowercased())
          stateRules.append(
            generateUnifiedStateTransition(key: key, fromState: stateId, toState: transitionData.toState, hasStickyMode: transitionData.hasStickyMode, appAlias: appAlias, profile: profile)
          )
        }
      }
      
      // Add terminal actions from this state
      if let actions = terminalActions[stateId] {
        for (key, actionData) in actions.sorted(by: { $0.key < $1.key }) {
          definedKeys.insert(key.lowercased())
          stateRules.append(
            generateUnifiedTerminalAction(
              key: key,
              fromState: stateId,
              toState: actionData.terminalStateId,
              actionPath: actionData.path,
              hasStickyMode: actionData.hasStickyMode,
              appAlias: appAlias,
              node: actionData.node,
              profile: profile
            )
          )
        }
      }
      
      if !stateRules.isEmpty {
        // Add catch-all rules to consume undefined keys (must be last)
        let catchAllRules = generateCatchAllRules(
          fromState: stateId,
          appAlias: appAlias,
          definedKeys: definedKeys,
          profile: profile
        )
        stateRules.append(contentsOf: catchAllRules)
        
        // Add state-specific condition
        let stateCondition: String
        if let alias = appAlias {
          // App-specific state
          stateCondition = "[:condi :\(alias) :\(varNames.appSpecificVar) [\"\(varNames.stateVar)\" \(stateId)]]"
        } else if bundleId == "__FALLBACK__" {
          // Fallback state (treated as app-specific)
          stateCondition = "[:condi :\(varNames.appSpecificVar) [\"\(varNames.stateVar)\" \(stateId)]]"
        } else {
          stateCondition = "[:condi :\(varNames.appSpecificVar) [\"\(varNames.stateVar)\" \(stateId)]]"
        }
        
        modeRules.append(stateCondition)
        modeRules.append(contentsOf: stateRules)
      }
    }
    
    if !modeRules.isEmpty {
      groups.append(ManipulatorGroup(condition: modeCondition, rules: modeRules))
    }
    
    return (activation: activationRule, groups: groups)
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
    
    var stateTransitions: [Int32: [String: (toState: Int32, hasStickyMode: Bool)]] = [:]
    var terminalActions: [Int32: [String: (path: String, terminalStateId: Int32, hasStickyMode: Bool, node: StateNode)]] = [:]
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
        terminalActions[parentStateId]?[key] = (path: pathString, terminalStateId: node.stateId, hasStickyMode: node.parentGroupHasStickyMode, node: node)
      } else {
        if stateTransitions[parentStateId] == nil {
          stateTransitions[parentStateId] = [:]
        }
        // Check if the target group has sticky mode
        let groupHasStickyMode: Bool
        if case .group(let targetGroup) = node.item {
          groupHasStickyMode = targetGroup.stickyMode ?? false
        } else {
          groupHasStickyMode = false
        }
        stateTransitions[parentStateId]?[key] = (toState: node.stateId, hasStickyMode: groupHasStickyMode)
        allStateIds.insert(node.stateId)
      }
    }
    
    // Generate state transitions with cleaner app conditions
    for (fromState, transitions) in stateTransitions {
      for (key, transitionData) in transitions {
        manipulators.append(
          generateUnifiedStateTransition(key: key, fromState: fromState, toState: transitionData.toState, hasStickyMode: transitionData.hasStickyMode, appAlias: appAlias)
        )
      }
    }
    
    // Generate terminal actions with cleaner app conditions
    for (fromState, actions) in terminalActions {
      for (key, actionData) in actions {
        manipulators.append(
          generateUnifiedTerminalAction(key: key, fromState: fromState, toState: actionData.terminalStateId, actionPath: actionData.path, hasStickyMode: actionData.hasStickyMode, appAlias: appAlias, node: actionData.node)
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

    // When escape is pressed, always reset sticky mode along with other states
    if let bundleId = bundleId {
      return """
           [:escape 
            [[\"leader_state\" \(inactiveStateId)] [\"leaderkey_sticky\" 0] [:shell "\(deactivateCmd)"]] 
            {:conditions [[:frontmost_application_is ["\(bundleId)"]] [\"leader_state\" \(stateId)]]}]
        """
    } else {
      return """
           [:escape [[\"leader_state\" \(inactiveStateId)] [\"leaderkey_sticky\" 0] [:shell "\(deactivateCmd)"]] [\"leader_state\" \(stateId)]]
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

  private static func generateTerminalAction(key: String, fromState: Int32, toState: Int32, actionPath: String, hasStickyMode: Bool, bundleId: String? = nil, node: StateNode? = nil)
    -> String
  {
    let karabinerKey = convertToKarabinerKey(key)
    let cliPath = "/usr/local/bin/leaderkey-cli"
    
    // Check if this is a shortcut action that can be exported directly
    if let node = node,
       case .action(let action) = node.item,
       action.type == .shortcut,
       canExportShortcutToKarabiner(action.value) {
      
      // Convert shortcut to Karabiner format
      let shortcutKeys = convertShortcutToKarabinerFormat(action.value)
      
      // Build the action sequence: deactivate + execute shortcuts
      var actions = "[:shell \"\(cliPath) deactivate\"]"
      for shortcutKey in shortcutKeys {
        actions += " \(shortcutKey)"
      }
      
      // Clear all variables since we're deactivating
      let stateVars = "[\"leader_state\" \(inactiveStateId)] [\"leaderkey_active\" 0] [\"leaderkey_appspecific\" 0]"
      
      if let bundleId = bundleId {
        return """
             [\(karabinerKey) 
              [\(actions) \(stateVars)] 
              {:conditions [[:frontmost_application_is ["\(bundleId)"]] [\"leader_state\" \(fromState)]]}]
          """
      } else {
        return """
             [\(karabinerKey) [\(actions) \(stateVars)] [\"leader_state\" \(fromState)]]
          """
      }
    }
    
    // Default behavior for non-shortcut actions or complex shortcuts
    // Use stateid command with optional sticky flag
    let commandSuffix = hasStickyMode ? " sticky" : ""
    let sequenceCmd =
      FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) stateid \(toState)\(commandSuffix)"
      : "echo 'stateid \(toState)\(commandSuffix)' | nc -U /tmp/leaderkey.sock"

    // If parent group has sticky mode, keep leader_state at fromState and set sticky flag
    // Otherwise, reset everything
    let stateVars: String
    if hasStickyMode {
      // Keep leader_state at current group (fromState), set sticky flag
      stateVars = "[\"leaderkey_sticky\" 1]"
    } else {
      // Normal reset - clear everything
      stateVars = "[\"leader_state\" \(inactiveStateId)] [\"leaderkey_active\" 0] [\"leaderkey_appspecific\" 0]"
    }
    
    if let bundleId = bundleId {
      return """
           [\(karabinerKey) 
            [[:shell "\(sequenceCmd)"] \(stateVars)] 
            {:conditions [[:frontmost_application_is ["\(bundleId)"]] [\"leader_state\" \(fromState)]]}]
        """
    } else {
      return """
           [\(karabinerKey) [[:shell "\(sequenceCmd)"] \(stateVars)] [\"leader_state\" \(fromState)]]
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

  // Helper function to generate profile-specific variable names
  private static func getProfileVariableNames(profile: LeaderKeyProfile?) -> (
    stateVar: String,
    activeVar: String,
    appSpecificVar: String,
    stickyVar: String
  ) {
    if let profile = profile {
      // Use profile ID to create unique variable names (Karabiner variables must be alphanumeric)
      let profileSuffix = profile.id.uuidString.replacingOccurrences(of: "-", with: "_").lowercased()
      return (
        stateVar: "leader_state_\(profileSuffix)",
        activeVar: "leaderkey_active_\(profileSuffix)",
        appSpecificVar: "leaderkey_appspecific_\(profileSuffix)",
        stickyVar: "leaderkey_sticky_\(profileSuffix)"
      )
    } else {
      // Default variable names for backward compatibility
      return (
        stateVar: "leader_state",
        activeVar: "leaderkey_active",
        appSpecificVar: "leaderkey_appspecific",
        stickyVar: "leaderkey_sticky"
      )
    }
  }
  
  // Helper function to convert a profile's KeyboardShortcut to Goku format
  private static func profileShortcutToGokuKey(profile: LeaderKeyProfile?) -> String {
    // If no profile provided, use default Cmd+K
    guard let profile = profile else {
      return "{:key :k :modi [:command]}"
    }
    
    // Try to get the shortcut from KeyboardShortcuts
    if let shortcut = KeyboardShortcuts.getShortcut(for: profile.keyboardShortcutName) {
      var modifiers: [String] = []
      
      // Convert modifiers to Goku format
      if shortcut.modifiers.contains(.command) {
        modifiers.append(":command")
      }
      if shortcut.modifiers.contains(.shift) {
        modifiers.append(":shift")
      }
      if shortcut.modifiers.contains(.option) {
        modifiers.append(":option")
      }
      if shortcut.modifiers.contains(.control) {
        modifiers.append(":control")
      }
      
      // Convert key to Goku format
      // Map carbon key code to key character - simplified mapping for common keys
      let keyChar: String
      switch shortcut.carbonKeyCode {
      case 0: keyChar = "a"
      case 1: keyChar = "s"
      case 2: keyChar = "d"
      case 3: keyChar = "f"
      case 4: keyChar = "h"
      case 5: keyChar = "g"
      case 6: keyChar = "z"
      case 7: keyChar = "x"
      case 8: keyChar = "c"
      case 9: keyChar = "v"
      case 11: keyChar = "b"
      case 12: keyChar = "q"
      case 13: keyChar = "w"
      case 14: keyChar = "e"
      case 15: keyChar = "r"
      case 16: keyChar = "y"
      case 17: keyChar = "t"
      case 31: keyChar = "o"
      case 32: keyChar = "u"
      case 34: keyChar = "i"
      case 35: keyChar = "p"
      case 37: keyChar = "l"
      case 38: keyChar = "j"
      case 40: keyChar = "k"
      case 41: keyChar = "semicolon"
      case 45: keyChar = "n"
      case 46: keyChar = "m"
      default: keyChar = "k"  // Default fallback
      }
      let gokuKey = ":\(keyChar)"
      
      // Build the Goku key string
      if modifiers.isEmpty {
        return "{:key \(gokuKey)}"
      } else {
        return "{:key \(gokuKey) :modi [\(modifiers.joined(separator: " "))]}"
      }
    }
    
    // Fallback to default if no shortcut set
    return "{:key :k :modi [:command]}"
  }
  
  // Unified manipulator generators with cleaner app alias conditions
  private static func generateUnifiedActivationManipulator(appAlias: String?, bundleId: String?, activationKey: String, initialStateId: Int32, profile: LeaderKeyProfile? = nil) -> String {
    let cliPath = "/usr/local/bin/leaderkey-cli"
    
    // Include bundleId in activation command for app-specific activations
    let activateCmd: String
    if let bundleId = bundleId {
      // App-specific activation with bundleId
      activateCmd = FileManager.default.fileExists(atPath: cliPath)
        ? "\(cliPath) activate \(bundleId)" : "echo 'activate \(bundleId)' | nc -U /tmp/leaderkey.sock"
    } else {
      // Fallback activation without bundleId
      activateCmd = FileManager.default.fileExists(atPath: cliPath)
        ? "\(cliPath) activate" : "echo 'activate' | nc -U /tmp/leaderkey.sock"
    }
    
    // Get profile-specific variable names
    let varNames = getProfileVariableNames(profile: profile)
    
    // Determine which mode variables to set (including global leaderkey_active)
    let modeVars: String
    if appAlias != nil || bundleId == "__FALLBACK__" {
      // App-specific mode (including fallback) - set both global and profile-specific
      modeVars = "[\"leaderkey_active\" 1] [\"\(varNames.activeVar)\" 1] [\"\(varNames.appSpecificVar)\" 1]"
    } else {
      // This shouldn't happen anymore - we only have app-specific mode
      modeVars = "[\"leaderkey_active\" 1] [\"\(varNames.activeVar)\" 1] [\"\(varNames.appSpecificVar)\" 1]"
    }
    
    if let alias = appAlias {
      // App-specific activation with simple app alias condition
      return "   [\(activationKey) [\(modeVars) [\"\(varNames.stateVar)\" \(initialStateId)] [:shell \"\(activateCmd)\"]] :\(alias)]"
    } else {
      // Fallback activation with no app condition
      return "   [\(activationKey) [\(modeVars) [\"\(varNames.stateVar)\" \(initialStateId)] [:shell \"\(activateCmd)\"]]]"
    }
  }
  
  private static func generateUnifiedEscapeHandler(forState stateId: Int32, appAlias: String?) -> String {
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let deactivateCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) deactivate" : "echo 'deactivate' | nc -U /tmp/leaderkey.sock"
    
    // Clear all mode variables on escape, including sticky mode
    let clearVars = "[\"leaderkey_active\" 0] [\"leaderkey_appspecific\" 0] [\"leaderkey_sticky\" 0] [\"leader_state\" \(inactiveStateId)]"
    
    if let alias = appAlias {
      // App-specific escape with combined conditions
      return "   [:escape [\(clearVars) [:shell \"\(deactivateCmd)\"]] [:\(alias) [\"leader_state\" \(stateId)]]]"
    } else {
      // Global escape with just state condition
      return "   [:escape [\(clearVars) [:shell \"\(deactivateCmd)\"]] [\"leader_state\" \(stateId)]]"
    }
  }
  
  private static func generateUnifiedStateTransition(key: String, fromState: Int32, toState: Int32, hasStickyMode: Bool, appAlias: String?, profile: LeaderKeyProfile? = nil) -> String {
    let karabinerKey = convertToKarabinerKey(key)
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let varNames = getProfileVariableNames(profile: profile)
    
    // Send state change notification to update UI
    let stateCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) stateid \(toState)"
      : "echo 'stateid \(toState)' | nc -U /tmp/leaderkey.sock"
    
    // Build action array
    var actions = "[\"\(varNames.stateVar)\" \(toState)] [:shell \"\(stateCmd)\"]"
    if hasStickyMode {
      actions += " [\"\(varNames.stickyVar)\" 1]"
    }
    
    if let alias = appAlias {
      // App-specific transition with combined conditions
      return "   [\(karabinerKey) [\(actions)] [:\(alias) [\"\(varNames.stateVar)\" \(fromState)]]]"
    } else {
      // Global transition with just state condition
      return "   [\(karabinerKey) [\(actions)] [\"\(varNames.stateVar)\" \(fromState)]]"
    }
  }
  
  // Check if a shortcut can be exported directly to Karabiner
  private static func canExportShortcutToKarabiner(_ shortcut: String) -> Bool {
    let parts = shortcut.split(separator: " ")
    for part in parts {
      let lower = part.lowercased()
      // Skip shortcuts with delays or complex key operations
      if lower.contains("delay:") || lower.contains("keydown:") || lower.contains("keyup:") {
        return false
      }
    }
    return true
  }
  
  // Convert LeaderKey shortcut format to Karabiner/Goku format
  private static func convertShortcutToKarabinerFormat(_ shortcut: String) -> [String] {
    let parts = shortcut.split(separator: " ").map(String.init)
    var karabinerKeys: [String] = []
    
    for part in parts {
      if part.lowercased() == "vk_none" || part.lowercased() == "release_modifiers" {
        karabinerKeys.append(":vk_none")
      } else {
        // Parse compact format like "CSa" to Karabiner format
        if let converted = parseCompactShortcutToKarabiner(part) {
          karabinerKeys.append(converted)
        }
      }
    }
    
    return karabinerKeys
  }
  
  // Parse a single compact shortcut like "CSa" to Karabiner format like ":!CSa"
  private static func parseCompactShortcutToKarabiner(_ shortcut: String) -> String? {
    guard !shortcut.isEmpty else { return nil }
    
    var modifierLetters = ""
    var remainingString = shortcut
    
    // Parse modifier characters: C=Cmd, S=Shift, O=Option, T=Control, F=Function
    while !remainingString.isEmpty {
      let firstChar = remainingString.first!
      var consumedModifier = false
      
      switch firstChar {
      case "C":  // Command
        modifierLetters += "C"
        consumedModifier = true
      case "S":  // Shift
        modifierLetters += "S"
        consumedModifier = true
      case "O":  // Option/Alt
        modifierLetters += "O"
        consumedModifier = true
      case "T":  // Control
        modifierLetters += "T"
        consumedModifier = true
      case "F":  // Function
        modifierLetters += "F"
        consumedModifier = true
      default:
        break
      }
      
      if consumedModifier {
        remainingString.removeFirst()
      } else {
        break
      }
    }
    
    // The rest is the key name
    var keyName = remainingString
    guard !keyName.isEmpty else { return nil }
    
    // Map descriptive names back to their special characters
    let descriptiveNameMap: [String: String] = [
      "question": "?",
      "exclamation": "!",
      "at": "@",
      "hash": "#",
      "dollar": "$",
      "percent": "%",
      "caret": "^",
      "ampersand": "&",
      "asterisk": "*",
      "parenleft": "(",
      "parenright": ")",
      "underscore": "_",
      "plus": "+",
      "braceleft": "{",
      "braceright": "}",
      "quote": "\"",
      "tilde": "~",
      "pipe": "|",
      "colon": ":",
      "less": "<",
      "greater": ">",
    ]
    
    // Check if the key name is a descriptive name that needs conversion
    if let specialChar = descriptiveNameMap[keyName.lowercased()] {
      keyName = specialChar
    }
    
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
      "<": "comma",
      ">": "period",
    ]
    
    // Check if it's a shifted special character
    if let shiftedKey = shiftedKeyMap[keyName] {
      // Add Shift modifier if not already present
      if !modifierLetters.contains("S") {
        modifierLetters += "S"
      }
      keyName = shiftedKey
    }
    
    // Map special keys to Karabiner notation
    let keyMap: [String: String] = [
      "space": "spacebar",
      "return": "return_or_enter",
      "enter": "return_or_enter",
      "tab": "tab",
      "delete": "delete_or_backspace",
      "backspace": "delete_or_backspace",
      "escape": "escape",
      "esc": "escape",
      "up": "up_arrow",
      "down": "down_arrow",
      "left": "left_arrow",
      "right": "right_arrow",
    ]
    
    // Get the mapped key or use the key lowercased
    let finalKey = keyMap[keyName.lowercased()] ?? keyName.lowercased()
    
    // Build the final format
    if !modifierLetters.isEmpty {
      // Format: :!CSa for Cmd+Shift+A (no brackets when used in action array)
      // The ! prefix indicates modifiers are present, followed by modifier letters
      return ":!\(modifierLetters)\(finalKey)"
    } else {
      // No modifiers, just the key
      return ":\(finalKey)"
    }
  }
  
  private static func generateUnifiedTerminalAction(key: String, fromState: Int32, toState: Int32, actionPath: String, hasStickyMode: Bool, appAlias: String?, node: StateNode? = nil, profile: LeaderKeyProfile? = nil) -> String {
    let karabinerKey = convertToKarabinerKey(key)
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let varNames = getProfileVariableNames(profile: profile)
    
    // Check if this is a shortcut action that can be exported directly
    if let node = node,
       case .action(let action) = node.item,
       action.type == .shortcut,
       canExportShortcutToKarabiner(action.value) {
      
      // Convert shortcut to Karabiner format
      let shortcutKeys = convertShortcutToKarabinerFormat(action.value)
      
      // Build the action sequence based on sticky mode
      var actions = ""
      let stateVars: String
      
      if hasStickyMode {
        // In sticky mode: just execute shortcuts and stay in current state
        for shortcutKey in shortcutKeys {
          actions += actions.isEmpty ? "\(shortcutKey)" : " \(shortcutKey)"
        }
        // Keep leader_state at current group, set sticky flag
        stateVars = "[\"\(varNames.stickyVar)\" 1]"
      } else {
        // Normal mode: deactivate + execute shortcuts
        actions = "[:shell \"\(cliPath) deactivate\"]"
        for shortcutKey in shortcutKeys {
          actions += " \(shortcutKey)"
        }
        // Clear all variables since we're deactivating
        stateVars = "[\"\(varNames.activeVar)\" 0] [\"\(varNames.appSpecificVar)\" 0] [\"\(varNames.stateVar)\" \(inactiveStateId)]"
      }
      
      if let alias = appAlias {
        // App-specific shortcut action
        return "   [\(karabinerKey) [\(actions) \(stateVars)] [:\(alias) [\"\(varNames.stateVar)\" \(fromState)]]]"
      } else {
        // Global shortcut action
        return "   [\(karabinerKey) [\(actions) \(stateVars)] [\"\(varNames.stateVar)\" \(fromState)]]"
      }
    }
    
    // Default behavior for non-shortcut actions or complex shortcuts
    let commandSuffix = hasStickyMode ? " sticky" : ""
    let sequenceCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) stateid \(toState)\(commandSuffix)"
      : "echo 'stateid \(toState)\(commandSuffix)' | nc -U /tmp/leaderkey.sock"
    
    // If parent group has sticky mode, keep leader_state at fromState and set sticky flag
    // Otherwise, reset everything
    let clearVars: String
    if hasStickyMode {
      // Keep leader_state at current group (fromState), set sticky flag
      clearVars = "[\"\(varNames.stickyVar)\" 1]"
    } else {
      // Normal reset - clear everything
      clearVars = "[\"\(varNames.activeVar)\" 0] [\"\(varNames.appSpecificVar)\" 0] [\"\(varNames.stateVar)\" \(inactiveStateId)]"
    }
    
    if let alias = appAlias {
      // App-specific terminal action with combined conditions
      return "   [\(karabinerKey) [[:shell \"\(sequenceCmd)\"] \(clearVars)] [:\(alias) [\"\(varNames.stateVar)\" \(fromState)]]]"
    } else {
      // Global terminal action with just state condition
      return "   [\(karabinerKey) [[:shell \"\(sequenceCmd)\"] \(clearVars)] [\"\(varNames.stateVar)\" \(fromState)]]"
    }
  }
  
  private static func generateCatchAllRules(fromState: Int32, appAlias: String?, definedKeys: Set<String>, profile: LeaderKeyProfile? = nil) -> [String] {
    // Use Goku's {:any :key_code} syntax to match any key with any modifiers
    // This replaces 50+ individual rules with a single catch-all rule
    var rules: [String] = []
    
    // Include shake command to provide visual feedback for undefined keys
    let cliPath = "/usr/local/bin/leaderkey-cli"
    let shakeCmd = FileManager.default.fileExists(atPath: cliPath)
      ? "\(cliPath) shake" : "echo 'shake' | nc -U /tmp/leaderkey.sock"
    
    let varNames = getProfileVariableNames(profile: profile)
    
    if let alias = appAlias {
      // App-specific catch-all with combined conditions (excluding sticky mode)
      rules.append("   [{:any :key_code :modi :any} [[:shell \"\(shakeCmd)\"] :vk_none] [:\(alias) [\"\(varNames.stateVar)\" \(fromState)] [\"\(varNames.stickyVar)\" 0]]]")
    } else {
      // Fallback catch-all with just state condition (excluding sticky mode)
      rules.append("   [{:any :key_code :modi :any} [[:shell \"\(shakeCmd)\"] :vk_none] [[\"\(varNames.stateVar)\" \(fromState)] [\"\(varNames.stickyVar)\" 0]]]")
    }
    
    return rules
  }
  
  private static func formatGokuEDN(manipulators: [String], bundleId: String? = nil) -> String {
    // Split manipulators into sections for better organization
    let activation = manipulators.first ?? ""
    let statesAndActions = manipulators.dropFirst()
    
    let appComment = bundleId != nil ? " for \(bundleId!)" : ""
    let description = "Leader Key 2.0 State Machine\(appComment)"
    
    // Apply alternative mappings to all manipulators
    let allManipulators = [activation] + statesAndActions
    let manipulatorsWithAlternatives = applyAlternativeKeyMappings(to: allManipulators)
    
    return """
      ;; Goku Configuration for Leader Key 2.0
      ;; Generated state machine with numeric state tracking
      ;; State 0 = inactive, State 1 = leader active, Other states = navigation states

      {
       :main [{:des "\(description)"
               :rules [
      \(manipulatorsWithAlternatives.joined(separator: "\n"))
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
        
        // Add all rules in this group with alternative mappings applied
        let rulesWithAlternatives = applyAlternativeKeyMappings(to: group.rules)
        rules.append(contentsOf: rulesWithAlternatives)
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
    edn += "   :leaderkey {:input_source_id \"^com.apple.keylayout.US$\"}\n"
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
    
    // Extract activation shortcuts (first item is always activation)
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
    
    // 2. Create Main section (without activation)
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
  
  // MARK: - EDN Injection into Main Karabiner Config
  
  enum InjectionResult {
    case success
    case noMarkersFound
    case partialMarkersFound(missing: [String])
    case fileNotFound
    case error(String)
  }
  
  static func injectIntoMainKarabinerEDN(applications: String, mainRules: [String], autoAddMarkers: Bool = false, preserveActivationShortcuts: Bool = false) -> InjectionResult {
    let configPath = NSHomeDirectory() + "/.config/karabiner.edn"
    
    // Marker constants for efficient reuse
    let appStartMarker = ";;; LEADERKEY_APPLICATIONS_START"
    let appEndMarker = ";;; LEADERKEY_APPLICATIONS_END"
    let mainStartMarker = ";;; LEADERKEY_MAIN_START"
    let mainEndMarker = ";;; LEADERKEY_MAIN_END"
    
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
    
    // Check which markers exist
    let hasAppStart = content.contains(appStartMarker)
    let hasAppEnd = content.contains(appEndMarker)
    let hasMainStart = content.contains(mainStartMarker)
    let hasMainEnd = content.contains(mainEndMarker)
    
    let hasAppMarkers = hasAppStart && hasAppEnd
    let hasMainMarkers = hasMainStart && hasMainEnd
    
    // Determine if we should proceed
    if !hasAppMarkers && !hasMainMarkers {
      if autoAddMarkers {
        // Try to add markers automatically
        debugLog("[Karabiner2Exporter] No markers found, attempting to add them automatically")
        let contentWithMarkers = insertMarkersIfMissing(content: content)
        if contentWithMarkers != content {
          // Markers were added, proceed with injection
          do {
            try contentWithMarkers.write(toFile: configPath, atomically: true, encoding: .utf8)
            debugLog("[Karabiner2Exporter] Added missing markers to karabiner.edn")
            // Recursive call with the updated file
            return injectIntoMainKarabinerEDN(applications: applications, mainRules: mainRules, autoAddMarkers: false)
          } catch {
            return .error("Failed to write markers: \(error.localizedDescription)")
          }
        }
      }
      debugLog("[Karabiner2Exporter] No markers found in karabiner.edn")
      return .noMarkersFound
    }
    
    // Check for partial markers (incomplete pairs)
    var missingMarkers: [String] = []
    if hasAppStart && !hasAppEnd { missingMarkers.append(appEndMarker) }
    if !hasAppStart && hasAppEnd { missingMarkers.append(appStartMarker) }
    if hasMainStart && !hasMainEnd { missingMarkers.append(mainEndMarker) }
    if !hasMainStart && hasMainEnd { missingMarkers.append(mainStartMarker) }
    
    if !missingMarkers.isEmpty {
      debugLog("[Karabiner2Exporter] Partial markers found, missing: \(missingMarkers)")
      return .partialMarkersFound(missing: missingMarkers)
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
    
    var modifiedContent = content
    var injectedSomething = false
    
    // Replace applications section if markers exist
    if hasAppMarkers {
      if let appStartRange = modifiedContent.range(of: appStartMarker),
         let appEndRange = modifiedContent.range(of: appEndMarker, range: appStartRange.upperBound..<modifiedContent.endIndex) {
        let replaceRange = appStartRange.upperBound..<appEndRange.lowerBound
        let injectedApps = "\n" + applications + "\n  "
        modifiedContent.replaceSubrange(replaceRange, with: injectedApps)
        debugLog("[Karabiner2Exporter] Injected applications section")
        injectedSomething = true
      }
    }
    
    // Replace main section if markers exist
    if hasMainMarkers {
      if let mainStartRange = modifiedContent.range(of: mainStartMarker),
         let mainEndRange = modifiedContent.range(of: mainEndMarker, range: mainStartRange.upperBound..<modifiedContent.endIndex) {
        let replaceRange = mainStartRange.upperBound..<mainEndRange.lowerBound
        
        // Check if we need to preserve activation shortcuts that are inside the markers
        var preservedActivation: String? = nil
        if preserveActivationShortcuts {
          let existingContent = String(modifiedContent[replaceRange])
          // Extract existing activation shortcuts block if present
          if let activationStart = existingContent.range(of: "{:des \"Leader Key - Activation Shortcuts\"") {
            // Find the matching closing brace
            var braceCount = 0
            var foundEnd = false
            var currentIndex = activationStart.lowerBound
            
            while currentIndex < existingContent.endIndex && !foundEnd {
              let char = existingContent[currentIndex]
              if char == "{" {
                braceCount += 1
              } else if char == "}" {
                braceCount -= 1
                if braceCount == 0 {
                  foundEnd = true
                  preservedActivation = String(existingContent[activationStart.lowerBound...currentIndex])
                  debugLog("[Karabiner2Exporter] Preserving existing activation shortcuts from within markers")
                }
              }
              currentIndex = existingContent.index(after: currentIndex)
            }
          }
        }
        
        // Build the replacement content
        var injectedMain = "\n"
        
        // Add preserved activation shortcuts first if they exist
        if let preservedActivation = preservedActivation {
          injectedMain += "  " + preservedActivation + "\n\n"
        }
        
        // Add other main rules
        injectedMain += mainRules.joined(separator: "\n\n") + "\n  "
        
        modifiedContent.replaceSubrange(replaceRange, with: injectedMain)
        debugLog("[Karabiner2Exporter] Injected main rules section")
        injectedSomething = true
      }
    }
    
    // Write the modified content back only if we injected something
    if injectedSomething {
      do {
        try modifiedContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        debugLog("[Karabiner2Exporter] Successfully updated karabiner.edn")
        return .success
      } catch {
        debugLog("[Karabiner2Exporter] Failed to write updated content: \(error)")
        return .error("Failed to write file: \(error.localizedDescription)")
      }
    } else {
      debugLog("[Karabiner2Exporter] No injection performed")
      return .noMarkersFound
    }
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
    
    let appStartMarker = ";;; LEADERKEY_APPLICATIONS_START"
    let appEndMarker = ";;; LEADERKEY_APPLICATIONS_END"
    let mainStartMarker = ";;; LEADERKEY_MAIN_START"
    let mainEndMarker = ";;; LEADERKEY_MAIN_END"
    
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
    // Replace the key - use simple string replacement as regex has issues with word boundaries
    var alternativeRule = originalRule.replacingOccurrences(
      of: ":\(originalKey)",
      with: ":\(alternativeKey)"
    )
    
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
