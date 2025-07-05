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
    "theme", default: .mysteryBox, suite: defaultsSuite)
  static let automaticallyChecksForUpdates = Key<Bool>(
    "automaticallyChecksForUpdates", default: true, suite: defaultsSuite)

  static let autoOpenCheatsheet = Key<AutoOpenCheatsheetSetting>(
    "autoOpenCheatsheet",
    default: .delay, suite: defaultsSuite)
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
  static let reactivateBehavior = Key<ReactivateBehavior>(
    "reactivateBehavior", default: .hide, suite: defaultsSuite)
  static let resetOnCmdRelease = Key<Bool>(
    "resetOnCmdRelease", default: false, suite: defaultsSuite)
  static let normalModeOpacity = Key<Double>(
    "normalModeOpacity", default: 0.9, suite: defaultsSuite)
  static let stickyModeOpacity = Key<Double>(
    "stickyModeOpacity", default: 0.9, suite: defaultsSuite)
  static let panelTopOffsetPercent = Key<Double>(
    "panelTopOffsetPercent", default: 0.3, suite: defaultsSuite)
    
  // User-defined names for config files - maps file paths to custom names
  static let configFileCustomNames = Key<[String: String]>("configFileCustomNames", default: [:], suite: defaultsSuite)
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

  // Helper for group-specific shortcuts
  // static func forGroup(_ path: String) -> KeyboardShortcuts.Name {
  //   KeyboardShortcuts.Name("group_\(path)")
  // }
}
