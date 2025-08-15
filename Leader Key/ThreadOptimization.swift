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
      }
      debounceTimers[identifier] = timer
      RunLoop.current.add(timer, forMode: .common)
    }
  }
}