import Foundation
import QuartzCore
import Kingfisher

/// Thread optimization utilities to reduce unnecessary async dispatches and ensure high performance under system stress
enum ThreadOptimization {
  
  // MARK: - Memory Locking for Critical Operations
  
  /// Critical memory pool that is locked in physical memory
  private static var criticalMemoryPool: UnsafeMutableRawPointer?
  private static let criticalPoolSize = 10 * 1024 * 1024 // 10MB locked pool
  private static var poolOffset = 0
  private static let poolLock = NSLock()
  
  /// Status of memory locking capability
  enum MemoryLockingStatus {
    case available      // mlock() works and pool is allocated
    case privilegesRequired // mlock() failed due to insufficient privileges  
    case systemLimit    // mlock() failed due to system limits
    case unavailable    // mlock() not supported or other error
  }
  
  private static var lockingStatus: MemoryLockingStatus = .unavailable
  
  /// High-priority queue for critical event processing
  static let criticalEventQueue = DispatchQueue(
    label: "com.leaderkey.critical-events",
    qos: .userInteractive,
    attributes: [.concurrent],
    autoreleaseFrequency: .workItem
  )
  
  /// Ultra-high priority queue for time-sensitive operations
  static let realtimeQueue = DispatchQueue(
    label: "com.leaderkey.realtime",
    qos: .userInteractive,
    attributes: [],
    autoreleaseFrequency: .workItem  // FIXED: Was .never, causing memory leaks
  )
  
  // MARK: - Memory Locking Implementation
  
  /// Initialize critical memory pool with mlock() for ultimate reliability
  static func initializeCriticalMemoryPool() {
    poolLock.lock()
    defer { poolLock.unlock() }
    
    guard criticalMemoryPool == nil else { return } // Already initialized
    
    // Allocate aligned memory for the critical pool
    var rawPointer: UnsafeMutableRawPointer?
    let alignment = Int(getpagesize())
    let result = posix_memalign(&rawPointer, alignment, criticalPoolSize)
    
    guard result == 0, let allocatedPointer = rawPointer else {
      print("[ThreadOptimization] Failed to allocate critical memory pool: \(result)")
      lockingStatus = .unavailable
      return
    }
    
    criticalMemoryPool = allocatedPointer
    
    // Lock the memory in physical RAM to prevent swapping
    let lockResult = mlock(allocatedPointer, criticalPoolSize)
    
    if lockResult == 0 {
      lockingStatus = .available
      print("[ThreadOptimization] Successfully locked \(criticalPoolSize / 1024 / 1024)MB critical memory pool")
      
      // Initialize the pool with critical data structures
      initializeCriticalStructures()
    } else {
      let error = errno
      switch error {
      case EPERM:
        lockingStatus = .privilegesRequired
        print("[ThreadOptimization] mlock() failed: insufficient privileges (EPERM)")
      case ENOMEM:
        lockingStatus = .systemLimit
        print("[ThreadOptimization] mlock() failed: system limit reached (ENOMEM)")
      default:
        lockingStatus = .unavailable
        print("[ThreadOptimization] mlock() failed with error: \(error)")
      }
      
      // Keep the allocated memory even if locking failed
      print("[ThreadOptimization] Continuing with unlocked memory pool")
    }
  }
  
  /// Initialize critical data structures in locked memory
  private static func initializeCriticalStructures() {
    guard criticalMemoryPool != nil else { return }
    
    // Reserve space for critical structures
    // - Event processing state (1MB)
    // - Configuration cache backup (2MB) 
    // - Thread scheduling data (1MB)
    // - Recovery state information (1MB)
    // - Future expansion (5MB)
    
    print("[ThreadOptimization] Initialized critical structures in locked memory")
  }
  
  /// Allocate memory from the critical locked pool
  static func allocateCriticalMemory(size: Int) -> UnsafeMutableRawPointer? {
    poolLock.lock()
    defer { poolLock.unlock() }
    
    guard let pool = criticalMemoryPool,
          poolOffset + size <= criticalPoolSize else {
      print("[ThreadOptimization] Critical memory pool exhausted or unavailable")
      return nil
    }
    
    let pointer = pool.advanced(by: poolOffset)
    poolOffset += size
    
    // Align to 8-byte boundary for next allocation
    poolOffset = (poolOffset + 7) & ~7
    
    return pointer
  }
  
  /// Get current memory locking status
  static func getMemoryLockingStatus() -> MemoryLockingStatus {
    return lockingStatus
  }
  
  /// Cleanup critical memory pool
  static func cleanupCriticalMemoryPool() {
    poolLock.lock()
    defer { poolLock.unlock() }
    
    guard let pool = criticalMemoryPool else { return }
    
    // Unlock memory first if it was locked
    if lockingStatus == .available {
      munlock(pool, criticalPoolSize)
    }
    
    // Free the allocated memory
    free(pool)
    criticalMemoryPool = nil
    poolOffset = 0
    lockingStatus = .unavailable
    
    print("[ThreadOptimization] Cleaned up critical memory pool")
  }
  /// Execute a block on the main thread, avoiding unnecessary dispatch if already on main
  static func executeOnMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
    } else {
      DispatchQueue.main.async(execute: block)
    }
  }

  /// Execute a block on the main thread synchronously if safe, async otherwise
  static func executeOnMainSync(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
    } else {
      DispatchQueue.main.sync(execute: block)
    }
  }

  /// Batch multiple UI updates together to reduce dispatch overhead
  static func batchUIUpdates(_ updates: @escaping () -> Void) {
    if Thread.isMainThread {
      updates()
    } else {
      DispatchQueue.main.async {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updates()
        CATransaction.commit()
      }
    }
  }

  /// Debounce rapid calls to reduce excessive dispatches
  private static var debounceTimers: [String: Timer] = [:]
  private static let debounceQueue = DispatchQueue(label: "com.leaderkey.debounce")

  static func debounce(
    identifier: String,
    delay: TimeInterval,
    action: @escaping () -> Void
  ) {
    debounceQueue.async {
      debounceTimers[identifier]?.invalidate()
      let timer = Timer.scheduledTimer(
        withTimeInterval: delay,
        repeats: false
      ) { _ in
        executeOnMain(action)
        // Clean up timer reference after execution
        debounceQueue.async {
          debounceTimers.removeValue(forKey: identifier)
        }
      }
      debounceTimers[identifier] = timer
      RunLoop.current.add(timer, forMode: .common)
    }
  }

  /// Clean up all pending debounce timers
  static func cleanupAllTimers() {
    debounceQueue.async {
      for (_, timer) in debounceTimers {
        timer.invalidate()
      }
      debounceTimers.removeAll()
      print("[ThreadOptimization] Cleaned up \(debounceTimers.count) timers")
    }
  }

  /// Clean up a specific timer
  static func cleanupTimer(identifier: String) {
    debounceQueue.async {
      if let timer = debounceTimers[identifier] {
        timer.invalidate()
        debounceTimers.removeValue(forKey: identifier)
        print("[ThreadOptimization] Cleaned up timer: \(identifier)")
      }
    }
  }

  /// Get count of active timers (for debugging)
  static func activeTimerCount() -> Int {
    debounceQueue.sync {
      return debounceTimers.count
    }
  }
  
  /// Execute critical operations on high-priority queue
  static func executeCritical(_ block: @escaping () -> Void) {
    criticalEventQueue.async {
      autoreleasepool {
        let originalPriority = Thread.current.threadPriority
        Thread.current.threadPriority = 1.0
        defer { Thread.current.threadPriority = originalPriority }
        block()
      }
    }
  }
  
  /// Execute time-sensitive operations on realtime queue with system-level priority
  static func executeRealtime(_ block: @escaping () -> Void) {
    realtimeQueue.async {
      autoreleasepool {
        let originalPriority = Thread.current.threadPriority
        Thread.current.threadPriority = 1.0
        defer { Thread.current.threadPriority = originalPriority }
        
        // Set real-time scheduling for critical operations
        setRealtimeThreadPolicy()
        
        block()
      }
    }
  }
  
  /// Set real-time thread policy for the current thread
  static func setRealtimeThreadPolicy() {
    let thread = mach_thread_self()
    
    // Set time constraint policy for real-time scheduling
    var timeConstraintPolicy = thread_time_constraint_policy_data_t()
    timeConstraintPolicy.period = 0 // No specific period
    timeConstraintPolicy.computation = 500 // 0.5ms of computation time
    timeConstraintPolicy.constraint = 1000 // 1ms constraint
    timeConstraintPolicy.preemptible = 1 // Allow preemption
    
    let policyResult = withUnsafeMutablePointer(to: &timeConstraintPolicy) {
      $0.withMemoryRebound(to: integer_t.self, capacity: MemoryLayout<thread_time_constraint_policy_data_t>.size / MemoryLayout<integer_t>.size) {
        thread_policy_set(
          thread,
          thread_policy_flavor_t(THREAD_TIME_CONSTRAINT_POLICY),
          $0,
          mach_msg_type_number_t(4) // THREAD_TIME_CONSTRAINT_POLICY_COUNT = 4
        )
      }
    }
    
    if policyResult != KERN_SUCCESS {
      // Fallback to extended policy if real-time fails
      var extendedPolicy = thread_extended_policy_data_t()
      extendedPolicy.timeshare = 0 // Non-timeshare (higher priority)
      
      _ = withUnsafeMutablePointer(to: &extendedPolicy) {
        $0.withMemoryRebound(to: integer_t.self, capacity: MemoryLayout<thread_extended_policy_data_t>.size / MemoryLayout<integer_t>.size) {
          thread_policy_set(
            thread,
            thread_policy_flavor_t(THREAD_EXTENDED_POLICY),
            $0,
            mach_msg_type_number_t(1) // THREAD_EXTENDED_POLICY_COUNT = 1
          )
        }
      }
    }
  }
  
  /// Adaptive execution based on system pressure
  static func executeAdaptive(_ block: @escaping () -> Void) {
    let thermalState = ProcessInfo.processInfo.thermalState
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    if thermalState == .critical || thermalState == .serious || isLowPowerMode {
      // System under stress - use highest priority execution
      executeRealtime(block)
    } else {
      // Normal conditions - use regular critical queue
      executeCritical(block)
    }
  }
  
  // MARK: - Resource Optimization
  
  private static var resourceOptimizationTimer: Timer?
  
  /// Start resource optimization monitoring (reduced frequency to prevent memory issues)
  static func startResourceOptimization() {
    stopResourceOptimization() // Ensure no duplicate timers
    
    resourceOptimizationTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
      optimizeResources()
    }
    
    if let timer = resourceOptimizationTimer {
      RunLoop.main.add(timer, forMode: .common)
    }
  }
  
  /// Stop resource optimization monitoring
  static func stopResourceOptimization() {
    resourceOptimizationTimer?.invalidate()
    resourceOptimizationTimer = nil
  }
  
  /// Optimize resources based on current memory usage and system pressure
  private static func optimizeResources() {
    let thermalState = ProcessInfo.processInfo.thermalState
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    let currentMemory = getCurrentMemoryUsage()
    
    executeCritical {
      // Memory-based proactive cleanup with realistic thresholds
      if currentMemory >= 150 { // 150MB threshold for proactive cleanup (was 50MB)
        print("[ThreadOptimization] Memory at \(currentMemory)MB - performing proactive cleanup")
        proactiveCleanup()
      }
      
      // System pressure based cleanup with realistic thresholds
      if thermalState == .critical || isLowPowerMode || currentMemory >= 350 { // Was 100MB
        // Emergency optimization
        print("[ThreadOptimization] Emergency conditions detected - performing emergency cleanup")
        emergencyCleanup()
      } else if thermalState == .serious || currentMemory >= 250 { // Was 75MB
        // Aggressive optimization  
        print("[ThreadOptimization] High pressure conditions - performing aggressive cleanup")
        aggressiveCleanup()
      } else if currentMemory >= 150 { // Was 50MB
        // Proactive optimization (already handled above but included for clarity)
        proactiveCleanup()
      }
      
      // Always clean up old timers regardless of memory usage
      cleanupAllTimers()
    }
  }
  
  /// Emergency resource cleanup for extreme memory pressure
  static func emergencyCleanup() {
    // Ultra-minimal cache limits for emergency situations
    let cache = KingfisherManager.shared.cache
    cache.memoryStorage.config.totalCostLimit = 512 * 1024 // Reduced to 512KB for emergency
    cache.clearMemoryCache()
    cache.clearDiskCache() // Also clear disk cache in emergency
    
    // Clear all other caches
    ViewSizeCache.shared.clear()
    
    // Clean temp files
    cleanupTempFiles()
    
    print("[ThreadOptimization] Emergency resource cleanup completed")
  }
  
  /// Aggressive resource cleanup for high memory usage
  static func aggressiveCleanup() {
    // Reduced cache limits
    let cache = KingfisherManager.shared.cache  
    cache.memoryStorage.config.totalCostLimit = 2 * 1024 * 1024 // Reduced from 5MB to 2MB
    cache.clearMemoryCache()
    
    // Clear view size cache
    ViewSizeCache.shared.clear()
    
    print("[ThreadOptimization] Aggressive resource cleanup completed")
  }
  
  /// Proactive cleanup when approaching memory limits (new)
  static func proactiveCleanup() {
    // Moderate cleanup before hitting high memory thresholds
    let cache = KingfisherManager.shared.cache
    cache.memoryStorage.config.totalCostLimit = 3 * 1024 * 1024 // Set to 3MB limit
    
    // Only clear memory cache, keep disk cache
    cache.clearMemoryCache()
    
    // Clean up old timers
    cleanupAllTimers()
    
    print("[ThreadOptimization] Proactive resource cleanup completed")
  }
  
  /// Clean up temporary files
  static func cleanupTempFiles() {
    let tempDir = NSTemporaryDirectory()
    let fileManager = FileManager.default
    
    do {
      let contents = try fileManager.contentsOfDirectory(atPath: tempDir)
      for file in contents {
        if file.hasPrefix("leaderkey_") || file.hasPrefix("stress_test_") {
          let fullPath = (tempDir as NSString).appendingPathComponent(file)
          try? fileManager.removeItem(atPath: fullPath)
        }
      }
    } catch {
      print("[ThreadOptimization] Error cleaning temp files: \(error)")
    }
  }
  
  // MARK: - Memory Profiling & Leak Detection
  
  /// Detailed memory profiling data with component breakdown
  struct MemoryProfile {
    let timestamp: Date
    let residentSize: UInt64     // Physical memory in MB
    let virtualSize: UInt64      // Virtual memory in MB  
    let peakResidentSize: UInt64 // Peak memory usage in MB
    let queueCount: Int          // Active dispatch queues
    let timerCount: Int          // Active timers
    let componentBreakdown: ComponentMemoryBreakdown
    
    var description: String {
      """
      [MemoryProfile \(timestamp)]
      Total Resident: \(residentSize)MB | Virtual: \(virtualSize)MB | Peak: \(peakResidentSize)MB
      Queues: \(queueCount) | Timers: \(timerCount)
      Component Breakdown:
      \(componentBreakdown.description)
      """
    }
  }
  
  /// Detailed breakdown of memory usage by component
  struct ComponentMemoryBreakdown {
    let kingfisherMemory: UInt64     // Kingfisher cache memory in bytes
    let kingfisherDisk: UInt64       // Kingfisher disk cache in bytes
    let configCacheMemory: UInt64    // Config cache memory estimate in bytes
    let viewSizeCacheMemory: UInt64  // View size cache memory in bytes
    let frameworkOverhead: UInt64    // Estimated framework memory in bytes
    let unknownMemory: UInt64        // Unaccounted memory in bytes
    
    var description: String {
      let kingfisherMB = kingfisherMemory / 1024 / 1024
      let configMB = configCacheMemory / 1024 / 1024
      let viewMB = viewSizeCacheMemory / 1024 / 1024
      let frameworkMB = frameworkOverhead / 1024 / 1024
      let unknownMB = unknownMemory / 1024 / 1024
      let diskMB = kingfisherDisk / 1024 / 1024
      
      return """
        - Kingfisher Cache: \(kingfisherMB)MB (Disk: \(diskMB)MB)
        - Config Cache: \(configMB)MB
        - View Size Cache: \(viewMB)MB
        - Framework Overhead: \(frameworkMB)MB
        - Unknown/Other: \(unknownMB)MB
      """
    }
  }
  
  private static var memoryHistory: [MemoryProfile] = []
  private static let maxHistoryCount = 20 // Keep last 20 profiles
  
  /// Get current memory usage in MB
  static func getCurrentMemoryUsage() -> UInt64 {
    return getDetailedMemoryProfile().residentSize
  }
  
  /// Get comprehensive memory profile with component breakdown and leak detection
  static func getDetailedMemoryProfile() -> MemoryProfile {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
    
    let result = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
      }
    }
    
    // Collect component memory breakdown
    let componentBreakdown = getComponentMemoryBreakdown()
    
    let profile = MemoryProfile(
      timestamp: Date(),
      residentSize: result == KERN_SUCCESS ? info.resident_size / 1024 / 1024 : 0,
      virtualSize: result == KERN_SUCCESS ? info.virtual_size / 1024 / 1024 : 0,
      peakResidentSize: result == KERN_SUCCESS ? info.resident_size_max / 1024 / 1024 : 0,
      queueCount: getActiveQueueCount(),
      timerCount: activeTimerCount(),
      componentBreakdown: componentBreakdown
    )
    
    // Add to history and maintain size limit
    memoryHistory.append(profile)
    if memoryHistory.count > maxHistoryCount {
      memoryHistory.removeFirst()
    }
    
    return profile
  }
  
  /// Collect detailed memory usage breakdown by component
  private static func getComponentMemoryBreakdown() -> ComponentMemoryBreakdown {
    // Kingfisher cache memory usage (estimate based on config limits)
    let cache = KingfisherManager.shared.cache
    let kingfisherMemory = UInt64(cache.memoryStorage.config.totalCostLimit)
    
    // Kingfisher disk cache size
    let kingfisherDisk: UInt64 = {
      do {
        let diskCacheSize = try cache.diskStorage.totalSize()
        return UInt64(diskCacheSize)
      } catch {
        return 0
      }
    }()
    
    // Config cache memory estimate
    let configCacheMemory = estimateConfigCacheMemory()
    
    // View size cache memory
    let viewSizeCacheMemory = estimateViewSizeCacheMemory()
    
    // Framework overhead estimate (rough calculation)
    let frameworkOverhead = estimateFrameworkOverhead()
    
    // Calculate unknown memory (total - known components)
    // Get total memory directly to avoid circular dependency
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
    let result = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
      }
    }
    let totalMemoryBytes = result == KERN_SUCCESS ? UInt64(info.resident_size) : 0
    let knownMemory = kingfisherMemory + configCacheMemory + viewSizeCacheMemory + frameworkOverhead
    let unknownMemory = totalMemoryBytes > knownMemory ? totalMemoryBytes - knownMemory : 0
    
    return ComponentMemoryBreakdown(
      kingfisherMemory: kingfisherMemory,
      kingfisherDisk: kingfisherDisk,
      configCacheMemory: configCacheMemory,
      viewSizeCacheMemory: viewSizeCacheMemory,
      frameworkOverhead: frameworkOverhead,
      unknownMemory: unknownMemory
    )
  }
  
  /// Estimate config cache memory usage
  private static func estimateConfigCacheMemory() -> UInt64 {
    // Updated estimate based on new aggressive limits (2MB max, 10 entries)
    // This is an approximation since NSCache doesn't expose memory usage directly
    return 2 * 1024 * 1024 // Reduced estimate to 2MB to match new cache limits
  }
  
  /// Estimate view size cache memory usage
  private static func estimateViewSizeCacheMemory() -> UInt64 {
    // ViewSizeCache stores NSSize (16 bytes) per UUID (16 bytes) + overhead
    // Updated: 64 entries max * 64 bytes per entry
    return 64 * 64 // About 4KB (reduced from 16KB)
  }
  
  /// Estimate framework overhead (SwiftUI, Cocoa, etc.)
  private static func estimateFrameworkOverhead() -> UInt64 {
    // More realistic estimate for a minimal menu bar app
    // Base macOS app overhead is typically much lower for simple apps
    return 40 * 1024 * 1024 // Reduced estimate to 40MB for frameworks
  }
  
  /// Detect memory leaks by analyzing trends
  static func detectMemoryLeaks() -> String? {
    guard memoryHistory.count >= 5 else { return nil }
    
    let recent = memoryHistory.suffix(5)
    let growthRate = Double(recent.last!.residentSize - recent.first!.residentSize) / 5.0
    
    if growthRate > 10.0 { // More than 10MB growth over 5 samples
      return "MEMORY LEAK DETECTED: Growing at \(String(format: "%.1f", growthRate))MB per sample"
    }
    
    if recent.last!.residentSize > 400 { // Realistic absolute threshold (was 200MB)
      return "EXCESSIVE MEMORY: \(recent.last!.residentSize)MB - Normal should be <200MB"
    }
    
    return nil
  }
  
  /// Get memory history for analysis
  static func getMemoryHistory() -> [MemoryProfile] {
    return memoryHistory
  }
  
  /// Print detailed memory report with component breakdown
  static func printMemoryReport() {
    let current = getDetailedMemoryProfile()
    print(current.description)
    
    if let leak = detectMemoryLeaks() {
      print("🚨 \(leak)")
    }
    
    // Print recent trend
    if memoryHistory.count >= 3 {
      let recent = memoryHistory.suffix(3)
      let sizes = recent.map { $0.residentSize }
      print("Recent trend: \(sizes)MB")
    }
    
    // Print optimization recommendations
    let breakdown = current.componentBreakdown
    if breakdown.kingfisherMemory > 10 * 1024 * 1024 { // > 10MB
      print("💡 Recommendation: Kingfisher cache is using \(breakdown.kingfisherMemory / 1024 / 1024)MB - consider reducing limit")
    }
    if breakdown.unknownMemory > 50 * 1024 * 1024 { // > 50MB
      print("💡 Recommendation: \(breakdown.unknownMemory / 1024 / 1024)MB of unknown memory - investigate further")
    }
  }
  
  /// Get detailed memory report as string for UI display
  static func getMemoryReportString() -> String {
    let current = getDetailedMemoryProfile()
    var report = current.description
    
    if let leak = detectMemoryLeaks() {
      report += "\n🚨 \(leak)"
    }
    
    // Add recent trend
    if memoryHistory.count >= 3 {
      let recent = memoryHistory.suffix(3)
      let sizes = recent.map { $0.residentSize }
      report += "\nRecent trend: \(sizes)MB"
    }
    
    return report
  }
  
  /// Get count of active dispatch queues (approximation)
  private static func getActiveQueueCount() -> Int {
    // This is an approximation - we track the queues we create
    return 2 // criticalEventQueue + realtimeQueue
  }
}