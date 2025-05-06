import Foundation

struct ValidationError: Identifiable, Equatable {
  let id = UUID()
  let path: [Int]  // Path to the item with the error (indices in the actions array)
  let message: String
  let type: ValidationErrorType

  static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
    lhs.id == rhs.id
  }
}

enum ValidationErrorType {
  case emptyKey
  case nonSingleCharacterKey
  case duplicateKey
}

class ConfigValidator {
  static func validate(group: Group) -> [ValidationError] {
    print("[VALIDATOR LOG] validate: CALLED for group key '\(group.key ?? "nil")', label '\(group.label ?? "no_label")'.")
    // print("[VALIDATOR LOG] validate: Group details: \(group)") // Could be too verbose
    var errors = [ValidationError]()
    validateGroup(group, path: [], errors: &errors)
    print("[VALIDATOR LOG] validate: FINISHED. Total errors found: \(errors.count)")
    return errors
  }

  private static func validateGroup(_ group: Group, path: [Int], errors: inout [ValidationError]) {
    let groupIdentifier = "Group (key: '\(group.key ?? "nil")', label: '\(group.label ?? "no_label")') at path \(path)"
    print("[VALIDATOR LOG] validateGroup: CALLED for \(groupIdentifier). Current errors count: \(errors.count)")

    // Check if the group key is valid (if not root level)
    if !path.isEmpty {
      print("[VALIDATOR LOG] validateGroup: Validating key for \(groupIdentifier).")
      validateKey(group.key, at: path, errors: &errors)
    } else {
      print("[VALIDATOR LOG] validateGroup: Skipping key validation for root group (path is empty).")
    }

    // Check for duplicate keys within this group
    var keysInGroup = [String: Int]()  // key: index
    print("[VALIDATOR LOG] validateGroup: Iterating \(group.actions.count) actions in \(groupIdentifier).")

    for (index, item) in group.actions.enumerated() {
      let currentPath = path + [index]
      let itemKey = item.item.key
      let itemType = String(describing: item.item.type)
      print("[VALIDATOR LOG] validateGroup: Processing item at index \(index) (key: '\(itemKey ?? "nil")', type: \(itemType)) in \(groupIdentifier). New path: \(currentPath)")

      let keyToValidate: String?
      switch item {
      case .action(let action):
        keyToValidate = action.key
        print("[VALIDATOR LOG] validateGroup: Item is ACTION. Validating its key '\(keyToValidate ?? "nil")' at path \(currentPath).")
        validateKey(keyToValidate, at: currentPath, errors: &errors)
      case .group(let subgroup):
        keyToValidate = subgroup.key // Key for duplicate check
        print("[VALIDATOR LOG] validateGroup: Item is GROUP (key: '\(subgroup.key ?? "nil")', label: '\(subgroup.label ?? "no_label")'). Recursively calling validateGroup for path \(currentPath).")
        // Note: We don't validate the key here directly with validateKey because it will be validated in the recursive call to validateGroup.
        validateGroup(subgroup, path: currentPath, errors: &errors)
      }

      // Check for duplicates using keyToValidate
      if let currentItemKey = keyToValidate, !currentItemKey.isEmpty {
        print("[VALIDATOR LOG] validateGroup: Checking for duplicate key '\(currentItemKey)' in \(groupIdentifier).")
        if let existingIndex = keysInGroup[currentItemKey] {
          let duplicatePath = path + [existingIndex]
          print("[VALIDATOR LOG] validateGroup: DUPLICATE KEY FOUND for '\(currentItemKey)' in \(groupIdentifier). Original at path \(duplicatePath), new at \(currentPath).")
          errors.append(
            ValidationError(
              path: duplicatePath,
              message: "Multiple actions for the same key '\(currentItemKey)'",
              type: .duplicateKey
            ))
          errors.append(
            ValidationError(
              path: currentPath,
              message: "Multiple actions for the same key '\(currentItemKey)'",
              type: .duplicateKey
            ))
        } else {
          keysInGroup[currentItemKey] = index
        }
      }
    }
  }

  private static func validateKey(_ key: String?, at path: [Int], errors: inout [ValidationError]) {
    print("[VALIDATOR LOG] validateKey: CALLED for key '\(key ?? "nil_provided")' at path \(path).")
    guard let key = key else {
      print("[VALIDATOR LOG] validateKey: Key is MISSING (nil) at path \(path). Adding .emptyKey error.")
      errors.append(
        ValidationError(
          path: path,
          message: "Key is missing",
          type: .emptyKey
        ))
      return
    }

    if key.isEmpty {
      print("[VALIDATOR LOG] validateKey: Key is EMPTY STRING at path \(path). Adding .emptyKey error.")
      errors.append(
        ValidationError(
          path: path,
          message: "Key is empty",
          type: .emptyKey
        ))
      return
    }

    if key.count != 1 {
      print("[VALIDATOR LOG] validateKey: Key '\(key)' is NOT SINGLE CHARACTER (count: \(key.count)) at path \(path). Adding .nonSingleCharacterKey error.")
      errors.append(
        ValidationError(
          path: path,
          message: "Key must be a single character",
          type: .nonSingleCharacterKey
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
