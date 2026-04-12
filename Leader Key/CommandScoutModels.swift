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
  let title: String

  var id: String { path }
}

struct CommandScoutMenuInventoryResponse: Codable, Equatable {
  let app: String
  let items: [CommandScoutMenuItem]
}

struct CommandScoutMenuFetchResult: Equatable {
  var items: [CommandScoutMenuItem]
  var errorMessage: String?
}

struct CommandScoutMenuSuggestionResult: Equatable {
  var suggestions: [CommandScoutSuggestion]
  var errorMessage: String?
}

struct CommandScoutAppContext: Equatable {
  let selectedConfigKey: String
  let bundleId: String
  let appName: String
  let appDisplayName: String

  static func resolve(selectedConfigKey: String, userConfig: UserConfig) -> CommandScoutAppContext? {
    guard let bundleId = userConfig.extractBundleId(from: selectedConfigKey) else { return nil }

    let runningApp = NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == bundleId }
    let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
    let fallbackName = appURL?.deletingPathExtension().lastPathComponent
    let displayName = runningApp?.localizedName ?? fallbackName ?? selectedConfigKey

    return CommandScoutAppContext(
      selectedConfigKey: selectedConfigKey,
      bundleId: bundleId,
      appName: displayName,
      appDisplayName: displayName
    )
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

enum CommandScoutError: LocalizedError {
  case missingAppContext
  case missingAPIKey
  case invalidProviderResponse(String)
  case httpFailure(statusCode: Int, body: String)

  var errorDescription: String? {
    switch self {
    case .missingAppContext:
      return "Command Scout requires an app-specific config."
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
  static func tokens(from sequence: String) -> [String] {
    let cleaned = sequence
      .replacingOccurrences(of: ">", with: " ")
      .replacingOccurrences(of: "/", with: " ")
      .replacingOccurrences(of: ",", with: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()

    guard !cleaned.isEmpty else { return [] }

    let parts = cleaned.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    if parts.count == 1, let token = parts.first, shouldSplitCompactSequence(token) {
      return token.map { String($0) }
    }

    return parts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
  }

  static func normalizedSequence(_ sequence: String) -> String {
    tokens(from: sequence).joined(separator: " ")
  }

  private static func shouldSplitCompactSequence(_ token: String) -> Bool {
    guard token.count > 1 && token.count <= 3 else { return false }
    return token.allSatisfy { $0.isLetter || $0.isNumber }
  }
}

enum CommandScoutPrompts {
  static let systemPrompt = """
    You are Command Scout for Leader Key. Return strict JSON only. Suggest useful app commands for a keyboard-driven launcher. Prefer menu actions when the menu inventory contains the command. Use shortcuts or keystrokes only when the command is not available in the menu and the shortcut is reliable. Do not invent shortcuts. Mark uncertain data as low confidence. Do not suggest shell commands unless explicitly requested. Use short mnemonic Leader Key sequences, avoid collisions with existing sequences, and explain each sequence choice.
    """

  static func inventoryPrompt(
    appName: String,
    bundleId: String,
    existingConfigSummary: String,
    fallbackSummary: String,
    menuItemsJSON: String,
    webResearchEnabled: Bool
  ) -> String {
    """
    App: \(appName)
    Bundle ID: \(bundleId)
    Existing Leader Key config: \(existingConfigSummary)
    Fallback config summary: \(fallbackSummary)
    Live menu inventory: \(menuItemsJSON)
    Allowed action types: menu, shortcut, keystroke, url
    Web research enabled: \(webResearchEnabled)

    Find useful commands missing from the current Leader Key config. Include common menu commands, important shortcuts not exposed in the menu, and app-specific high-value workflows. Return JSON with:
    suggestions: [{title, category, source, actionType, actionValue, description, aiDescription, confidence, sourceNotes}]
    For menu actions, actionValue must be "\(appName) > <menu path>". For shortcuts, include the exact shortcut string and source.
    """
  }

  static func sequencePrompt(
    sequenceTree: String,
    reservedKeys: [String],
    suggestionsJSON: String
  ) -> String {
    """
    Given these suggestions and this existing sequence tree, assign Leader Key sequences.
    Rules: prefer 1-2 keys, allow 3 keys for conflicts, use mnemonic category prefixes, never overwrite existing sequences, avoid reserved keys, keep related commands near each other, and provide 2 alternatives for each conflict.
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
