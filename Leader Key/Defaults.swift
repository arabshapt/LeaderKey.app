import Cocoa
import Defaults
import KeyboardShortcuts
import SwiftUI

var defaultsSuite =
  ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
  ? UserDefaults(suiteName: UUID().uuidString)!
  : .standard

extension Defaults.Keys {
  static let configDir = Key<String>(
    "configDir", default: UserConfig.defaultDirectory(), suite: defaultsSuite)
  static let showMenuBarIcon = Key<Bool>(
    "showInMenubar", default: true, suite: defaultsSuite)
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
  /// Optional override path for kar binary (if empty, uses kar from PATH)
  static let karBinaryPath = Key<String>("karBinaryPath", default: "", suite: defaultsSuite)
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
      return "kar (TypeScript)"
    case .goku:
      return "Goku (EDN)"
    case .both:
      return "Both (kar + Goku)"
    }
  }

  var description: String {
    switch self {
    case .kar:
      return "Generates TypeScript config, compiled by kar to karabiner.json"
    case .goku:
      return "Generates EDN config, injected into karabiner.edn and compiled by Goku"
    case .both:
      return "Runs both kar and Goku pipelines"
    }
  }

  var requiresKar: Bool {
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
