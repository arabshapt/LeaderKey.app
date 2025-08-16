import Cocoa
import Foundation
import Defaults

// MARK: - Error Types and Classification
enum ErrorCategory {
  case transient  // Can be retried (network, file busy)
  case permanent  // Cannot be retried (syntax error, missing file)
  case unknown    // Unclear if retry would help
}

struct ErrorContext {
  let error: Error
  let category: ErrorCategory
  var retryCount: Int
  let timestamp: Date
  let operation: String
  
  var shouldRetry: Bool {
    return category == .transient && retryCount < 3
  }
}

// MARK: - Error History for Debugging
class ErrorHistory {
  static let shared = ErrorHistory()
  private var history: [ErrorContext] = []
  private let maxHistorySize = 50
  private let queue = DispatchQueue(label: "com.leaderkey.errorhistory")
  
  private init() {}
  
  func record(_ context: ErrorContext) {
    queue.async { [weak self] in
      guard let self = self else { return }
      self.history.append(context)
      if self.history.count > self.maxHistorySize {
        self.history.removeFirst()
      }
    }
  }
  
  func getRecentErrors() -> [ErrorContext] {
    queue.sync { history }
  }
  
  func clear() {
    queue.async { [weak self] in
      self?.history.removeAll()
    }
  }
}

// MARK: - Error Handling
extension UserConfig {
  
  /// Classify an error to determine if it should be retried
  private func classifyError(_ error: Error) -> ErrorCategory {
    let nsError = error as NSError
    
    // File system errors
    if nsError.domain == NSCocoaErrorDomain {
      switch nsError.code {
      case NSFileReadNoSuchFileError:
        return .permanent  // File doesn't exist
      case NSFileReadNoPermissionError:
        return .permanent  // No permission
      case NSFileReadCorruptFileError:
        return .permanent  // File is corrupted
      case NSFileReadInvalidFileNameError:
        return .permanent  // Invalid filename
      case NSFileReadUnknownError:
        return .transient  // Might be temporary
      default:
        if nsError.code >= 256 && nsError.code <= 512 {
          // File system errors in this range are often transient
          return .transient
        }
      }
    }
    
    // POSIX errors
    if nsError.domain == NSPOSIXErrorDomain {
      switch nsError.code {
      case Int(EBUSY), Int(EAGAIN), Int(EINTR):
        return .transient  // Resource busy, try again
      case Int(ENOENT), Int(EACCES), Int(EPERM):
        return .permanent  // File not found, permission denied
      default:
        break
      }
    }
    
    // JSON decoding errors are usually permanent
    if error is DecodingError {
      return .permanent
    }
    
    return .unknown
  }
  
  /// Handle error with automatic retry for transient errors
  internal func handleError(
    _ error: Error,
    critical: Bool,
    operation: String = "Unknown",
    retryAction: (() -> Void)? = nil
  ) {
    let category = classifyError(error)
    let context = ErrorContext(
      error: error,
      category: category,
      retryCount: 0,
      timestamp: Date(),
      operation: operation
    )
    
    // Record for debugging
    ErrorHistory.shared.record(context)
    
    // If transient and retry action provided, attempt retry
    if context.shouldRetry, let retryAction = retryAction {
      retryWithBackoff(context: context, action: retryAction)
    } else {
      // Show error and handle based on criticality
      showErrorAndRecover(context: context, critical: critical)
    }
  }
  
  /// Retry with exponential backoff
  private func retryWithBackoff(
    context: ErrorContext,
    action: @escaping () -> Void,
    retryCount: Int = 0
  ) {
    let maxRetries = 3
    let baseDelay = 0.5  // Start with 0.5 seconds
    
    if retryCount >= maxRetries {
      // Max retries reached, show error
      showErrorAndRecover(context: context, critical: false)
      return
    }
    
    // Calculate delay with exponential backoff
    let delay = baseDelay * pow(2.0, Double(retryCount))
    
    print("[ErrorHandling] Retrying \(context.operation) after \(delay)s (attempt \(retryCount + 1)/\(maxRetries))")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      // Update retry count
      var updatedContext = context
      updatedContext.retryCount = retryCount + 1
      ErrorHistory.shared.record(updatedContext)
      
      // Attempt the action again
      action()
    }
  }
  
  /// Show error alert and perform recovery based on error type
  private func showErrorAndRecover(context: ErrorContext, critical: Bool) {
    // Construct detailed error message
    var message = "\(context.error.localizedDescription)"
    
    if context.category == .transient && context.retryCount > 0 {
      message += "\n\nFailed after \(context.retryCount) retries."
    }
    
    // Add recovery suggestions based on error type
    let recoverySuggestion = getRecoverySuggestion(for: context)
    if !recoverySuggestion.isEmpty {
      message += "\n\n\(recoverySuggestion)"
    }
    
    alertHandler.showAlert(
      style: critical ? .critical : .warning,
      message: message
    )
    
    // Perform recovery actions based on criticality
    if critical {
      performCriticalRecovery()
    } else {
      performSoftRecovery(for: context)
    }
  }
  
  /// Get recovery suggestion based on error type
  private func getRecoverySuggestion(for context: ErrorContext) -> String {
    switch context.category {
    case .transient:
      return "This appears to be a temporary issue. Please try again in a moment."
    case .permanent:
      if context.operation.contains("config") || context.operation.contains("Config") {
        return "Try resetting your configuration or checking the file format."
      }
      return "This issue requires manual intervention."
    case .unknown:
      return "If this problem persists, please restart the application."
    }
  }
  
  /// Perform critical recovery (reset to safe state)
  private func performCriticalRecovery() {
    print("[ErrorHandling] Performing critical recovery - resetting to safe state")
    
    // Clear all state
    root = emptyRoot
    currentlyEditingGroup = emptyRoot
    validationErrors = []
    selectedConfigKeyForEditing = globalDefaultDisplayName
    
    // Clear caches
    appConfigs.removeAll()
    configCache.clearCache()
    
    // Attempt to reload default config
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      self?.ensureAndLoad()
    }
  }
  
  /// Perform soft recovery based on error context
  private func performSoftRecovery(for context: ErrorContext) {
    print("[ErrorHandling] Performing soft recovery for \(context.operation)")
    
    // Operation-specific recovery
    if context.operation.contains("save") || context.operation.contains("Save") {
      // For save errors, try to create a backup
      createBackupConfig()
    } else if context.operation.contains("load") || context.operation.contains("Load") {
      // For load errors, try to use cached version
      if !discoveredConfigFiles.isEmpty {
        print("[ErrorHandling] Using cached config list")
      }
    }
    
    // Re-validate current state
    validateCurrentState()
  }
  
  /// Create a backup of the current configuration
  private func createBackupConfig() {
    let backupPath = (Defaults[.configDir] as NSString)
      .appendingPathComponent("backup-\(Date().timeIntervalSince1970).json")
    
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(root)
      try data.write(to: URL(fileURLWithPath: backupPath))
      print("[ErrorHandling] Created backup at: \(backupPath)")
    } catch {
      print("[ErrorHandling] Failed to create backup: \(error)")
    }
  }
  
  /// Validate current state and fix inconsistencies
  private func validateCurrentState() {
    // Ensure we have at least empty root
    if root.actions.isEmpty && root.key == nil {
      root = emptyRoot
    }
    
    // Ensure editing group is valid
    if currentlyEditingGroup.actions.isEmpty && currentlyEditingGroup.key == nil {
      currentlyEditingGroup = root
    }
    
    // Ensure selected config exists
    if !discoveredConfigFiles.keys.contains(selectedConfigKeyForEditing) {
      selectedConfigKeyForEditing = globalDefaultDisplayName
    }
  }
}