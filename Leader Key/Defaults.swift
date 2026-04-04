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
  /// Karabiner 2.0 export backend: kar, goku, or both
  static let karabiner2Backend = Key<Karabiner2Backend>(
    "karabiner2Backend", default: .goku, suite: defaultsSuite)
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
  case kar
  case goku
  case both

  var id: Self { self }

  var displayName: String {
    switch self {
    case .kar:
      return "karabiner.ts (repo export)"
    case .goku:
      return "Goku (EDN)"
    case .both:
      return "Both (karabiner.ts + Goku)"
    }
  }

  var description: String {
    switch self {
    case .kar:
      return "Writes a generated Leader Key module into a configured karabiner.ts workspace and applies the managed rules directly"
    case .goku:
      return "Generates EDN config, injected into karabiner.edn and compiled by Goku"
    case .both:
      return "Writes the generated karabiner.ts module first, then runs the legacy Goku EDN pipeline"
    }
  }

  var requiresKarabinerTsExport: Bool {
    self == .kar || self == .both
  }

  var requiresGoku: Bool {
    self == .goku || self == .both
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

  // Helper for group-specific shortcuts
  // static func forGroup(_ path: String) -> KeyboardShortcuts.Name {
  //   KeyboardShortcuts.Name("group_\(path)")
  // }
}
