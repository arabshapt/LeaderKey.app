import AppKit  // For keycodes
import Foundation
import os

/// Fast lookup structure for O(1) key validation in configs.
/// Preprocesses a Group hierarchy into keyed maps for instant item lookup.
final class KeyLookupCache {
  /// Maps group ID + key to the matching ActionOrGroup for O(1) item lookup
  private var itemByKeyPerGroup: [UUID: [String: ActionOrGroup]] = [:]

  /// Maps group ID to its sticky mode setting
  private var stickyModePerGroup: [UUID: Bool] = [:]

  /// Maps group ID to child group IDs for traversal
  private var childGroupsPerGroup: [UUID: [UUID]] = [:]

  /// The root group ID
  private var rootGroupId: UUID?

  /// Thread-safe access
  private let queue = DispatchQueue(label: "com.leaderkey.keylookup", attributes: .concurrent)

  // MARK: - Building Cache

  /// Build the cache from a Group hierarchy
  func buildFromGroup(_ group: Group) {
    let spid = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: "KeyLookupCache.build", signpostID: spid)
    var itemByKeyPerGroup: [UUID: [String: ActionOrGroup]] = [:]
    var stickyModePerGroup: [UUID: Bool] = [:]
    var childGroupsPerGroup: [UUID: [UUID]] = [:]

    Self.processGroup(
      group,
      itemByKeyPerGroup: &itemByKeyPerGroup,
      stickyModePerGroup: &stickyModePerGroup,
      childGroupsPerGroup: &childGroupsPerGroup
    )

    queue.sync(flags: .barrier) {
      self.itemByKeyPerGroup = itemByKeyPerGroup
      self.stickyModePerGroup = stickyModePerGroup
      self.childGroupsPerGroup = childGroupsPerGroup
      self.rootGroupId = group.id
    }
    os_signpost(.end, log: signpostLog, name: "KeyLookupCache.build", signpostID: spid)
  }

  /// Recursively process a group and its children
  private static func processGroup(
    _ group: Group,
    itemByKeyPerGroup: inout [UUID: [String: ActionOrGroup]],
    stickyModePerGroup: inout [UUID: Bool],
    childGroupsPerGroup: inout [UUID: [UUID]]
  ) {
    var itemByKey = [String: ActionOrGroup]()
    var childGroups = [UUID]()

    // Process all actions in this group
    for actionOrGroup in group.actions {
      // Add the key if it exists
      if let key = actionOrGroup.item.key {
        itemByKey[key] = actionOrGroup
      }

      // If it's a subgroup, process it recursively
      if case .group(let subgroup) = actionOrGroup {
        childGroups.append(subgroup.id)
        processGroup(
          subgroup,
          itemByKeyPerGroup: &itemByKeyPerGroup,
          stickyModePerGroup: &stickyModePerGroup,
          childGroupsPerGroup: &childGroupsPerGroup
        )
      }
    }

    // Store the processed data
    itemByKeyPerGroup[group.id] = itemByKey
    stickyModePerGroup[group.id] = group.stickyMode ?? false
    childGroupsPerGroup[group.id] = childGroups
  }

  // MARK: - Querying Cache

  /// Check if a key exists in a specific group (O(1) lookup)
  func hasKey(_ key: String, inGroupId groupId: UUID) -> Bool {
    queue.sync {
      itemByKeyPerGroup[groupId]?[key] != nil
    }
  }

  /// Look up the ActionOrGroup for a key in a specific group (O(1) lookup)
  func getItem(forKey key: String, inGroupId groupId: UUID) -> ActionOrGroup? {
    queue.sync {
      itemByKeyPerGroup[groupId]?[key]
    }
  }

  /// Get all valid keys for a group
  func getValidKeys(forGroupId groupId: UUID) -> Set<String>? {
    queue.sync {
      guard let itemByKey = itemByKeyPerGroup[groupId] else { return nil }
      return Set(itemByKey.keys)
    }
  }

  /// Check if a group has sticky mode enabled
  func isStickyMode(forGroupId groupId: UUID) -> Bool {
    queue.sync {
      stickyModePerGroup[groupId] ?? false
    }
  }

  /// Get child group IDs for a group
  func getChildGroups(forGroupId groupId: UUID) -> [UUID] {
    queue.sync {
      childGroupsPerGroup[groupId] ?? []
    }
  }

  /// Check if a key exists anywhere in the config tree (for activation keys)
  func hasKeyAnywhere(_ key: String) -> Bool {
    queue.sync {
      for itemByKey in itemByKeyPerGroup.values {
        if itemByKey[key] != nil {
          return true
        }
      }
      return false
    }
  }

  /// Get root group ID
  func getRootGroupId() -> UUID? {
    queue.sync {
      rootGroupId
    }
  }

  /// Get all valid keycodes for a group (for sticky mode optimization)
  /// Returns a Set of keycodes that map to the valid keys in the group
  /// Note: This only works for keys that are in the englishKeymap/englishShiftedKeymap
  func getValidKeycodes(forGroupId groupId: UUID) -> Set<UInt16>? {
    queue.sync {
      guard let itemByKey = itemByKeyPerGroup[groupId] else { return nil }
      let keys = itemByKey.keys

      // For now, return a basic set of common keycodes
      // A more complete implementation would need access to the full keymap
      var keycodes = Set<UInt16>()

      // Map common keys to their keycodes
      // Letters a-z
      let letterMapping: [(String, UInt16)] = [
        ("a", 0x00), ("b", 0x0B), ("c", 0x08), ("d", 0x02), ("e", 0x0E), ("f", 0x03),
        ("g", 0x05), ("h", 0x04), ("i", 0x22), ("j", 0x26), ("k", 0x28), ("l", 0x25),
        ("m", 0x2E), ("n", 0x2D), ("o", 0x1F), ("p", 0x23), ("q", 0x0C), ("r", 0x0F),
        ("s", 0x01), ("t", 0x11), ("u", 0x20), ("v", 0x09), ("w", 0x0D), ("x", 0x07),
        ("y", 0x10), ("z", 0x06),
      ]

      // Numbers 0-9
      let numberMapping: [(String, UInt16)] = [
        ("1", 0x12), ("2", 0x13), ("3", 0x14), ("4", 0x15), ("5", 0x17),
        ("6", 0x16), ("7", 0x1A), ("8", 0x1C), ("9", 0x19), ("0", 0x1D),
      ]

      // Common punctuation
      let punctMapping: [(String, UInt16)] = [
        (",", 0x2B), (".", 0x2F), ("/", 0x2C), (";", 0x29), ("'", 0x27),
        ("-", 0x1B), ("=", 0x18), ("[", 0x21), ("]", 0x1E), ("\\", 0x2A),
      ]

      // Check each mapping
      for (char, code) in letterMapping + numberMapping + punctMapping {
        if keys.contains(char) || keys.contains(char.uppercased()) {
          keycodes.insert(code)
        }
      }

      return keycodes.isEmpty ? nil : keycodes
    }
  }

  // MARK: - Cache Management

  /// Clear all cached data
  func clear() {
    queue.sync(flags: .barrier) {
      self.itemByKeyPerGroup.removeAll()
      self.stickyModePerGroup.removeAll()
      self.childGroupsPerGroup.removeAll()
      self.rootGroupId = nil
    }
  }

  /// Get cache statistics for debugging
  func getCacheStats() -> String {
    queue.sync {
      let groupCount = itemByKeyPerGroup.count
      let totalKeys = itemByKeyPerGroup.values.reduce(0) { $0 + $1.count }
      let stickyGroups = stickyModePerGroup.values.filter { $0 }.count

      return """
        KeyLookupCache Stats:
        - Groups: \(groupCount)
        - Total Keys: \(totalKeys)
        - Sticky Groups: \(stickyGroups)
        - Root ID: \(rootGroupId?.uuidString ?? "nil")
        """
    }
  }
}
