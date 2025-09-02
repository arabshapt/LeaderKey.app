import AppKit
import Foundation

final class KarabinerInputMethod: InputMethod {
  private weak var delegate: InputMethodDelegate?
  private let socketServer = UnixSocketServer.shared
  private var lastHealthCheck = Date()

  var isActive: Bool {
    return socketServer.getStatistics().contains("Running: true")
  }

  var healthStatus: InputMethodHealthStatus {
    let karabinerRunning = isKarabinerRunning()
    let socketActive = isActive

    let isHealthy = karabinerRunning && socketActive
    let message: String

    if !karabinerRunning {
      message = "Karabiner Elements is not running"
    } else if !socketActive {
      message = "Unix socket server is not active"
    } else {
      message = "Karabiner integration is active and healthy"
    }

    return InputMethodHealthStatus(
      isHealthy: isHealthy,
      message: message,
      lastCheckTime: lastHealthCheck
    )
  }

  func start(with delegate: InputMethodDelegate) -> Bool {
    self.delegate = delegate

    socketServer.delegate = self

    let success = socketServer.start()

    if success {
      debugLog("[KarabinerInputMethod] Started successfully")
    } else {
      debugLog("[KarabinerInputMethod] Failed to start")
    }

    return success
  }

  func stop() {
    socketServer.stop()
    debugLog("[KarabinerInputMethod] Stopped")
  }

  func checkHealth() -> Bool {
    lastHealthCheck = Date()
    return isKarabinerRunning() && isActive
  }

  func getStatistics() -> String {
    return socketServer.getStatistics()
  }

  private func isKarabinerRunning() -> Bool {
    let karabinerBundleIDs = [
      "org.pqrs.Karabiner-Elements.Settings",
      "org.pqrs.Karabiner-Menu",
      "org.pqrs.Karabiner-NotificationWindow",
      "org.pqrs.Karabiner-EventViewer",
    ]

    let runningApps = NSWorkspace.shared.runningApplications
    let hasKarabinerApp = runningApps.contains { app in
      if let bundleID = app.bundleIdentifier {
        return karabinerBundleIDs.contains(bundleID)
      }
      return false
    }

    if !hasKarabinerApp {
      return isKarabinerGrabberRunning()
    }

    return hasKarabinerApp
  }

  private func isKarabinerGrabberRunning() -> Bool {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "pgrep -x karabiner_grabber"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = Pipe()

    do {
      try task.run()
      task.waitUntilExit()
      return task.terminationStatus == 0
    } catch {
      debugLog("[KarabinerInputMethod] Failed to check karabiner_grabber: \(error)")
      return false
    }
  }
}

extension KarabinerInputMethod: UnixSocketServerDelegate {
  func unixSocketServerDidReceiveActivation(bundleId: String?) {
    debugLog("[KarabinerInputMethod] Received activation, bundleId: \(bundleId ?? "nil")")
    delegate?.inputMethodDidReceiveActivation(bundleId: bundleId)
  }

  func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
    debugLog("[KarabinerInputMethod] Received key: \(keyCode), modifiers: \(modifiers)")
    delegate?.inputMethodDidReceiveKey(keyCode, modifiers: modifiers)
  }

  func unixSocketServerDidReceiveDeactivation() {
    debugLog("[KarabinerInputMethod] Received deactivation")
    delegate?.inputMethodDidReceiveDeactivation()
  }

  func unixSocketServerDidReceiveSettings() {
    debugLog("[KarabinerInputMethod] Received settings command")
    delegate?.inputMethodDidReceiveSettings()
  }

  func unixSocketServerDidReceiveSequence(_ sequence: String) {
    debugLog("[KarabinerInputMethod] Received sequence: \(sequence)")
    delegate?.inputMethodDidReceiveSequence(sequence)
  }
  
  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool) {
    debugLog("[KarabinerInputMethod] Received state ID: \(stateId)")
    // Karabiner 1.0 doesn't support sticky mode, always pass false
    delegate?.inputMethodDidReceiveStateId(stateId, sticky: false)
  }

  func unixSocketServerRequestState() -> [String: Any] {
    return delegate?.inputMethodDidRequestState() ?? ["active": false]
  }
}
