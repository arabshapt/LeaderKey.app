import Foundation
import os

/// Thread-safe cache for parsed configuration groups to avoid repeated JSON parsing
final class ConfigCache {
  private let cache = NSCache<NSString, CacheEntry>()
  // NSLock instead of a concurrent queue + barriers: barrier blocks need a
  // GCD pool thread, so readers blocked in queue.sync deadlock when the pool
  // is exhausted. A lock releases directly to a waiting thread.
  private let lock = NSLock()
  private let maxCacheAge: TimeInterval = 60  // Cache for 1 minute

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
    // Configure cache limits
    cache.countLimit = 50  // Max 50 configs in memory
    cache.totalCostLimit = 10 * 1024 * 1024  // 10MB max
  }

  /// Get cached config if available and not expired
  func getConfig(for path: String, fileModificationDate: Date? = nil) -> Group? {
    lock.lock()
    defer { lock.unlock() }

    guard let entry = cache.object(forKey: path as NSString) else { return nil }

    // Check if cache is expired
    if entry.isExpired(maxAge: maxCacheAge) {
      cache.removeObject(forKey: path as NSString)
      return nil
    }

    // Check if file has been modified since caching
    if let fileMod = fileModificationDate,
      let cachedMod = entry.fileModificationDate,
      fileMod > cachedMod
    {
      cache.removeObject(forKey: path as NSString)
      return nil
    }

    return entry.group
  }

  /// Store config in cache
  func setConfig(_ group: Group, for path: String, fileModificationDate: Date? = nil) {
    let entry = CacheEntry(group: group, fileModificationDate: fileModificationDate)
    // Estimate size based on number of items (rough approximation)
    let estimatedCost = estimateCost(for: group)
    lock.lock()
    defer { lock.unlock() }
    cache.setObject(entry, forKey: path as NSString, cost: estimatedCost)
  }

  /// Clear all cached configs
  func clearCache() {
    lock.lock()
    defer { lock.unlock() }
    cache.removeAllObjects()
  }

  /// Remove specific config from cache
  func removeConfig(for path: String) {
    lock.lock()
    defer { lock.unlock() }
    cache.removeObject(forKey: path as NSString)
  }

  /// Estimate memory cost of a group for cache limits
  private func estimateCost(for group: Group) -> Int {
    var itemCount = 0

    func countItems(_ items: [ActionOrGroup]) {
      for item in items {
        itemCount += 1
        if case .group(let subgroup) = item {
          countItems(subgroup.actions)
        } else if case .layer(let layer) = item {
          countItems(layer.actions)
        }
      }
    }

    countItems(group.actions)
    // Rough estimate: 1KB per item
    return itemCount * 1024
  }

  /// Performance monitoring wrapper
  static func measureParsing<T>(_ label: String = "JSON Parsing", block: () throws -> T) rethrows
    -> T
  {
    let spid = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: "ConfigCache.parse", signpostID: spid, "%{public}s", label)
    let start = CFAbsoluteTimeGetCurrent()
    defer {
      let elapsed = CFAbsoluteTimeGetCurrent() - start
      os_signpost(.end, log: signpostLog, name: "ConfigCache.parse", signpostID: spid)
      if elapsed > 0.05 {  // Log operations taking more than 50ms
        print("[ConfigCache] \(label) took \(String(format: "%.3f", elapsed))s")
      }
    }
    return try block()
  }
}
