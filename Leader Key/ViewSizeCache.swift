import Cocoa
import SwiftUI

// Caches the measured size of each Group's view to avoid layout flicker.
// Keyed by Group.id (UUID).
final class ViewSizeCache {
    static let shared = ViewSizeCache()
    private var cache: [UUID: NSSize] = [:]
    private let lock = NSLock()
    private let maxEntries = 64 // Reduced from 256 to 64 for aggressive memory optimization

    private init() {}

    func size(for group: Group) -> NSSize? {
        lock.lock(); defer { lock.unlock() }
        return cache[group.id]
    }

    func store(_ size: NSSize, for group: Group) {
        lock.lock(); defer { lock.unlock() }
        if cache.count >= maxEntries {
            cache.removeAll() // prevent unbounded growth in long sessions
        }
        cache[group.id] = size
    }

    func clear() {
        lock.lock(); defer { lock.unlock() }
        cache.removeAll()
    }
}
