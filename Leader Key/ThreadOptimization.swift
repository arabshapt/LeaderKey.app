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
}
