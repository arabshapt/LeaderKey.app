import Cocoa
import Defaults
import KeyboardShortcuts
import SwiftUI

var defaultsSuite =
  ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
  ? UserDefaults(suiteName: UUID().uuidString)!
  : .standard

private func defaultReloadSuccessSound() -> ReloadSuccessSound {
  let legacySoundEnabled = defaultsSuite.object(forKey: "playReloadSuccessSound") as? Bool ?? false
  return legacySoundEnabled ? .glass : .off
}

func defaultKarabinerTsRepoPath() -> String {
  let candidate = (NSHomeDirectory() as NSString).appendingPathComponent(
    "personalProjects/LeaderKeyapp/karabiner.ts")
  var isDirectory: ObjCBool = false
  if FileManager.default.fileExists(atPath: candidate, isDirectory: &isDirectory), isDirectory.boolValue {
    return candidate
  }
  return ""
}

extension Defaults.Keys {
  static let configDir = Key<String>(
    "configDir", default: UserConfig.defaultDirectory(), suite: defaultsSuite)
  static let showMenuBarIcon = Key<Bool>(
    "showInMenubar", default: true, suite: defaultsSuite)
  @available(*, deprecated, message: "Use reloadSuccessSound instead.")
  static let playReloadSuccessSound = Key<Bool>(
    "playReloadSuccessSound", default: false, suite: defaultsSuite)
  static let reloadSuccessSound = Key<ReloadSuccessSound>(
    "reloadSuccessSound", default: defaultReloadSuccessSound(), suite: defaultsSuite)
  static let forceEnglishKeyboardLayout = Key<Bool>(
    "forceEnglishKeyboardLayout", default: false, suite: defaultsSuite)
  static let modifierKeyConfiguration = Key<ModifierKeyConfig>(
    "modifierKeyConfiguration", default: .controlGroupOptionSticky, suite: defaultsSuite)
  static let theme = Key<Theme>(
    "theme", default: .mysteryBox, suite: defaultsSuite)
  static let automaticallyChecksForUpdates = Key<Bool>(
    "automaticallyChecksForUpdates", default: false, suite: defaultsSuite)

  static let autoOpenCheatsheet = Key<AutoOpenCheatsheetSetting>(
    "autoOpenCheatsheet",
    default: .always, suite: defaultsSuite)
  static let cheatsheetDelayMS = Key<Int>(
    "cheatsheetDelayMS", default: 2000, suite: defaultsSuite)
  static let expandGroupsInCheatsheet = Key<Bool>(
    "expandGroupsInCheatsheet", default: false, suite: defaultsSuite)
  static let showAppIconsInCheatsheet = Key<Bool>(
    "showAppIconsInCheatsheet", default: true, suite: defaultsSuite)
  static let showDetailsInCheatsheet = Key<Bool>(
    "showDetailsInCheatsheet", default: true, suite: defaultsSuite)
  static let showFaviconsInCheatsheet = Key<Bool>(
    "showFaviconsInCheatsheet", default: true, suite: defaultsSuite)

  // Enable or disable verbose diagnostic logging at runtime (safe default: off)
  static let enableVerboseLogging = Key<Bool>(
    "enableVerboseLogging", default: false, suite: defaultsSuite)
  static let reactivateBehavior = Key<ReactivateBehavior>(
    "reactivateBehavior", default: .reset, suite: defaultsSuite)
  static let resetOnCmdRelease = Key<Bool>(
    "resetOnCmdRelease", default: false, suite: defaultsSuite)
  static let leaderSequenceTimeoutEnabled = Key<Bool>(
    "leaderSequenceTimeoutEnabled", default: false, suite: defaultsSuite)
  static let leaderSequenceTimeoutMS = Key<Int>(
    "leaderSequenceTimeoutMS", default: 2000, suite: defaultsSuite)
  static let normalSequenceTimeoutEnabled = Key<Bool>(
    "normalSequenceTimeoutEnabled", default: false, suite: defaultsSuite)
  static let normalSequenceTimeoutMS = Key<Int>(
    "normalSequenceTimeoutMS", default: 2000, suite: defaultsSuite)
  static let hintOverlayVisible = Key<Bool>(
    "hintOverlayVisible", default: true, suite: defaultsSuite)
  static let normalModeOpacity = Key<Double>(
    "normalModeOpacity", default: 0.9, suite: defaultsSuite)
  static let stickyModeOpacity = Key<Double>(
    "stickyModeOpacity", default: 0.7, suite: defaultsSuite)
  static let panelTopOffsetPercent = Key<Double>(
    "panelTopOffsetPercent", default: 0.15, suite: defaultsSuite)
  static let panelClickThrough = Key<Bool>(
    "panelClickThrough", default: false, suite: defaultsSuite)
  static let showFallbackItems = Key<Bool>(
    "showFallbackItems", default: true, suite: defaultsSuite)
  #if DEBUG
    static let useNativeOutlineConfigEditor = Key<Bool>(
      "useNativeOutlineConfigEditor", default: true, suite: defaultsSuite)
  #else
    static let useNativeOutlineConfigEditor = Key<Bool>(
      "useNativeOutlineConfigEditor", default: false, suite: defaultsSuite)
  #endif

  // User-defined names for config files - maps file paths to custom names
  static let configFileCustomNames = Key<[String: String]>(
    "configFileCustomNames", default: [:], suite: defaultsSuite)

  // Command execution settings
  /// Shell preference for running command actions
  static let commandShellPreference = Key<ShellPreference>(
    "commandShellPreference", default: .system, suite: defaultsSuite)
  /// Whether to load shell RC files when executing commands
  static let loadShellRCFiles = Key<Bool>("loadShellRCFiles", default: true, suite: defaultsSuite)
  /// Custom shell path when using custom shell preference
  static let customShellPath = Key<String>("customShellPath", default: "", suite: defaultsSuite)
  /// Input method for keyboard events
  static let inputMethodPreference = Key<InputMethodPreference>(
    "inputMethodPreference", default: .karabiner2, suite: defaultsSuite)
  /// Legacy kar binary path. Repo-based karabiner.ts export uses karabinerTsRepoPath instead.
  @available(*, deprecated, message: "Use karabinerTsRepoPath instead.")
  static let karBinaryPath = Key<String>("karBinaryPath", default: "", suite: defaultsSuite)
  /// Configurable path to the karabiner.ts repo or prepared config workspace.
  static let karabinerTsRepoPath = Key<String>(
    "karabinerTsRepoPath", default: defaultKarabinerTsRepoPath(), suite: defaultsSuite)
  /// Optional override path for goku binary (if empty, uses goku from PATH)
  static let gokuBinaryPath = Key<String>("gokuBinaryPath", default: "", suite: defaultsSuite)
  /// Karabiner 2.0 export backend.
  static let karabiner2Backend = Key<Karabiner2Backend>(
    "karabiner2Backend", default: .karabinerTS, suite: defaultsSuite)

  /// Voice dispatcher feature gate.
  static let voiceDispatcherEnabled = Key<Bool>(
    "voiceDispatcherEnabled", default: false, suite: defaultsSuite)
  /// Keep the audio engine warm while voice is enabled so the first word is not clipped.
  static let voicePrewarmMicrophone = Key<Bool>(
    "voicePrewarmMicrophone", default: true, suite: defaultsSuite)
  /// Voice dispatch is dry-run unless the user explicitly enables execution.
  static let voiceDispatchMode = Key<VoiceDispatchMode>(
    "voiceDispatchMode", default: .dryRun, suite: defaultsSuite)
  /// Planner routing preference for voice dispatch.
  static let voicePlannerMode = Key<VoicePlannerMode>(
    "voicePlannerMode", default: .fastOnly, suite: defaultsSuite)
  /// Groq speech-to-text model.
  static let voiceSTTModel = Key<VoiceSTTModel>(
    "voiceSTTModel", default: .whisperLargeV3Turbo, suite: defaultsSuite)
  /// Local inference server URL for planner tiers (llama-server or Ollama).
  static let voiceLlamaServerURL = Key<String>(
    "voiceLlamaServerURL", default: "http://localhost:11434", suite: defaultsSuite)
  /// Tier 2 model identity used by the local planner daemon.
  static let voiceTier2Model = Key<String>(
    "voiceTier2Model", default: "qwen3.5:2b", suite: defaultsSuite)
  /// Tier 2 GGUF file path, if the user manages llama-server from Leader Key later.
  static let voiceTier2ModelPath = Key<String>(
    "voiceTier2ModelPath", default: "", suite: defaultsSuite)
  /// Tier 2 fallback when current llama.cpp support for Qwen3.5 is unstable.
  static let voiceTier2FallbackModel = Key<String>(
    "voiceTier2FallbackModel", default: "qwen2.5:1.5b-instruct", suite: defaultsSuite)
  /// Tier 3 model identity for vague/agentic catalog commands.
  static let voiceTier3Model = Key<String>(
    "voiceTier3Model", default: "gemma4:e4b", suite: defaultsSuite)
  /// Tier 3 quantized model path.
  static let voiceTier3ModelPath = Key<String>(
    "voiceTier3ModelPath", default: "", suite: defaultsSuite)
  /// Show status notice when llama-server is unreachable and tier falls back to fast-only.
  static let voiceNotifyTierUnavailable = Key<Bool>(
    "voiceNotifyTierUnavailable", default: true, suite: defaultsSuite)
  /// Groq Cloud model for the planner tier.
  static let voiceGroqPlannerModel = Key<String>(
    "voiceGroqPlannerModel", default: "llama-3.3-70b-versatile", suite: defaultsSuite)
  /// Gemini model for the planner tier.
  static let voiceGeminiPlannerModel = Key<String>(
    "voiceGeminiPlannerModel", default: "gemini-2.5-flash", suite: defaultsSuite)
  /// Generic cloud planner provider.
  static let voiceCloudPlannerProvider = Key<VoiceCloudPlannerProvider>(
    "voiceCloudPlannerProvider", default: .openRouter, suite: defaultsSuite)
  /// Generic cloud planner model.
  static let voiceCloudPlannerModel = Key<String>(
    "voiceCloudPlannerModel", default: "openai/gpt-4.1-mini", suite: defaultsSuite)
  /// Custom OpenAI-compatible planner base URL.
  static let voiceCloudPlannerBaseURL = Key<String>(
    "voiceCloudPlannerBaseURL", default: "", suite: defaultsSuite)
}

enum AutoOpenCheatsheetSetting: String, Defaults.Serializable {
  case never
  case always
  case delay
}

enum ModifierKeyConfig: String, Codable, Defaults.Serializable, CaseIterable, Identifiable {
  case controlGroupOptionSticky
  case optionGroupControlSticky

  var id: Self { self }

  var description: String {
    switch self {
    case .controlGroupOptionSticky:
      return "⌃ Group sequences, ⌥ Sticky mode"
    case .optionGroupControlSticky:
      return "⌥ Group sequences, ⌃ Sticky mode"
    }
  }
}

enum ReactivateBehavior: String, Defaults.Serializable {
  case hide
  case reset
  case nothing
}

enum ReloadSuccessSound: String, Defaults.Serializable, CaseIterable, Identifiable {
  case off
  case glass
  case hero
  case ping
  case pop
  case funk

  var id: Self { self }

  var displayName: String {
    switch self {
    case .off:
      return "Off"
    case .glass:
      return "Glass"
    case .hero:
      return "Hero"
    case .ping:
      return "Ping"
    case .pop:
      return "Pop"
    case .funk:
      return "Funk"
    }
  }

  var description: String {
    switch self {
    case .off:
      return "Silent"
    case .glass:
      return "Airy crystalline chime"
    case .hero:
      return "Clean synthetic confirmation"
    case .ping:
      return "Bright minimal ping"
    case .pop:
      return "Soft modern pop"
    case .funk:
      return "Playful electronic blip"
    }
  }

  var soundName: NSSound.Name? {
    switch self {
    case .off:
      return nil
    case .glass:
      return .init("Glass")
    case .hero:
      return .init("Hero")
    case .ping:
      return .init("Ping")
    case .pop:
      return .init("Pop")
    case .funk:
      return .init("Funk")
    }
  }
}

enum ShellPreference: String, Defaults.Serializable, CaseIterable, Identifiable {
  case system
  case zsh
  case bash
  case sh
  case dash
  case custom

  var id: Self { self }

  var description: String {
    switch self {
    case .system:
      return "System Default"
    case .zsh:
      return "Zsh (/bin/zsh)"
    case .bash:
      return "Bash (/bin/bash)"
    case .sh:
      return "Sh (/bin/sh)"
    case .dash:
      return "Dash (/bin/dash)"
    case .custom:
      return "Custom"
    }
  }

  var path: String {
    switch self {
    case .system:
      return ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
    case .zsh:
      return "/bin/zsh"
    case .bash:
      return "/bin/bash"
    case .sh:
      return "/bin/sh"
    case .dash:
      return "/bin/dash"
    case .custom:
      return Defaults[.customShellPath].isEmpty ? "/bin/sh" : Defaults[.customShellPath]
    }
  }

  static func isValidShellPath(_ path: String) -> Bool {
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && !isDirectory.boolValue && fileManager.isExecutableFile(atPath: path)
  }
}

enum VoiceDispatchMode: String, Defaults.Serializable, CaseIterable, Identifiable {
  case dryRun
  case execute

  var id: Self { self }

  var displayName: String {
    switch self {
    case .dryRun:
      return "Dry run"
    case .execute:
      return "Execute safe actions"
    }
  }

  var description: String {
    switch self {
    case .dryRun:
      return "Plans commands and reports intended actions without running them."
    case .execute:
      return "Runs only validated safe actions. Confirmation and blocked actions still do not run."
    }
  }
}

enum VoicePlannerMode: String, Defaults.Serializable, CaseIterable, Identifiable {
  case fastOnly
  case tiered
  case tieredOllama
  case tieredCloud
  case tieredGroq
  case groqOnly
  case tieredGemini
  case geminiOnly
  case cloudOnly

  var id: Self { self }

  var displayName: String {
    switch self {
    case .fastOnly:
      return "Fast only"
    case .tiered:
      return "Tiered (llama-server)"
    case .tieredOllama:
      return "Tiered (Ollama)"
    case .tieredCloud:
      return "Tiered (Cloud API)"
    case .tieredGroq:
      return "Tiered (Groq Cloud)"
    case .groqOnly:
      return "Groq Only"
    case .tieredGemini:
      return "Tiered (Gemini)"
    case .geminiOnly:
      return "Gemini Only"
    case .cloudOnly:
      return "Cloud Only"
    }
  }

  var description: String {
    switch self {
    case .fastOnly:
      return "Use alias, BM25, and fuzzy matching only."
    case .tiered:
      return "Fast matcher first, then llama-server (/v1/chat/completions) for harder commands."
    case .tieredOllama:
      return "Fast matcher first, then Ollama (/api/chat) for harder commands."
    case .tieredCloud:
      return "Fast matcher first, then a cloud planner provider for harder commands."
    case .tieredGroq:
      return "Fast matcher first, then Groq Cloud API for harder commands. Uses your Groq API key."
    case .groqOnly:
      return "Always use Groq Cloud API. Handles repetition, multi-step, and complex commands."
    case .tieredGemini:
      return "Fast matcher first, then Gemini API for harder commands. Uses your Gemini API key."
    case .geminiOnly:
      return "Always use Gemini API with retrieved candidates only. Handles complex voice commands."
    case .cloudOnly:
      return "Always use the selected cloud planner provider."
    }
  }

  var isTiered: Bool {
    self == .tiered || self == .tieredOllama || self == .tieredCloud || self == .tieredGroq
      || self == .groqOnly || self == .tieredGemini || self == .geminiOnly || self == .cloudOnly
  }
}

enum VoiceCloudPlannerProvider: String, Defaults.Serializable, CaseIterable, Identifiable {
  case openAI
  case openRouter
  case fireworks
  case together
  case deepInfra
  case perplexity
  case compatible

  var id: Self { self }

  var displayName: String {
    switch self {
    case .openAI:
      return "OpenAI"
    case .openRouter:
      return "OpenRouter"
    case .fireworks:
      return "Fireworks"
    case .together:
      return "Together"
    case .deepInfra:
      return "DeepInfra"
    case .perplexity:
      return "Perplexity"
    case .compatible:
      return "Custom OpenAI-compatible"
    }
  }

  var plannerKind: String {
    switch self {
    case .openAI:
      return "openai"
    case .openRouter:
      return "openrouter"
    case .fireworks:
      return "fireworks"
    case .together:
      return "together"
    case .deepInfra:
      return "deepinfra"
    case .perplexity:
      return "perplexity"
    case .compatible:
      return "compatible"
    }
  }

  var defaultModel: String {
    switch self {
    case .openAI:
      return "gpt-4.1-mini"
    case .openRouter:
      return "openai/gpt-4.1-mini"
    case .fireworks:
      return "accounts/fireworks/models/kimi-k2p5"
    case .together:
      return "meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo"
    case .deepInfra:
      return "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo"
    case .perplexity:
      return "sonar-pro"
    case .compatible:
      return "gpt-4.1-mini"
    }
  }

  var baseURL: String {
    switch self {
    case .openAI:
      return "https://api.openai.com/v1"
    case .openRouter:
      return "https://openrouter.ai/api/v1"
    case .fireworks:
      return "https://api.fireworks.ai/inference/v1"
    case .together:
      return "https://api.together.ai/v1"
    case .deepInfra:
      return "https://api.deepinfra.com/v1/openai"
    case .perplexity:
      return "https://api.perplexity.ai"
    case .compatible:
      return ""
    }
  }

  var keychainAccount: String {
    "voice.cloud.\(rawValue)"
  }
}

enum VoiceSTTModel: String, Defaults.Serializable, CaseIterable, Identifiable {
  case whisperLargeV3Turbo = "whisper-large-v3-turbo"
  case whisperLargeV3 = "whisper-large-v3"

  var id: Self { self }

  var displayName: String {
    switch self {
    case .whisperLargeV3Turbo:
      return "Whisper Large v3 Turbo"
    case .whisperLargeV3:
      return "Whisper Large v3"
    }
  }

  var description: String {
    switch self {
    case .whisperLargeV3Turbo:
      return "Groq fast/default transcription model."
    case .whisperLargeV3:
      return "Groq higher-accuracy transcription model."
    }
  }
}

enum InputMethodPreference: String, Defaults.Serializable, CaseIterable, Identifiable {
  case karabiner2 = "karabiner2"

  var id: Self { self }

  var displayName: String {
    switch self {
    case .karabiner2:
      return "Karabiner 2.0 (State Machine)"
    }
  }

  var description: String {
    switch self {
    case .karabiner2:
      return "Karabiner integration with state machine and send_user_command transport"
    }
  }
}

enum Karabiner2Backend: String, Defaults.Serializable, CaseIterable, Identifiable {
  case karabinerTS = "kar"
  case goku
  case legacyBoth = "both"

  static var allCases: [Karabiner2Backend] {
    [.karabinerTS, .goku]
  }

  var id: Self { self }

  var normalized: Karabiner2Backend {
    switch self {
    case .legacyBoth:
      return .karabinerTS
    case .karabinerTS, .goku:
      return self
    }
  }

  var displayName: String {
    switch normalized {
    case .karabinerTS, .legacyBoth:
      return "karabiner.ts (repo export)"
    case .goku:
      return "Goku (EDN)"
    }
  }

  var description: String {
    switch normalized {
    case .karabinerTS, .legacyBoth:
      return "Writes a generated Leader Key module into a configured karabiner.ts workspace "
        + "and applies the managed rules directly."
    case .goku:
      return "Legacy path: generates EDN config, injects it into karabiner.edn, "
        + "and compiles it with Goku."
    }
  }

  var usesKarabinerTsExport: Bool {
    normalized == .karabinerTS
  }

  var usesLegacyGoku: Bool {
    normalized == .goku
  }
}

// Extend KeyboardShortcuts.Name to add app-specific names
extension KeyboardShortcuts.Name {
  static let activate = KeyboardShortcuts.Name("activate")
  static let activateDefaultOnly = KeyboardShortcuts.Name(
    "activateDefaultOnly",
    default: KeyboardShortcuts.Shortcut(.k, modifiers: [.command, .shift])
  )
  static let activateAppSpecific = KeyboardShortcuts.Name(
    "activateAppSpecific",
    default: KeyboardShortcuts.Shortcut(.k, modifiers: [.command, .option])
  )
  static let forceReset = KeyboardShortcuts.Name(
    "forceReset",
    default: KeyboardShortcuts.Shortcut(.k, modifiers: [.command, .shift, .control])
  )
  static let fallbackEscape = KeyboardShortcuts.Name(
    "fallbackEscape",
    default: nil  // No default - user can set if needed
  )
  static let voiceToggleRecord = KeyboardShortcuts.Name(
    "voiceToggleRecord",
    default: nil
  )
  static let voiceHoldToTalk = KeyboardShortcuts.Name(
    "voiceHoldToTalk",
    default: nil
  )

  // Helper for group-specific shortcuts
  // static func forGroup(_ path: String) -> KeyboardShortcuts.Name {
  //   KeyboardShortcuts.Name("group_\(path)")
  // }
}
