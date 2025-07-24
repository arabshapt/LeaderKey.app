import Foundation

struct ValidationError: Identifiable, Equatable {
  let id = UUID()
  let path: [Int]  // Path to the item with the error (indices in the actions array)
  let message: String
  let type: ValidationErrorType
  let severity: ValidationSeverity
  let suggestion: String?
  
  init(path: [Int], message: String, type: ValidationErrorType, severity: ValidationSeverity = .error, suggestion: String? = nil) {
    self.path = path
    self.message = message
    self.type = type
    self.severity = severity
    self.suggestion = suggestion
  }

  static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
    lhs.id == rhs.id
  }
}

enum ValidationErrorType {
  case emptyKey
  case nonSingleCharacterKey
  case duplicateKey
}

enum ValidationSeverity {
  case warning
  case error
  
  var color: String {
    switch self {
    case .warning: return "orange"
    case .error: return "red"
    }
  }
  
  var iconName: String {
    switch self {
    case .warning: return "exclamationmark.triangle"
    case .error: return "xmark.circle"
    }
  }
}

class ConfigValidator {
  static func validate(group: Group) -> [ValidationError] {
    var errors = [ValidationError]()
    validateGroup(group, path: [], errors: &errors)
    return errors
  }

  private static func validateGroup(_ group: Group, path: [Int], errors: inout [ValidationError]) {
    // Check if the group key is valid (if not root level)
    if !path.isEmpty {
      validateKey(group.key, at: path, errors: &errors)
    }

    // Check for duplicate keys within this group
    var keysInGroup = [String: Int]()  // key: index

    for (index, item) in group.actions.enumerated() {
      let currentPath = path + [index]

      let keyToValidate: String?
      switch item {
      case .action(let action):
        keyToValidate = action.key
        validateKey(keyToValidate, at: currentPath, errors: &errors)
      case .group(let subgroup):
        keyToValidate = subgroup.key
        validateGroup(subgroup, path: currentPath, errors: &errors)
      }

      // Check for duplicates using keyToValidate
      if let currentItemKey = keyToValidate, !currentItemKey.isEmpty {
        if let existingIndex = keysInGroup[currentItemKey] {
          let duplicatePath = path + [existingIndex]
          errors.append(
            ValidationError(
              path: duplicatePath,
              message: "Multiple actions for the same key '\(currentItemKey)'",
              type: .duplicateKey,
              suggestion: "Change this key to a unique character"
            ))
          errors.append(
            ValidationError(
              path: currentPath,
              message: "Multiple actions for the same key '\(currentItemKey)'",
              type: .duplicateKey,
              suggestion: "Change this key to a unique character"
            ))
        } else {
          keysInGroup[currentItemKey] = index
        }
      }
    }
  }

  private static func validateKey(_ key: String?, at path: [Int], errors: inout [ValidationError]) {
    guard let key = key else {
      errors.append(
        ValidationError(
          path: path,
          message: "Key is missing",
          type: .emptyKey,
          suggestion: "Click the key button and press a single character"
        ))
      return
    }

    if key.isEmpty {
      errors.append(
        ValidationError(
          path: path,
          message: "Key is empty",
          type: .emptyKey,
          suggestion: "Click the key button and press a single character"
        ))
      return
    }

    if key.count != 1 {
      errors.append(
        ValidationError(
          path: path,
          message: "Key must be a single character",
          type: .nonSingleCharacterKey,
          suggestion: "Use only one character (a-z, 0-9, or symbols)"
        ))
    }
  }

  // Helper function to find an item at a specific path
  static func findItem(in group: Group, at path: [Int]) -> ActionOrGroup? {
    guard !path.isEmpty else { return .group(group) }

    var currentGroup = group
    var remainingPath = path

    while !remainingPath.isEmpty {
      let index = remainingPath.removeFirst()

      guard index < currentGroup.actions.count else { return nil }

      if remainingPath.isEmpty {
        // We've reached the target item
        return currentGroup.actions[index]
      } else {
        // We need to go deeper
        guard case .group(let subgroup) = currentGroup.actions[index] else {
          // Path points through an action, which can't contain other items
          return nil
        }
        currentGroup = subgroup
      }
    }

    return nil
  }
}
