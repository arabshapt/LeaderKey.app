import Cocoa
import SwiftUI

// Caches the measured size of each Group's view to avoid layout flicker.
// Keyed by Group.id (UUID).
final class ViewSizeCache {
    static let shared = ViewSizeCache()
    private var cache: [UUID: NSSize] = [:]
    private let lock = NSLock()

    private init() {}

    func size(for group: Group) -> NSSize? {
        lock.lock(); defer { lock.unlock() }
        return cache[group.id]
    }

    func store(_ size: NSSize, for group: Group) {
        lock.lock(); defer { lock.unlock() }
        cache[group.id] = size
    }

    func clear() {
        lock.lock(); defer { lock.unlock() }
        cache.removeAll()
    }
} 