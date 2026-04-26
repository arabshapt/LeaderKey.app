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
  case invalidActionValue
  case invalidLayerScope
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
    "shift",
  ]

  static func validate(group: Group, allowsLayers: Bool = true) -> [ValidationError] {
    var errors = [ValidationError]()
    validateGroup(group, path: [], errors: &errors, insideLayer: false, allowsLayers: allowsLayers)
    return errors
  }

  private static func validateGroup(
    _ group: Group,
    path: [Int],
    errors: inout [ValidationError],
    insideLayer: Bool,
    allowsLayers: Bool,
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
        validateActionValue(action, at: currentPath, errors: &errors)
      case .group(let subgroup):
        keyToValidate = subgroup.key
        validateGroup(
          subgroup,
          path: currentPath,
          errors: &errors,
          insideLayer: insideLayer,
          allowsLayers: allowsLayers
        )
      case .layer(let layer):
        keyToValidate = layer.key
        validateLayer(
          layer,
          path: currentPath,
          errors: &errors,
          insideLayer: insideLayer,
          allowsLayers: allowsLayers
        )
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
    insideLayer: Bool,
    allowsLayers: Bool
  ) {
    validateKey(layer.key, at: path, errors: &errors)

    if !allowsLayers {
      errors.append(
        ValidationError(
          path: path,
          message: "Layers are only supported in normal-mode configs",
          type: .invalidLayerScope,
          suggestion: "Move this layer to a normal fallback or normal app config"
        ))
    }

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

    if let tapAction = layer.tapAction {
      if tapAction.type == .group || tapAction.type == .layer {
        errors.append(
          ValidationError(
            path: path,
            message: "Layer tapAction must be a terminal action",
            type: .invalidLayerTapAction,
            suggestion: "Use a shortcut, command, macro, or normal-mode control action"
          ))
      } else {
        validateActionValue(tapAction, at: path, errors: &errors, label: "Layer tapAction")
      }
    }

    let layerGroup = Group(
      key: layer.key,
      label: layer.label,
      iconPath: layer.iconPath,
      stickyMode: nil,
      actions: layer.actions
    )
    validateGroup(
      layerGroup,
      path: path,
      errors: &errors,
      insideLayer: true,
      allowsLayers: allowsLayers,
      validateSelfKey: false
    )
  }

  private static func validateActionValue(
    _ action: Action,
    at path: [Int],
    errors: inout [ValidationError],
    label: String = "Action"
  ) {
    if action.type == .group || action.type == .layer {
      appendInvalidActionValue(
        at: path,
        errors: &errors,
        message: "\(label) must be a terminal action",
        suggestion: "Use a shortcut, command, macro, or mode-control action"
      )
      return
    }

    if action.type.isModeControlAction {
      return
    }

    switch action.type {
    case .macro:
      validateMacroSteps(action.macroSteps, at: path, errors: &errors, label: label)
    case .menu:
      let parts = action.value.components(separatedBy: " > ")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      if parts.first?.isEmpty ?? true {
        appendInvalidActionValue(
          at: path,
          errors: &errors,
          message: "\(label) menu action needs a target app",
          suggestion: "Choose an app for the menu action"
        )
      } else if parts.dropFirst()
        .joined(separator: " > ")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .isEmpty
      {
        appendInvalidActionValue(
          at: path,
          errors: &errors,
          message: "\(label) menu action needs a menu path",
          suggestion: "Choose a menu item path"
        )
      }
    case .intellij:
      let pieces = action.value.components(separatedBy: "|")
      let actionIds = (pieces.first ?? "")
        .components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
      if actionIds.isEmpty {
        appendInvalidActionValue(
          at: path,
          errors: &errors,
          message: "\(label) needs at least one IntelliJ action ID",
          suggestion: "Enter an IntelliJ action ID"
        )
      }
      if pieces.count > 1 {
        let delay = pieces[1].trimmingCharacters(in: .whitespacesAndNewlines)
        if !delay.isEmpty && Int(delay) == nil {
          appendInvalidActionValue(
            at: path,
            errors: &errors,
            message: "\(label) IntelliJ delay must be a whole number of milliseconds",
            suggestion: "Use a whole-number delay or remove the delay"
          )
        }
      }
    default:
      if action.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        appendInvalidActionValue(
          at: path,
          errors: &errors,
          message: "\(label) value is required",
          suggestion: "Enter a value for this action"
        )
      }
    }
  }

  private static func validateMacroSteps(
    _ macroSteps: [MacroStep]?,
    at path: [Int],
    errors: inout [ValidationError],
    label: String
  ) {
    for (index, step) in (macroSteps ?? []).enumerated() {
      if !step.delay.isFinite || step.delay < 0 {
        appendInvalidActionValue(
          at: path,
          errors: &errors,
          message: "\(label) macro step \(index + 1) delay must be non-negative",
          suggestion: "Use a non-negative delay for each macro step"
        )
      }
      validateActionValue(
        step.action,
        at: path,
        errors: &errors,
        label: "\(label) macro step \(index + 1)"
      )
    }
  }

  private static func appendInvalidActionValue(
    at path: [Int],
    errors: inout [ValidationError],
    message: String,
    suggestion: String
  ) {
    errors.append(
      ValidationError(
        path: path,
        message: message,
        type: .invalidActionValue,
        suggestion: suggestion
      ))
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
