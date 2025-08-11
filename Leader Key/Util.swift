import Foundation

func delay(_ milliseconds: Int, callback: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: callback)
}

// Runtime-controlled logging. When Defaults.enableVerboseLogging is false (default), output is silenced in release.
// In DEBUG builds, logs are always shown to aid development.
import Defaults

func debugLog(_ message: @autoclosure () -> String) {
#if DEBUG
  print(message())
#else
  if Defaults[.enableVerboseLogging] {
    print(message())
  }
#endif
}
