import Foundation

/// Thread-safe cache for parsed configuration groups to avoid repeated JSON parsing
final class ConfigCache {
    private let cache = NSCache<NSString, CacheEntry>()
    private let queue = DispatchQueue(label: "com.leaderkey.configcache", attributes: .concurrent)
    private let maxCacheAge: TimeInterval = 30 // Reduced from 60s to 30s for aggressive memory management
    
    /// Wrapper to store both the config and its timestamp
    private class CacheEntry {
        let group: Group
        let timestamp: Date
        let fileModificationDate: Date?
        
        init(group: Group, fileModificationDate: Date? = nil) {
            self.group = group
            self.timestamp = Date()
            self.fileModificationDate = fileModificationDate
        }
        
        func isExpired(maxAge: TimeInterval) -> Bool {
            Date().timeIntervalSince(timestamp) > maxAge
        }
    }
    
    init() {
        // Aggressive cache limits for memory optimization
        cache.countLimit = 10 // Reduced from 50 to 10 configs in memory
        cache.totalCostLimit = 2 * 1024 * 1024 // Reduced from 10MB to 2MB max
    }
    
    /// Get cached config if available and not expired
    func getConfig(for path: String, fileModificationDate: Date? = nil) -> Group? {
        queue.sync {
            guard let entry = cache.object(forKey: path as NSString) else { return nil }
            
            // Check if cache is expired
            if entry.isExpired(maxAge: maxCacheAge) {
                cache.removeObject(forKey: path as NSString)
                return nil
            }
            
            // Check if file has been modified since caching
            if let fileMod = fileModificationDate,
               let cachedMod = entry.fileModificationDate,
               fileMod > cachedMod {
                cache.removeObject(forKey: path as NSString)
                return nil
            }
            
            return entry.group
        }
    }
    
    /// Store config in cache
    func setConfig(_ group: Group, for path: String, fileModificationDate: Date? = nil) {
        queue.async(flags: .barrier) {
            let entry = CacheEntry(group: group, fileModificationDate: fileModificationDate)
            // Estimate size based on number of items (rough approximation)
            let estimatedCost = self.estimateCost(for: group)
            self.cache.setObject(entry, forKey: path as NSString, cost: estimatedCost)
        }
    }
    
    /// Clear all cached configs
    func clearCache() {
        queue.async(flags: .barrier) {
            self.cache.removeAllObjects()
        }
    }
    
    /// Remove specific config from cache
    func removeConfig(for path: String) {
        queue.async(flags: .barrier) {
            self.cache.removeObject(forKey: path as NSString)
        }
    }
    
    /// Estimate memory cost of a group for cache limits
    private func estimateCost(for group: Group) -> Int {
        var itemCount = 0
        
        func countItems(_ items: [ActionOrGroup]) {
            for item in items {
                itemCount += 1
                if case .group(let subgroup) = item {
                    countItems(subgroup.actions)
                }
            }
        }
        
        countItems(group.actions)
        // Rough estimate: 1KB per item
        return itemCount * 1024
    }
    
    /// Performance monitoring wrapper
    static func measureParsing<T>(_ label: String = "JSON Parsing", block: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            if elapsed > 0.05 { // Log operations taking more than 50ms
                print("[ConfigCache] \(label) took \(String(format: "%.3f", elapsed))s")
            }
        }
        return try block()
    }
}