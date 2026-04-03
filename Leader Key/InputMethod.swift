import AppKit
import Foundation

protocol InputMethod: AnyObject {
  var isActive: Bool { get }
  var healthStatus: InputMethodHealthStatus { get }

  func start(with delegate: InputMethodDelegate) -> Bool
  func stop()
  func checkHealth() -> Bool
  func getStatistics() -> String
}

protocol InputMethodDelegate: AnyObject {
  func inputMethodDidReceiveActivation(bundleId: String?)
  func inputMethodDidReceiveApplyConfig()
  func inputMethodDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags)
  func inputMethodDidReceiveDeactivation()
  func inputMethodDidReceiveSettings()
  func inputMethodDidReceiveSequence(_ sequence: String)
  func inputMethodDidReceiveStateId(_ stateId: Int32, sticky: Bool)
  func inputMethodDidReceiveShake()
  func inputMethodDidRequestState() -> [String: Any]
}

struct InputMethodHealthStatus {
  let isHealthy: Bool
  let message: String
  let lastCheckTime: Date
}

enum InputMethodType: String, Codable {
  case cgEventTap = "cgeventtap"
  case karabiner = "karabiner"

  var displayName: String {
    switch self {
    case .cgEventTap:
      return "CGEventTap (Default)"
    case .karabiner:
      return "Karabiner Elements"
    }
  }

  var description: String {
    switch self {
    case .cgEventTap:
      return "Direct keyboard interception using macOS event taps"
    case .karabiner:
      return "Integration through Karabiner Elements with Unix socket"
    }
  }
}
