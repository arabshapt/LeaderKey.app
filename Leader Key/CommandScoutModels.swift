import AppKit
import Defaults
import Foundation

enum CommandScoutAIProviderKind: String, Codable, Defaults.Serializable, CaseIterable, Identifiable {
  case gemini
  case openAI
  case anthropic
  case openAICompatible

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .gemini: return "Gemini"
    case .openAI: return "OpenAI"
    case .anthropic: return "Anthropic"
    case .openAICompatible: return "OpenAI-compatible"
    }
  }

  var defaultModel: String {
    switch self {
    case .gemini: return "gemini-2.5-pro"
    case .openAI: return "gpt-5.1"
    case .anthropic: return "claude-opus-4-5"
    case .openAICompatible: return ""
    }
  }

  var supportsWebResearch: Bool {
    switch self {
    case .gemini:
      return true
    case .openAI, .anthropic, .openAICompatible:
      return false
    }
  }

  func supportsWebResearch(modelName: String) -> Bool {
    guard supportsWebResearch else { return false }
    switch self {
    case .gemini:
      return true
    case .openAI, .anthropic, .openAICompatible:
      return false
    }
  }

  var keychainAccount: String {
    "command-scout.\(rawValue)"
  }
}

enum CommandScoutSuggestionSource: String, Codable, CaseIterable, Identifiable {
  case liveMenu
  case ai
  case web
  case local

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .liveMenu: return "Live menu"
    case .ai: return "AI"
    case .web: return "Web"
    case .local: return "Local"
    }
  }
}

enum CommandScoutActionType: String, Codable, CaseIterable, Identifiable {
  case menu
  case shortcut
  case keystroke
  case url
  case command
  case macro
  case application
  case unsupported

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .menu: return "Menu"
    case .shortcut: return "Shortcut"
    case .keystroke: return "Keystroke"
    case .url: return "URL"
    case .command: return "Command"
    case .macro: return "Macro"
    case .application: return "Application"
    case .unsupported: return "Unsupported"
    }
  }

  var leaderKeyType: Type? {
    switch self {
    case .menu: return .menu
    case .shortcut: return .shortcut
    case .keystroke: return .keystroke
    case .url: return .url
    case .command: return .command
    case .application: return .application
    case .macro, .unsupported: return nil
    }
  }

  var requiresExplicitSelection: Bool {
    switch self {
    case .command, .macro, .application, .unsupported:
      return true
    case .menu, .shortcut, .keystroke, .url:
      return false
    }
  }
}

enum CommandScoutConflictStatus: String, Codable, CaseIterable, Identifiable {
  case clear
  case duplicateSequence
  case duplicateAction
  case invalidSequence
  case invalidActionValue
  case unsupportedAction
  case highRisk

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .clear: return "Clear"
    case .duplicateSequence: return "Duplicate sequence"
    case .duplicateAction: return "Duplicate action"
    case .invalidSequence: return "Invalid sequence"
    case .invalidActionValue: return "Invalid value"
    case .unsupportedAction: return "Unsupported"
    case .highRisk: return "Needs review"
    }
  }
}

struct CommandScoutSuggestion: Identifiable, Codable, Equatable {
  var id: String
  var title: String
  var category: String
  var source: CommandScoutSuggestionSource
  var actionType: CommandScoutActionType
  var actionValue: String
  var menuFallbackPaths: [String]
  var description: String
  var aiDescription: String
  var suggestedSequence: String
  var alternatives: [String]
  var confidence: Double
  var conflictStatus: CommandScoutConflictStatus
  var reviewNotes: String
  var shortcut: String? = nil

  var isHighConfidence: Bool {
    confidence >= 0.75
  }

  var isSelectableByDefault: Bool {
    isHighConfidence && conflictStatus == .clear && !actionType.requiresExplicitSelection
  }

  var canCreateAction: Bool {
    actionType.leaderKeyType != nil && conflictStatus != .unsupportedAction
  }

  var sequenceTokens: [String] {
    CommandScoutSequenceNormalizer.tokens(from: suggestedSequence)
  }

  func makeAction() -> Action? {
    guard let leaderKeyType = actionType.leaderKeyType else { return nil }
    guard !sequenceTokens.isEmpty else { return nil }
    let trimmedValue = actionValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedValue.isEmpty else { return nil }

    return Action(
      key: sequenceTokens.last,
      type: leaderKeyType,
      label: title.nilIfBlank,
      description: description.nilIfBlank,
      aiDescription: aiDescription.nilIfBlank,
      value: trimmedValue,
      iconPath: nil,
      activates: nil,
      menuFallbackPaths: menuFallbackPaths.isEmpty ? nil : menuFallbackPaths,
      stickyMode: nil,
      macroSteps: nil
    )
  }
}

struct CommandScoutMenuItem: Codable, Equatable, Identifiable {
  let appName: String
  let enabled: Bool
  let path: String
  let shortcut: String?
  let title: String

  var id: String { path }

  init(appName: String, enabled: Bool, path: String, shortcut: String? = nil, title: String) {
    self.appName = appName
    self.enabled = enabled
    self.path = path
    self.shortcut = shortcut
    self.title = title
  }
}

struct CommandScoutMenuInventoryResponse: Codable, Equatable {
  let app: String
  let items: [CommandScoutMenuItem]
}

struct CommandScoutMenuFetchResult: Equatable {
  var items: [CommandScoutMenuItem]
  var errorMessage: String?

  var isAppNotRunning: Bool {
    errorMessage?.hasPrefix("ERROR: App not running:") == true
  }
}

struct CommandScoutMenuSuggestionResult: Equatable {
  var suggestions: [CommandScoutSuggestion]
  var errorMessage: String?

  var isAppNotRunning: Bool {
    errorMessage?.hasPrefix("ERROR: App not running:") == true
  }
}

enum CommandScoutScanMode: String, Equatable {
  case menuOnly
  case menuAndAI
  case aiOnly

  var displayName: String {
    switch self {
    case .menuOnly: return "Menu only"
    case .menuAndAI: return "Menu + AI"
    case .aiOnly: return "AI only"
    }
  }
}

struct CommandScoutSuggestionMergeResult: Equatable {
  var suggestions: [CommandScoutSuggestion]
  var addedCount: Int
}

struct CommandScoutAIInventorySuccess: Equatable {
  var suggestions: [CommandScoutSuggestion]
  var aiSuggestionCount: Int
  var addedCount: Int
  var diagnostics: CommandScoutAIParseDiagnostics
}

enum CommandScoutAIInventoryResult: Equatable {
  case success(CommandScoutAIInventorySuccess)
  case parseFailure(CommandScoutAIParseDiagnostics)
}

struct CommandScoutAppTarget: Equatable, Sendable {
  let selectedConfigKey: String
  let bundleId: String
  let appName: String
  let appDisplayName: String
}

enum CommandScoutTarget: Equatable, Sendable {
  case app(CommandScoutAppTarget)
  case global
  case fallback

  static func resolve(selectedConfigKey: String, userConfig: UserConfig) -> CommandScoutTarget? {
    switch userConfig.configFileKind(forDisplayKey: selectedConfigKey) {
    case .global:
      return .global
    case .appFallback:
      return .fallback
    case .app(let bundleId):
      let runningApp = NSWorkspace.shared.runningApplications.first {
        $0.bundleIdentifier == bundleId
      }
      let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
      let fallbackName = appURL?.deletingPathExtension().lastPathComponent
      let displayName = runningApp?.localizedName ?? fallbackName ?? selectedConfigKey

      return .app(
        CommandScoutAppTarget(
          selectedConfigKey: selectedConfigKey,
          bundleId: bundleId,
          appName: displayName,
          appDisplayName: displayName
        )
      )
    case .normalFallback, .normalApp, .tag, .normalTag, .unknown:
      return nil
    }
  }

  var displayName: String {
    switch self {
    case .app(let app): return app.appDisplayName
    case .global: return globalDefaultDisplayName
    case .fallback: return defaultAppConfigDisplayName
    }
  }

  var appName: String? {
    guard case .app(let app) = self else { return nil }
    return app.appName
  }

  var bundleId: String? {
    guard case .app(let app) = self else { return nil }
    return app.bundleId
  }

  var usageContext: UsageContext {
    switch self {
    case .app(let app): return UsageContext(scope: .app, bundleId: app.bundleId)
    case .global: return UsageContext(scope: .global)
    case .fallback: return UsageContext(scope: .fallback)
    }
  }

  var supportsMenuInventory: Bool {
    if case .app = self { return true }
    return false
  }

  var requiresAI: Bool { !supportsMenuInventory }

  var allowedActionTypes: Set<CommandScoutActionType> {
    switch self {
    case .app:
      return [.menu, .shortcut, .keystroke, .url]
    case .global:
      return [.application, .url, .command]
    case .fallback:
      return [.shortcut, .keystroke]
    }
  }

  var debugBundleIdentifier: String {
    bundleId ?? usageContext.scope.rawValue
  }
}

struct CommandScoutProviderSettings: Equatable {
  var providerKind: CommandScoutAIProviderKind
  var modelName: String
  var baseURL: String
  var webResearchEnabled: Bool

  var effectiveModelName: String {
    let trimmedModel = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedModel.isEmpty ? providerKind.defaultModel : trimmedModel
  }

  var isOpenRouterBaseURL: Bool {
    let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty,
          let url = URL(string: trimmed),
          let host = url.host?.lowercased()
    else {
      return false
    }
    return host == "openrouter.ai" || host.hasSuffix(".openrouter.ai")
  }

  var supportsWebResearch: Bool {
    switch providerKind {
    case .openAICompatible:
      return isOpenRouterBaseURL
    case .gemini, .openAI, .anthropic:
      return providerKind.supportsWebResearch(modelName: effectiveModelName)
    }
  }
}

struct CommandScoutScanResult: Equatable {
  var suggestions: [CommandScoutSuggestion]
  var statusMessage: String
  var menuError: String?
  var debugBundle: String
}

struct CommandScoutApplyResult: Equatable {
  var insertedCount: Int
  var skippedMessages: [String]
}

struct CommandScoutAIParseDiagnostics: Equatable {
  var reason: String
  var detectedShape: String
  var rawPreview: String
  var originalCount: Int
  var keptCount: Int

  var warningMessage: String? {
    guard originalCount > keptCount else { return nil }
    return "AI returned \(originalCount) suggestions; showing top \(keptCount)."
  }

  var failureMessage: String {
    "AI JSON parse failed: \(reason). Shape: \(detectedShape). Preview: \(rawPreview)"
  }
}

enum CommandScoutAIParseResult: Equatable {
  case success(suggestions: [CommandScoutSuggestion], diagnostics: CommandScoutAIParseDiagnostics)
  case failure(CommandScoutAIParseDiagnostics)
}

enum CommandScoutError: LocalizedError {
  case missingTarget
  case missingAPIKey
  case invalidProviderResponse(String)
  case httpFailure(statusCode: Int, body: String)

  var errorDescription: String? {
    switch self {
    case .missingTarget:
      return "Command Scout requires a Global, Fallback, or regular app config."
    case .missingAPIKey:
      return "Add an API key or run a menu-only scan."
    case .invalidProviderResponse(let message):
      return "Invalid AI provider response: \(message)"
    case .httpFailure(let statusCode, let body):
      return "AI provider request failed with HTTP \(statusCode): \(body)"
    }
  }
}

enum CommandScoutSequenceNormalizer {
  static let punctuationTokens = [",", ".", "/", ";", "'", "-", "=", "[", "]", "\\"]
  private static let allowedTokenSet = Set(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map(String.init)
      + punctuationTokens
  )

  static func tokens(from sequence: String) -> [String] {
    let cleaned = sequence
      .replacingOccurrences(of: ">", with: " ")
      .replacingOccurrences(of: "→", with: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard !cleaned.isEmpty else { return [] }

    let parts = cleaned.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    if parts.count == 1, let token = parts.first, shouldSplitCompactSequence(token) {
      return token.map { String($0) }
    }

    return parts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
  }

  static func normalizedSequence(_ sequence: String) -> String {
    tokens(from: sequence).joined()
  }

  static func isAllowedToken(_ token: String) -> Bool {
    allowedTokenSet.contains(token)
  }

  private static func shouldSplitCompactSequence(_ token: String) -> Bool {
    guard token.count > 1 && token.count <= 3 else { return false }
    return token.allSatisfy { allowedTokenSet.contains(String($0)) }
  }
}

enum CommandScoutPrompts {
  static func systemPrompt(for target: CommandScoutTarget) -> String {
    let scopeRules: String
    switch target {
    case .app:
      scopeRules = """
        Include live menu commands and reliable app shortcuts or keystrokes. Menu values must exactly match the supplied inventory.
        """
    case .global:
      scopeRules = """
        This is the Global map. Suggest useful applications, URLs, and commands only. Commands require explicit human review. Never return menu, shortcut, or keystroke actions.
        """
    case .fallback:
      scopeRules = """
        This is the cross-app Fallback map. Suggest portable shortcuts and keystrokes only. Never return menu, application, URL, or command actions.
        """
    }

    return """
    You are Command Scout for Leader Key, a keyboard-driven launcher for macOS. Return strict JSON only — no markdown, no prose.

    Your job: suggest useful actions and assign mnemonic key sequences for a Leader Key config. A sequence is 1-3 compact, case-sensitive keys pressed in order (e.g. "tn" = Tabs → New, "tN" uses uppercase N). Sequences should be short, intuitive, grouped by category prefix, and must never contain spaces.

    Rules:
    - \(scopeRules)
    - Do NOT invent shortcuts. Only suggest well-known, reliable shortcuts. Mark uncertain ones as low confidence.
    - For each suggestion, include a suggestedSequence as a compact 1-3 character string. Allowed keys are ASCII a-z, A-Z, 0-9, comma, period, slash, semicolon, quote, minus, equals, brackets, and backslash. Preserve exact case. Slash and comma are literal keys, never separators.
    - Category prefixes: t=Tabs, w=Windows, n=Navigation, e=Editing, v=View, d=Developer, b=Bookmarks, s=Search, h=History, f=File, p=Privacy, m=Misc.
    - Avoid collisions between sequences. If two commands share a prefix, use 2-3 keys.
    - Aim for 15-30 suggestions covering the app's most valuable workflows.
    """
  }

  static func inventoryPrompt(
    target: CommandScoutTarget,
    existingConfigSummary: String,
    fallbackSummary: String,
    menuItemsJSON: String,
    webResearchEnabled: Bool
  ) -> String {
    let targetDetails: String
    let actionRules: String
    switch target {
    case .app(let app):
      targetDetails = "App: \(app.appName)\nBundle ID: \(app.bundleId)"
      actionRules = """
        Allowed action types: menu, shortcut, keystroke, url
        - For menu actions, actionValue must be "\(app.appName) > <exact menu path>"
        - source: "liveMenu" if from the menu inventory, "ai" if from your knowledge
        """
    case .global:
      targetDetails = "Target: Global"
      actionRules = """
        Allowed action types: application, url, command
        - Application values must name a real macOS application.
        - URL values must be legitimate URLs.
        - Commands must be useful, explicit, and marked in sourceNotes as requiring review.
        - Never return menu, shortcut, or keystroke actions.
        """
    case .fallback:
      targetDetails = "Target: Fallback"
      actionRules = """
        Allowed action types: shortcut, keystroke
        - Suggest only reliable cross-app shortcuts and keystrokes.
        - Never return menu, application, URL, or command actions.
        """
    }

    return """
    \(targetDetails)
    Existing Leader Key config: \(existingConfigSummary)
    Fallback config summary: \(fallbackSummary)
    Live menu inventory: \(menuItemsJSON)
    \(actionRules)
    Web research enabled: \(webResearchEnabled)

    Return JSON: {"suggestions": [{title, category, source, actionType, actionValue, suggestedSequence, description, aiDescription, confidence, sourceNotes}]}

    - source: "ai" unless the action exactly matches a supplied live menu item
    - suggestedSequence: compact, case-sensitive mnemonic key path like "tn" (tabs → new). Allowed punctuation keys include comma, period, slash, semicolon, quote, minus, equals, brackets, and backslash. Spaces are invalid.
    - confidence: number 0-1 (0.9 = very sure, 0.5 = uncertain)
    - Include the most useful 15-30 commands. Prioritize daily-use actions.
    """
  }

  static func sequencePrompt(
    sequenceTree: String,
    reservedKeys: [String],
    suggestionsJSON: String
  ) -> String {
    """
    Given these suggestions and this existing sequence tree, assign Leader Key sequences.
    Rules: prefer 1-2 compact keys, allow 3 keys for conflicts, preserve exact case, use mnemonic category prefixes, never overwrite existing sequences, avoid reserved keys, keep related commands near each other, and provide 2 alternatives for each conflict. Slash and comma are keys. Return compact sequences without spaces.
    Return JSON with:
    [{suggestionId, suggestedSequence, alternatives, collisionReason, mnemonicReason}]
    Existing sequence tree: \(sequenceTree)
    Reserved keys: \(reservedKeys.joined(separator: ", "))
    Suggestions: \(suggestionsJSON)
    """
  }
}

extension Defaults.Keys {
  static let commandScoutAIProvider = Key<CommandScoutAIProviderKind>(
    "commandScoutAIProvider", default: .gemini, suite: defaultsSuite)
  static let commandScoutAIModel = Key<String>(
    "commandScoutAIModel", default: CommandScoutAIProviderKind.gemini.defaultModel, suite: defaultsSuite)
  static let commandScoutAIBaseURL = Key<String>(
    "commandScoutAIBaseURL", default: "", suite: defaultsSuite)
  static let commandScoutWebResearchEnabled = Key<Bool>(
    "commandScoutWebResearchEnabled", default: true, suite: defaultsSuite)
}

private extension String {
  var nilIfBlank: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}
