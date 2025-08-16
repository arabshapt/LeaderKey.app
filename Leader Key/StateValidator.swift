import Foundation
import AppKit

/// Validates application state and ensures consistency
enum StateValidator {
  
  // MARK: - Window State Validation
  
  /// Validate if window can be shown
  static func canShowWindow(_ window: NSWindow?) -> ValidationResult {
    guard let window = window else {
      return .failure("Window is nil")
    }
    
    if window.isVisible {
      return .warning("Window is already visible")
    }
    
    if window.isMiniaturized {
      return .warning("Window is miniaturized")
    }
    
    return .success
  }
  
  /// Validate if window can be hidden
  static func canHideWindow(_ window: NSWindow?) -> ValidationResult {
    guard let window = window else {
      return .failure("Window is nil")
    }
    
    if !window.isVisible {
      return .warning("Window is already hidden")
    }
    
    return .success
  }
  
  // MARK: - Navigation State Validation
  
  /// Validate navigation state consistency
  static func validateNavigation(
    navigationPath: [Group],
    activeRoot: Group?,
    currentGroup: Group?
  ) -> ValidationResult {
    // Check if we have a root when navigating
    if !navigationPath.isEmpty && activeRoot == nil {
      return .failure("Navigation path exists but no active root")
    }
    
    // Check if current group matches navigation path
    if let current = currentGroup, 
       let last = navigationPath.last,
       current.key != last.key {
      return .warning("Current group doesn't match navigation path")
    }
    
    // Validate path continuity
    if navigationPath.count > 1 {
      for i in 0..<navigationPath.count - 1 {
        let parent = navigationPath[i]
        let child = navigationPath[i + 1]
        
        // Check if child exists in parent's actions
        let childExists = parent.actions.contains { action in
          if case .group(let group) = action {
            return group.key == child.key
          }
          return false
        }
        
        if !childExists {
          return .failure("Navigation path is broken at index \(i)")
        }
      }
    }
    
    return .success
  }
  
  // MARK: - Config State Validation
  
  /// Validate configuration state
  static func validateConfigState(
    root: Group?,
    currentlyEditingGroup: Group?,
    selectedConfigKey: String,
    discoveredConfigs: [String: String]
  ) -> ValidationResult {
    // Check root exists
    guard let root = root else {
      return .failure("Root configuration is nil")
    }
    
    // Check if root has any actions
    if root.actions.isEmpty {
      return .warning("Root configuration has no actions")
    }
    
    // Check if selected config exists
    if !discoveredConfigs.keys.contains(selectedConfigKey) {
      return .failure("Selected config '\(selectedConfigKey)' not found")
    }
    
    // Check editing group validity
    if let editing = currentlyEditingGroup {
      if editing.key == nil && editing.actions.isEmpty {
        return .warning("Currently editing group is empty")
      }
    }
    
    return .success
  }
  
  // MARK: - Keyboard State Validation
  
  /// Validate keyboard event state
  static func validateKeyboardState(
    heldModifiers: Set<CGKeyCode>,
    isWindowVisible: Bool
  ) -> ValidationResult {
    // Check for stuck modifiers
    if !heldModifiers.isEmpty && !isWindowVisible {
      return .warning("Modifiers held but window not visible: \(heldModifiers.count) keys")
    }
    
    // Check for excessive held modifiers (possible bug)
    if heldModifiers.count > 4 {
      return .failure("Too many modifiers held: \(heldModifiers.count)")
    }
    
    return .success
  }
  
  // MARK: - Pre/Post Condition Checks
  
  /// Check preconditions for showing window
  static func preShowWindowCheck(controller: Controller?) -> ValidationResult {
    guard let controller = controller else {
      return .failure("Controller is nil")
    }
    
    // Additional checks can be added here
    return .success
  }
  
  /// Check postconditions after hiding window
  static func postHideWindowCheck(
    window: NSWindow?,
    heldModifiers: Set<CGKeyCode>
  ) -> ValidationResult {
    // Window should not be visible
    if let window = window, window.isVisible {
      return .failure("Window still visible after hide")
    }
    
    // No modifiers should be held
    if !heldModifiers.isEmpty {
      return .warning("Modifiers still held after hide: \(heldModifiers.count)")
    }
    
    return .success
  }
  
  // MARK: - State Snapshot
  
  /// Create a snapshot of current state for debugging
  static func createStateSnapshot(
    windowVisible: Bool,
    navigationDepth: Int,
    heldModifiers: Int,
    activeConfig: String?,
    timestamp: Date = Date()
  ) -> StateSnapshot {
    return StateSnapshot(
      windowVisible: windowVisible,
      navigationDepth: navigationDepth,
      heldModifiers: heldModifiers,
      activeConfig: activeConfig,
      timestamp: timestamp
    )
  }
  
  /// Validate state transition
  static func validateTransition(
    from oldState: StateSnapshot,
    to newState: StateSnapshot
  ) -> ValidationResult {
    // Check for impossible transitions
    if !oldState.windowVisible && newState.navigationDepth > 0 {
      return .warning("Navigation depth increased while window hidden")
    }
    
    if oldState.navigationDepth > 0 && !newState.windowVisible && newState.navigationDepth > 0 {
      return .failure("Navigation not cleared when hiding window")
    }
    
    return .success
  }
}

// MARK: - Supporting Types

enum ValidationResult {
  case success
  case warning(String)
  case failure(String)
  
  var isValid: Bool {
    switch self {
    case .success, .warning:
      return true
    case .failure:
      return false
    }
  }
  
  var message: String? {
    switch self {
    case .success:
      return nil
    case .warning(let msg), .failure(let msg):
      return msg
    }
  }
  
  func log(context: String) {
    switch self {
    case .success:
      break // Don't log success
    case .warning(let msg):
      print("[StateValidator] ⚠️ \(context): \(msg)")
    case .failure(let msg):
      print("[StateValidator] ❌ \(context): \(msg)")
      #if DEBUG
      // In debug builds, assert on failures
      assertionFailure("[StateValidator] \(context): \(msg)")
      #endif
    }
  }
}

struct StateSnapshot {
  let windowVisible: Bool
  let navigationDepth: Int
  let heldModifiers: Int
  let activeConfig: String?
  let timestamp: Date
  
  var description: String {
    return """
    StateSnapshot at \(timestamp):
      - Window: \(windowVisible ? "visible" : "hidden")
      - Navigation depth: \(navigationDepth)
      - Held modifiers: \(heldModifiers)
      - Active config: \(activeConfig ?? "none")
    """
  }
}

// MARK: - Debug Helpers

#if DEBUG
extension StateValidator {
  /// Run all validations and log results (debug only)
  static func runFullValidation(
    window: NSWindow?,
    navigationPath: [Group],
    activeRoot: Group?,
    currentGroup: Group?,
    root: Group?,
    currentlyEditingGroup: Group?,
    selectedConfigKey: String,
    discoveredConfigs: [String: String],
    heldModifiers: Set<CGKeyCode>
  ) {
    print("[StateValidator] Running full validation...")
    
    canShowWindow(window).log(context: "canShowWindow")
    canHideWindow(window).log(context: "canHideWindow")
    
    validateNavigation(
      navigationPath: navigationPath,
      activeRoot: activeRoot,
      currentGroup: currentGroup
    ).log(context: "validateNavigation")
    
    validateConfigState(
      root: root,
      currentlyEditingGroup: currentlyEditingGroup,
      selectedConfigKey: selectedConfigKey,
      discoveredConfigs: discoveredConfigs
    ).log(context: "validateConfigState")
    
    validateKeyboardState(
      heldModifiers: heldModifiers,
      isWindowVisible: window?.isVisible ?? false
    ).log(context: "validateKeyboardState")
    
    print("[StateValidator] Validation complete")
  }
}
#endif