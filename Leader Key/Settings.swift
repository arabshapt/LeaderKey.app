import Settings

extension Settings.PaneIdentifier {
  static let general = Self("general")
  static let opacity = Self("opacity")
  static let advanced = Self("advanced")
  static let shortcuts = Self("shortcuts")
  static let search = Self("search")
}

/// Centralized configuration for all Settings panes
struct SettingsConfig {
    /// Width used by all Settings panes for consistent layout
    static let contentWidth: Double = 1100.0
}
