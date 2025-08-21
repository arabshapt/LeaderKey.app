import Foundation

/// Fast lookup structure for O(1) key validation in configs
/// Pre-processes a Group hierarchy into efficient HashSets for instant key lookups
final class KeyLookupCache {
    /// Maps group ID to the set of valid key strings in that group
    private var validKeysPerGroup: [UUID: Set<String>] = [:]
    
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
        queue.async(flags: .barrier) {
            self.validKeysPerGroup.removeAll()
            self.stickyModePerGroup.removeAll()
            self.childGroupsPerGroup.removeAll()
            self.rootGroupId = group.id
            
            self.processGroup(group)
        }
    }
    
    /// Recursively process a group and its children
    private func processGroup(_ group: Group) {
        var validKeys = Set<String>()
        var childGroups = [UUID]()
        
        // Process all actions in this group
        for actionOrGroup in group.actions {
            // Add the key if it exists
            if let key = actionOrGroup.item.key {
                validKeys.insert(key)
            }
            
            // If it's a subgroup, process it recursively
            if case .group(let subgroup) = actionOrGroup {
                childGroups.append(subgroup.id)
                processGroup(subgroup)
            }
        }
        
        // Store the processed data
        validKeysPerGroup[group.id] = validKeys
        stickyModePerGroup[group.id] = group.stickyMode ?? false
        childGroupsPerGroup[group.id] = childGroups
    }
    
    // MARK: - Querying Cache
    
    /// Check if a key exists in a specific group (O(1) lookup)
    func hasKey(_ key: String, inGroupId groupId: UUID) -> Bool {
        queue.sync {
            validKeysPerGroup[groupId]?.contains(key) ?? false
        }
    }
    
    /// Get all valid keys for a group
    func getValidKeys(forGroupId groupId: UUID) -> Set<String>? {
        queue.sync {
            validKeysPerGroup[groupId]
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
            for (_, keys) in validKeysPerGroup {
                if keys.contains(key) {
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
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clear() {
        queue.async(flags: .barrier) {
            self.validKeysPerGroup.removeAll()
            self.stickyModePerGroup.removeAll()
            self.childGroupsPerGroup.removeAll()
            self.rootGroupId = nil
        }
    }
    
    /// Get cache statistics for debugging
    func getCacheStats() -> String {
        queue.sync {
            let groupCount = validKeysPerGroup.count
            let totalKeys = validKeysPerGroup.values.reduce(0) { $0 + $1.count }
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