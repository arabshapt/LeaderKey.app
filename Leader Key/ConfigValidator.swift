import Foundation

struct ValidationError: Identifiable, Equatable {
  let id = UUID()
  let path: [Int]  // Path to the item with the error (indices in the actions array)
  let message: String
  let type: ValidationErrorType
  let severity: ValidationSeverity
  let suggestion: String?

  init(
    path: [Int], message: String, type: ValidationErrorType, severity: ValidationSeverity = .error,
    suggestion: String? = nil
  ) {
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
  case invalidLayerTrigger
  case invalidLayerTapAction
  case nestedLayer
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
  private static let disallowedLayerTriggerKeys: Set<String> = [
    "caps_lock",
    "left_command",
    "right_command",
    "left_option",
    "right_option",
    "left_control",
    "right_control",
    "left_shift",
    "right_shift",
    "fn",
    "command",
    "option",
    "control",
    "shift"
  ]

  static func validate(group: Group) -> [ValidationError] {
    var errors = [ValidationError]()
    validateGroup(group, path: [], errors: &errors, insideLayer: false)
    return errors
  }

  private static func validateGroup(
    _ group: Group,
    path: [Int],
    errors: inout [ValidationError],
    insideLayer: Bool,
    validateSelfKey: Bool = true
  ) {
    // Check if the group key is valid (if not root level)
    if validateSelfKey && !path.isEmpty {
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
        validateGroup(subgroup, path: currentPath, errors: &errors, insideLayer: insideLayer)
      case .layer(let layer):
        keyToValidate = layer.key
        validateLayer(layer, path: currentPath, errors: &errors, insideLayer: insideLayer)
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

  private static func validateLayer(
    _ layer: Layer,
    path: [Int],
    errors: inout [ValidationError],
    insideLayer: Bool
  ) {
    validateKey(layer.key, at: path, errors: &errors)

    if insideLayer {
      errors.append(
        ValidationError(
          path: path,
          message: "Nested layers are not supported",
          type: .nestedLayer,
          suggestion: "Use a group inside the layer, or move this layer to normal mode base level"
        ))
    }

    if let key = layer.key?.lowercased(), disallowedLayerTriggerKeys.contains(key) {
      errors.append(
        ValidationError(
          path: path,
          message: "Modifier keys cannot be used as normal-mode layer triggers",
          type: .invalidLayerTrigger,
          suggestion: "Use a non-modifier key for the layer trigger"
        ))
    }

    if let tapAction = layer.tapAction,
      tapAction.type == .group || tapAction.type == .layer
    {
      errors.append(
        ValidationError(
          path: path,
          message: "Layer tapAction must be a terminal action",
          type: .invalidLayerTapAction,
          suggestion: "Use a shortcut, command, macro, or normal-mode control action"
        ))
    }

    let layerGroup = Group(
      key: layer.key,
      label: layer.label,
      iconPath: layer.iconPath,
      stickyMode: nil,
      actions: layer.actions
    )
    validateGroup(layerGroup, path: path, errors: &errors, insideLayer: true, validateSelfKey: false)
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
        guard index < currentGroup.actions.count else { return nil }
        switch currentGroup.actions[index] {
        case .group(let subgroup):
          currentGroup = subgroup
        case .layer(let layer):
          currentGroup = Group(
            key: layer.key,
            label: layer.label,
            iconPath: layer.iconPath,
            stickyMode: nil,
            actions: layer.actions
          )
        case .action:
          // Path points through an action, which can't contain other items
          return nil
        }
      }
    }

    return nil
  }
}
