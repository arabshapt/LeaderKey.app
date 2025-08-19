import Foundation
import CoreGraphics

/// Lock-free event queue for ultra-fast event tap callbacks
/// Uses atomic operations to avoid blocking in the critical path
final class LockFreeEventQueue {
    /// Event wrapper to store in the queue
    struct EventEntry {
        let event: CGEvent
        let timestamp: UInt64
        let keyCode: UInt16?
        let modifiers: CGEventFlags
    }
    
    /// Ring buffer for events
    private let capacity: Int
    private let buffer: UnsafeMutablePointer<EventEntry?>
    private let mask: Int
    
    /// Atomic head and tail indices
    private let head = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    private let tail = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    
    /// Performance tracking
    private let enqueueCount = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    private let dequeueCount = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    private let dropCount = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    
    /// Initialize with power-of-2 capacity for fast modulo
    init(capacity: Int = 256) {
        // Ensure capacity is power of 2
        var powerOf2 = 1
        while powerOf2 < capacity {
            powerOf2 <<= 1
        }
        self.capacity = powerOf2
        self.mask = powerOf2 - 1
        
        // Allocate buffer
        self.buffer = UnsafeMutablePointer<EventEntry?>.allocate(capacity: powerOf2)
        for i in 0..<powerOf2 {
            buffer[i] = nil
        }
        
        // Initialize atomic counters
        head.initialize(to: 0)
        tail.initialize(to: 0)
        enqueueCount.initialize(to: 0)
        dequeueCount.initialize(to: 0)
        dropCount.initialize(to: 0)
    }
    
    deinit {
        // Clean up remaining events
        while dequeue() != nil {
            // Drain queue
        }
        
        // Deallocate memory
        buffer.deallocate()
        head.deallocate()
        tail.deallocate()
        enqueueCount.deallocate()
        dequeueCount.deallocate()
        dropCount.deallocate()
    }
    
    /// Enqueue event - lock-free, returns false if queue is full
    @inline(__always)
    func enqueue(_ event: CGEvent) -> Bool {
        let timestamp = mach_absolute_time()
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let modifiers = event.flags
        
        let entry = EventEntry(
            event: event.copy()!,
            timestamp: timestamp,
            keyCode: keyCode,
            modifiers: modifiers
        )
        
        // Load current tail with acquire ordering
        let currentTail = OSAtomicAdd64Barrier(0, tail)
        let nextTail = currentTail + 1
        
        // Load head with acquire ordering
        let currentHead = OSAtomicAdd64Barrier(0, head)
        
        // Check if queue is full
        if nextTail - currentHead > capacity {
            // Queue full, increment drop count
            OSAtomicIncrement64(dropCount)
            return false
        }
        
        // Store entry at tail position
        let index = Int(currentTail & Int64(mask))
        buffer[index] = entry
        
        // Update tail with release ordering
        OSAtomicCompareAndSwap64Barrier(currentTail, nextTail, tail)
        
        // Increment enqueue count
        OSAtomicIncrement64(enqueueCount)
        
        return true
    }
    
    /// Dequeue event - lock-free, returns nil if queue is empty
    @inline(__always)
    func dequeue() -> EventEntry? {
        // Load head with acquire ordering
        let currentHead = OSAtomicAdd64Barrier(0, head)
        
        // Load tail with acquire ordering
        let currentTail = OSAtomicAdd64Barrier(0, tail)
        
        // Check if queue is empty
        if currentHead >= currentTail {
            return nil
        }
        
        // Load entry at head position
        let index = Int(currentHead & Int64(mask))
        guard let entry = buffer[index] else {
            // Spurious empty slot, advance head anyway
            OSAtomicCompareAndSwap64Barrier(currentHead, currentHead + 1, head)
            return nil
        }
        
        // Clear buffer slot
        buffer[index] = nil
        
        // Update head with release ordering
        OSAtomicCompareAndSwap64Barrier(currentHead, currentHead + 1, head)
        
        // Increment dequeue count
        OSAtomicIncrement64(dequeueCount)
        
        return entry
    }
    
    /// Try to dequeue multiple events at once for batch processing
    func dequeueBatch(maxCount: Int = 10) -> [EventEntry] {
        var events: [EventEntry] = []
        events.reserveCapacity(maxCount)
        
        for _ in 0..<maxCount {
            guard let entry = dequeue() else {
                break
            }
            events.append(entry)
        }
        
        return events
    }
    
    /// Get current queue size (approximate due to concurrent access)
    @inline(__always)
    var size: Int {
        let currentTail = OSAtomicAdd64Barrier(0, tail)
        let currentHead = OSAtomicAdd64Barrier(0, head)
        let size = currentTail - currentHead
        return size > 0 ? min(Int(size), capacity) : 0
    }
    
    /// Check if queue is empty
    @inline(__always)
    var isEmpty: Bool {
        let currentTail = OSAtomicAdd64Barrier(0, tail)
        let currentHead = OSAtomicAdd64Barrier(0, head)
        return currentHead >= currentTail
    }
    
    /// Get performance statistics
    func getStatistics() -> (enqueued: Int64, dequeued: Int64, dropped: Int64) {
        return (
            enqueued: OSAtomicAdd64Barrier(0, enqueueCount),
            dequeued: OSAtomicAdd64Barrier(0, dequeueCount),
            dropped: OSAtomicAdd64Barrier(0, dropCount)
        )
    }
    
    /// Reset statistics
    func resetStatistics() {
        OSAtomicCompareAndSwap64Barrier(OSAtomicAdd64Barrier(0, enqueueCount), 0, enqueueCount)
        OSAtomicCompareAndSwap64Barrier(OSAtomicAdd64Barrier(0, dequeueCount), 0, dequeueCount)
        OSAtomicCompareAndSwap64Barrier(OSAtomicAdd64Barrier(0, dropCount), 0, dropCount)
    }
}

/// High-resolution timing utilities for performance monitoring
struct MachTime {
    private static var timebaseInfo: mach_timebase_info = {
        var info = mach_timebase_info()
        mach_timebase_info(&info)
        return info
    }()
    
    /// Convert Mach time to nanoseconds
    @inline(__always)
    static func toNanoseconds(_ machTime: UInt64) -> UInt64 {
        return machTime * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)
    }
    
    /// Convert Mach time to milliseconds
    @inline(__always)
    static func toMilliseconds(_ machTime: UInt64) -> Double {
        return Double(toNanoseconds(machTime)) / 1_000_000.0
    }
    
    /// Get current Mach time
    @inline(__always)
    static func now() -> UInt64 {
        return mach_absolute_time()
    }
    
    /// Measure execution time of a block in milliseconds
    @inline(__always)
    static func measure<T>(_ block: () throws -> T) rethrows -> (result: T, milliseconds: Double) {
        let start = now()
        let result = try block()
        let elapsed = now() - start
        return (result, toMilliseconds(elapsed))
    }
}