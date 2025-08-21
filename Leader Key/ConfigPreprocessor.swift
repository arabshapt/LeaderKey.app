import Foundation

/// Manages preprocessed config caches for efficient key lookups
/// Each app's merged config is preprocessed into a KeyLookupCache for O(1) lookups
final class ConfigPreprocessor {
    /// Cache of preprocessed configs per bundle ID (or "global" for default config)
    private var processedConfigs: [String: KeyLookupCache] = [:]
    
    /// Track when configs were last preprocessed for cache invalidation
    private var preprocessTimestamps: [String: Date] = [:]
    
    /// Thread-safe access
    private let queue = DispatchQueue(label: "com.leaderkey.configpreprocessor", attributes: .concurrent)
    
    /// Singleton instance
    static let shared = ConfigPreprocessor()
    
    private init() {}
    
    // MARK: - Preprocessing
    
    /// Preprocess a merged config into an efficient lookup structure
    /// - Parameters:
    ///   - config: The merged Group to preprocess
    ///   - identifier: Bundle ID for app configs, or "global" for default config
    /// - Returns: The preprocessed KeyLookupCache
    @discardableResult
    func preprocessConfig(_ config: Group, for identifier: String) -> KeyLookupCache {
        let cache = KeyLookupCache()
        cache.buildFromGroup(config)
        
        // Store the preprocessed cache
        queue.async(flags: .barrier) {
            self.processedConfigs[identifier] = cache
            self.preprocessTimestamps[identifier] = Date()
        }
        
        #if DEBUG
        print("[ConfigPreprocessor] Preprocessed config for '\(identifier)'")
        print(cache.getCacheStats())
        #endif
        
        return cache
    }
    
    // MARK: - Retrieval
    
    /// Get preprocessed config for a bundle ID
    /// - Parameter identifier: Bundle ID for app configs, or "global" for default config
    /// - Returns: The preprocessed KeyLookupCache if available
    func getProcessedConfig(for identifier: String?) -> KeyLookupCache? {
        let key = identifier ?? "global"
        return queue.sync {
            processedConfigs[key]
        }
    }
    
    /// Get or create preprocessed config
    /// - Parameters:
    ///   - config: The Group to preprocess if not cached
    ///   - identifier: Bundle ID for app configs, or "global" for default config
    /// - Returns: The preprocessed KeyLookupCache
    func getOrCreateProcessedConfig(_ config: Group, for identifier: String) -> KeyLookupCache {
        if let existing = getProcessedConfig(for: identifier) {
            return existing
        }
        return preprocessConfig(config, for: identifier)
    }
    
    // MARK: - Cache Management
    
    /// Invalidate a specific preprocessed config
    func invalidateConfig(for identifier: String) {
        queue.async(flags: .barrier) {
            self.processedConfigs.removeValue(forKey: identifier)
            self.preprocessTimestamps.removeValue(forKey: identifier)
        }
        
        #if DEBUG
        print("[ConfigPreprocessor] Invalidated config for '\(identifier)'")
        #endif
    }
    
    /// Invalidate all preprocessed configs
    func invalidateAll() {
        queue.async(flags: .barrier) {
            self.processedConfigs.removeAll()
            self.preprocessTimestamps.removeAll()
        }
        
        #if DEBUG
        print("[ConfigPreprocessor] Invalidated all configs")
        #endif
    }
    
    /// Check if a config needs reprocessing based on file modification time
    func needsReprocessing(for identifier: String, fileModificationDate: Date?) -> Bool {
        guard let fileModDate = fileModificationDate else { return false }
        
        return queue.sync {
            guard let preprocessTime = preprocessTimestamps[identifier] else {
                return true // Not preprocessed yet
            }
            return fileModDate > preprocessTime
        }
    }
    
    // MARK: - Statistics
    
    /// Get cache statistics for debugging
    func getCacheStatistics() -> String {
        queue.sync {
            var stats = "ConfigPreprocessor Statistics:\n"
            stats += "Cached Configs: \(processedConfigs.count)\n"
            
            for (identifier, cache) in processedConfigs {
                stats += "\n[\(identifier)]:\n"
                stats += cache.getCacheStats()
            }
            
            return stats
        }
    }
    
    /// Get list of all cached identifiers
    func getCachedIdentifiers() -> [String] {
        queue.sync {
            Array(processedConfigs.keys)
        }
    }
}