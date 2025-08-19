import Foundation
import CoreGraphics

/// Manages dual event taps with instant failover for ultimate reliability
/// Ensures LeaderKey continues working even if macOS disables one tap
final class DualEventTapManager {
    
    // MARK: - Tap State
    
    private var primaryTap: CFMachPort?
    private var secondaryTap: CFMachPort?
    private var primarySource: CFRunLoopSource?
    private var secondarySource: CFRunLoopSource?
    
    /// Which tap is currently active (0 = primary, 1 = secondary)
    private let activeTapIndex = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    
    /// Health status for each tap
    private let primaryHealthy = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    private let secondaryHealthy = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    
    /// Recovery state
    private let isRecovering = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    private var recoveryTimer: Timer?
    private let recoveryQueue = DispatchQueue(label: "com.leaderkey.tap.recovery", qos: .userInteractive)
    
    /// Statistics
    private let failoverCount = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    private let recoveryAttempts = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    private let successfulRecoveries = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
    
    // MARK: - Initialization
    
    init() {
        // Initialize atomic variables
        activeTapIndex.initialize(to: 0) // Start with primary
        primaryHealthy.initialize(to: 0)
        secondaryHealthy.initialize(to: 0)
        isRecovering.initialize(to: 0)
        failoverCount.initialize(to: 0)
        recoveryAttempts.initialize(to: 0)
        successfulRecoveries.initialize(to: 0)
    }
    
    deinit {
        stopDualTaps()
        
        // Deallocate atomic pointers
        activeTapIndex.deallocate()
        primaryHealthy.deallocate()
        secondaryHealthy.deallocate()
        isRecovering.deallocate()
        failoverCount.deallocate()
        recoveryAttempts.deallocate()
        successfulRecoveries.deallocate()
    }
    
    // MARK: - Dual Tap Management
    
    /// Create both event taps with the same configuration
    func createDualTaps(
        callback: CGEventTapCallBack,
        userInfo: UnsafeMutableRawPointer?
    ) -> Bool {
        print("[DualEventTapManager] Creating dual event taps for redundancy...")
        
        let eventMask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)
        
        // Create primary tap
        if let primary = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: userInfo
        ) {
            primaryTap = primary
            let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, primary, 0)
            primarySource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: primary, enable: true)
            OSAtomicCompareAndSwap32(0, 1, primaryHealthy)
            print("[DualEventTapManager] Primary tap created and enabled")
        } else {
            print("[DualEventTapManager] ⚠️ Failed to create primary tap")
        }
        
        // Create secondary tap with slight delay to avoid conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            if let secondary = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .tailAppendEventTap, // Different insertion point
                options: .defaultTap,
                eventsOfInterest: eventMask,
                callback: callback,
                userInfo: userInfo
            ) {
                self.secondaryTap = secondary
                let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, secondary, 0)
                self.secondarySource = source
                CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
                CGEvent.tapEnable(tap: secondary, enable: false) // Start disabled
                OSAtomicCompareAndSwap32(0, 1, self.secondaryHealthy)
                print("[DualEventTapManager] Secondary tap created (standby mode)")
            } else {
                print("[DualEventTapManager] ⚠️ Failed to create secondary tap")
            }
        }
        
        // Start recovery monitoring
        startRecoveryMonitoring()
        
        return primaryTap != nil
    }
    
    /// Get the currently active tap
    @inline(__always)
    func getActiveTap() -> CFMachPort? {
        let index = OSAtomicAdd32(0, activeTapIndex)
        return index == 0 ? primaryTap : secondaryTap
    }
    
    /// Check tap health and perform instant failover if needed
    @inline(__always)
    func checkAndFailover() -> Bool {
        // Check primary tap
        if let primary = primaryTap {
            let isEnabled = CGEvent.tapIsEnabled(tap: primary)
            let wasHealthy = OSAtomicAdd32(0, primaryHealthy) == 1
            
            if isEnabled && !wasHealthy {
                // Primary recovered!
                print("[DualEventTapManager] 🎉 Primary tap recovered")
                OSAtomicCompareAndSwap32(0, 1, primaryHealthy)
                
                // Switch back to primary if we were on secondary
                if OSAtomicAdd32(0, activeTapIndex) == 1 {
                    // Disable secondary, enable primary
                    if let secondary = secondaryTap {
                        CGEvent.tapEnable(tap: secondary, enable: false)
                    }
                    OSAtomicCompareAndSwap32(1, 0, activeTapIndex)
                    print("[DualEventTapManager] Switched back to primary tap")
                }
                return true
            } else if !isEnabled && wasHealthy {
                // Primary just failed!
                print("[DualEventTapManager] ⚠️ Primary tap disabled by system")
                OSAtomicCompareAndSwap32(1, 0, primaryHealthy)
                
                // Instant failover to secondary
                if let secondary = secondaryTap {
                    CGEvent.tapEnable(tap: secondary, enable: true)
                    OSAtomicCompareAndSwap32(0, 1, activeTapIndex)
                    OSAtomicIncrement64(failoverCount)
                    print("[DualEventTapManager] 🔄 Instant failover to secondary tap")
                    
                    // Try to re-enable primary in background
                    triggerRecovery()
                    return true
                }
            }
        }
        
        // Check secondary tap if it's active
        if OSAtomicAdd32(0, activeTapIndex) == 1, let secondary = secondaryTap {
            if !CGEvent.tapIsEnabled(tap: secondary) {
                // Secondary also disabled! Try to re-enable
                print("[DualEventTapManager] ⚠️ Secondary tap also disabled!")
                CGEvent.tapEnable(tap: secondary, enable: true)
                
                // Also try primary again
                if let primary = primaryTap {
                    CGEvent.tapEnable(tap: primary, enable: true)
                    if CGEvent.tapIsEnabled(tap: primary) {
                        OSAtomicCompareAndSwap32(1, 0, activeTapIndex)
                        OSAtomicCompareAndSwap32(0, 1, primaryHealthy)
                        print("[DualEventTapManager] Emergency switch back to primary")
                        return true
                    }
                }
            }
        }
        
        return getActiveTap() != nil
    }
    
    /// Re-enable a tap inline (called from callback for ultra-fast recovery)
    @inline(__always)
    func inlineReenableTaps() {
        // DO NOT CALL THIS FROM CALLBACK - TOO SLOW!
        // This function makes system calls which can take 10-50ms
        // Health checking should only happen in background timer
    }
    
    // MARK: - Recovery System
    
    private func startRecoveryMonitoring() {
        // Monitor tap health every 2 seconds
        recoveryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkAndFailover()
        }
    }
    
    private func triggerRecovery() {
        // Avoid multiple simultaneous recovery attempts
        guard OSAtomicCompareAndSwap32(0, 1, isRecovering) else { return }
        
        OSAtomicIncrement64(recoveryAttempts)
        
        recoveryQueue.async { [weak self] in
            guard let self = self else { return }
            
            print("[DualEventTapManager] Starting recovery attempt...")
            
            // Try to recover primary tap
            if let primary = self.primaryTap {
                for attempt in 1...5 {
                    CGEvent.tapEnable(tap: primary, enable: true)
                    usleep(100_000 * UInt32(attempt)) // Progressive delay
                    
                    if CGEvent.tapIsEnabled(tap: primary) {
                        OSAtomicCompareAndSwap32(0, 1, self.primaryHealthy)
                        OSAtomicIncrement64(self.successfulRecoveries)
                        print("[DualEventTapManager] ✅ Primary tap recovered after \(attempt) attempts")
                        break
                    }
                }
            }
            
            // Reset recovery flag
            OSAtomicCompareAndSwap32(1, 0, self.isRecovering)
        }
    }
    
    /// Stop both taps and cleanup
    func stopDualTaps() {
        print("[DualEventTapManager] Stopping dual taps...")
        
        // Stop recovery timer
        recoveryTimer?.invalidate()
        recoveryTimer = nil
        
        // Disable and remove primary tap
        if let source = primarySource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            primarySource = nil
        }
        if let tap = primaryTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            primaryTap = nil
        }
        
        // Disable and remove secondary tap
        if let source = secondarySource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            secondarySource = nil
        }
        if let tap = secondaryTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            secondaryTap = nil
        }
        
        print("[DualEventTapManager] Dual taps stopped")
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> String {
        let failovers = OSAtomicAdd64(0, failoverCount)
        let attempts = OSAtomicAdd64(0, recoveryAttempts)
        let recoveries = OSAtomicAdd64(0, successfulRecoveries)
        let activeIndex = OSAtomicAdd32(0, activeTapIndex)
        let primaryOk = OSAtomicAdd32(0, primaryHealthy) == 1
        let secondaryOk = OSAtomicAdd32(0, secondaryHealthy) == 1
        
        return """
        Dual Tap Statistics:
        - Active Tap: \(activeIndex == 0 ? "Primary" : "Secondary")
        - Primary Healthy: \(primaryOk)
        - Secondary Healthy: \(secondaryOk)
        - Failovers: \(failovers)
        - Recovery Attempts: \(attempts)
        - Successful Recoveries: \(recoveries)
        """
    }
}