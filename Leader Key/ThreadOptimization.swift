import Foundation
import QuartzCore

/// Thread optimization utilities to reduce unnecessary async dispatches
enum ThreadOptimization {
  /// Execute a block on the main thread, avoiding unnecessary dispatch if already on main
  static func executeOnMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
    } else {
      DispatchQueue.main.async(execute: block)
    }
  }

  /// Execute a block on the main thread synchronously if safe, async otherwise
  static func executeOnMainSync(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
    } else {
      DispatchQueue.main.sync(execute: block)
    }
  }

  /// Batch multiple UI updates together to reduce dispatch overhead
  static func batchUIUpdates(_ updates: @escaping () -> Void) {
    if Thread.isMainThread {
      updates()
    } else {
      DispatchQueue.main.async {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updates()
        CATransaction.commit()
      }
    }
  }

  /// Debounce rapid calls to reduce excessive dispatches
  private static var debounceTimers: [String: Timer] = [:]
  private static let debounceQueue = DispatchQueue(label: "com.leaderkey.debounce")

  static func debounce(
    identifier: String,
    delay: TimeInterval,
    action: @escaping () -> Void
  ) {
    debounceQueue.async {
      debounceTimers[identifier]?.invalidate()
      let timer = Timer.scheduledTimer(
        withTimeInterval: delay,
        repeats: false
      ) { _ in
        executeOnMain(action)
        // Clean up timer reference after execution
        debounceQueue.async {
          debounceTimers.removeValue(forKey: identifier)
        }
      }
      debounceTimers[identifier] = timer
      RunLoop.current.add(timer, forMode: .common)
    }
  }

  /// Clean up all pending debounce timers
  static func cleanupAllTimers() {
    debounceQueue.async {
      for (_, timer) in debounceTimers {
        timer.invalidate()
      }
      debounceTimers.removeAll()
      print("[ThreadOptimization] Cleaned up \(debounceTimers.count) timers")
    }
  }

  /// Clean up a specific timer
  static func cleanupTimer(identifier: String) {
    debounceQueue.async {
      if let timer = debounceTimers[identifier] {
        timer.invalidate()
        debounceTimers.removeValue(forKey: identifier)
        print("[ThreadOptimization] Cleaned up timer: \(identifier)")
      }
    }
  }

  /// Get count of active timers (for debugging)
  static func activeTimerCount() -> Int {
    debounceQueue.sync {
      return debounceTimers.count
    }
  }
}