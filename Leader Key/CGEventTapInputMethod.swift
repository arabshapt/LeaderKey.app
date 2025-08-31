import Cocoa
import CoreGraphics
import Foundation

final class CGEventTapInputMethod: InputMethod {
  private let dualTapManager: DualEventTapManager
  private weak var delegate: InputMethodDelegate?
  private weak var appDelegate: AppDelegate?
  private var lastHealthCheck = Date()

  var isActive: Bool {
    return dualTapManager.checkAndFailover()
  }

  var healthStatus: InputMethodHealthStatus {
    let isHealthy = dualTapManager.checkAndFailover()
    let message =
      isHealthy ? "Event tap is active and healthy" : "Event tap is disabled or unhealthy"
    return InputMethodHealthStatus(
      isHealthy: isHealthy,
      message: message,
      lastCheckTime: lastHealthCheck
    )
  }

  init(appDelegate: AppDelegate, dualTapManager: DualEventTapManager) {
    self.appDelegate = appDelegate
    self.dualTapManager = dualTapManager
  }

  func start(with delegate: InputMethodDelegate) -> Bool {
    self.delegate = delegate

    guard let appDelegate = appDelegate else {
      debugLog("[CGEventTapInputMethod] AppDelegate not available")
      return false
    }

    // Use the global optimized eventTapCallback directly
    // This preserves all the performance optimizations
    let success = dualTapManager.createDualTaps(
      callback: eventTapCallback,
      userInfo: Unmanaged.passUnretained(appDelegate).toOpaque()
    )

    if success {
      debugLog("[CGEventTapInputMethod] Started successfully")
    } else {
      debugLog("[CGEventTapInputMethod] Failed to start")
    }

    return success
  }

  func stop() {
    dualTapManager.stopDualTaps()
    debugLog("[CGEventTapInputMethod] Stopped")
  }

  func checkHealth() -> Bool {
    lastHealthCheck = Date()
    return dualTapManager.checkAndFailover()
  }

  func getStatistics() -> String {
    return dualTapManager.getStatistics()
  }
}
