import Cocoa
import Defaults
import SwiftUI
import KeyboardShortcuts

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
    "theme", default: .cheater, suite: defaultsSuite)
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

  // User-defined names for config files - maps file paths to custom names
  static let configFileCustomNames = Key<[String: String]>("configFileCustomNames", default: [:], suite: defaultsSuite)

  // Overlay detection settings
  /// Enable detection of overlay windows (like Raycast, Alfred) for separate configs
  static let overlayDetectionEnabled = Key<Bool>("overlayDetectionEnabled", default: false, suite: defaultsSuite)
  /// List of bundle IDs for apps that should be checked for overlay windows
  static let overlayApps = Key<[String]>("overlayApps", default: ["com.raycast.macos", "com.runningwithcrayons.Alfred"], suite: defaultsSuite)
  
  // Command execution settings
  /// Shell preference for running command actions
  static let commandShellPreference = Key<ShellPreference>("commandShellPreference", default: .system, suite: defaultsSuite)
  /// Whether to load shell RC files when executing commands
  static let loadShellRCFiles = Key<Bool>("loadShellRCFiles", default: true, suite: defaultsSuite)
  /// Custom shell path when using custom shell preference
  static let customShellPath = Key<String>("customShellPath", default: "", suite: defaultsSuite)
  /// Custom environment variables for command execution
  static let commandEnvironmentVariables = Key<[String: String]>("commandEnvironmentVariables", default: [:], suite: defaultsSuite)
  /// Working directory mode for command execution
  static let commandWorkingDirectory = Key<WorkingDirectoryMode>("commandWorkingDirectory", default: .home, suite: defaultsSuite)
  /// Custom working directory path
  static let customWorkingDirectoryPath = Key<String>("customWorkingDirectoryPath", default: "", suite: defaultsSuite)
  /// Command execution timeout in seconds
  static let commandTimeoutSeconds = Key<Int>("commandTimeoutSeconds", default: 30, suite: defaultsSuite)
  /// Output handling mode for commands
  static let commandOutputMode = Key<CommandOutputMode>("commandOutputMode", default: .silent, suite: defaultsSuite)
  /// Whether to use interactive mode for shell commands
  static let useInteractiveShell = Key<Bool>("useInteractiveShell", default: false, suite: defaultsSuite)
  /// Custom shell arguments
  static let customShellArguments = Key<String>("customShellArguments", default: "", suite: defaultsSuite)
  /// Pre-command hook - runs before the main command
  static let preCommandHook = Key<String>("preCommandHook", default: "", suite: defaultsSuite)
  /// Post-command hook - runs after the main command
  static let postCommandHook = Key<String>("postCommandHook", default: "", suite: defaultsSuite)
  /// Whether to enable command hooks
  static let enableCommandHooks = Key<Bool>("enableCommandHooks", default: false, suite: defaultsSuite)
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

enum WorkingDirectoryMode: String, Defaults.Serializable, CaseIterable, Identifiable {
  case home
  case config
  case current
  case custom
  
  var id: Self { self }
  
  var description: String {
    switch self {
    case .home:
      return "Home Directory"
    case .config:
      return "Config Directory"
    case .current:
      return "Current Directory"
    case .custom:
      return "Custom Path"
    }
  }
  
  var path: String {
    switch self {
    case .home:
      return NSHomeDirectory()
    case .config:
      return Defaults[.configDir]
    case .current:
      return FileManager.default.currentDirectoryPath
    case .custom:
      let customPath = Defaults[.customWorkingDirectoryPath]
      return customPath.isEmpty ? NSHomeDirectory() : customPath
    }
  }
}

enum CommandOutputMode: String, Defaults.Serializable, CaseIterable, Identifiable {
  case silent
  case notification
  case clipboard
  case log
  case window
  
  var id: Self { self }
  
  var description: String {
    switch self {
    case .silent:
      return "Silent (No Output)"
    case .notification:
      return "Show as Notification"
    case .clipboard:
      return "Copy to Clipboard"
    case .log:
      return "Log to Console"
    case .window:
      return "Show in Window"
    }
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
    default: nil // No default - user can set if needed
  )

  // Helper for group-specific shortcuts
  // static func forGroup(_ path: String) -> KeyboardShortcuts.Name {
  //   KeyboardShortcuts.Name("group_\(path)")
  // }
}
