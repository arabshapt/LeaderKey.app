import Defaults

enum Theme: String, Defaults.Serializable {
  case cheater
  case stealth

  static var all: [Theme] {
    return [.cheater, .stealth]
  }

  static func classFor(_ value: Theme) -> MainWindow.Type {
    switch value {
    case .cheater:
      return Cheater.Window.self
    case .stealth:
      return Stealth.Window.self
    }
  }

  static func name(_ value: Theme) -> String {
    switch value {
    case .cheater: return "Cheater"
    case .stealth: return "Stealth"
    }
  }
}
