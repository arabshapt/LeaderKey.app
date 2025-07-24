import AppKit
import ApplicationServices
import Defaults

/// Detects overlay windows (like Raycast/Alfred) vs normal app windows for separate config handling
/// Rebuilt from scratch with improved architecture and robust detection logic
class OverlayDetector: ObservableObject {
    static let shared = OverlayDetector()

    // MARK: - Permission Management
    private var permissionCache: Bool?
    private var permissionCacheTime: Date?
    private let permissionCacheInterval: TimeInterval = 30.0 // Cache for 30 seconds

    // MARK: - Detection Cache
    private var cachedDetectionResult: (bundleId: String?, isOverlay: Bool)?
    private var detectionCacheTime: Date?
    private let detectionCacheInterval: TimeInterval = 0.5 // Cache for 500ms to handle rapid activations

    // MARK: - Continuous Testing
    private var continuousTestingTimer: Timer?
    @Published var isContinuousTestingEnabled = false
    
    // MARK: - Real-time Detection Display
    @Published var currentDetection: String = ""
    @Published var lastUpdated: Date = Date()
    private var realtimeDetectionTimer: Timer?

    private init() {}

    // MARK: - Main Detection Method

    /// Early detection for overlay state before app activation - caches result to avoid timing issues
    /// Call this BEFORE any events that might cause overlays to disappear
    /// - Returns: Tuple with bundle ID and whether any overlay is active
    func detectAndCacheOverlayState() -> (bundleId: String?, isOverlay: Bool) {
        let result = performDetection()

        // Cache the result for immediate use
        cachedDetectionResult = result
        detectionCacheTime = Date()

        print("[OverlayDetector] 💾 Cached detection result: \(result.bundleId ?? "nil"), overlay: \(result.isOverlay)")
        return result
    }

    /// Detects frontmost app and checks all overlay apps for overlay windows
    /// Uses cached result if available and recent, otherwise performs fresh detection
    /// - Returns: Tuple with bundle ID and whether any overlay is active
    func detectFrontmostAppWithOverlay() -> (bundleId: String?, isOverlay: Bool) {
        // Check if we have a recent cached result
        if let cached = cachedDetectionResult,
           let cacheTime = detectionCacheTime,
           Date().timeIntervalSince(cacheTime) < detectionCacheInterval {
            print("[OverlayDetector] 📋 Using cached detection result: \(cached.bundleId ?? "nil"), overlay: \(cached.isOverlay)")
            return cached
        }

        // No cache or cache expired, perform fresh detection
        return performDetection()
    }

    /// Invalidates the cached detection result - call after activation is complete
    func invalidateDetectionCache() {
        cachedDetectionResult = nil
        detectionCacheTime = nil
        print("[OverlayDetector] 🗑️ Invalidated detection cache")
    }

    /// Internal method that performs the actual detection logic
    private func performDetection() -> (bundleId: String?, isOverlay: Bool) {
        guard Defaults[.overlayDetectionEnabled] else {
            let frontmostApp = NSWorkspace.shared.frontmostApplication
            return (frontmostApp?.bundleIdentifier, false)
        }

        // Check all configured overlay apps for overlay windows
        let overlayApps = Defaults[.overlayApps]
        let runningApps = NSWorkspace.shared.runningApplications

        for overlayAppBundleId in overlayApps {
            if let overlayApp = runningApps.first(where: { $0.bundleIdentifier == overlayAppBundleId }) {
                if detectOverlay(for: overlayApp) {
                    print("[OverlayDetector] 🎯 Overlay detected for \(overlayAppBundleId)")
                    return (overlayAppBundleId, true)
                }
            }
        }

        // No overlays detected, return frontmost app
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        return (frontmostApp?.bundleIdentifier, false)
    }

    // MARK: - App-Specific Detection

    private func detectOverlay(for app: NSRunningApplication) -> Bool {
        guard hasAccessibilityPermissions() else {
            print("[OverlayDetector] ❌ No accessibility permissions")
            return false
        }

        guard let bundleId = app.bundleIdentifier else {
            return false
        }

        // Use app-specific detection strategies
        switch bundleId {
        case "com.raycast.macos":
            return detectRaycastOverlay(for: app)
        case "com.runningwithcrayons.Alfred":
            return detectAlfredOverlay(for: app)
        default:
            return detectGenericOverlay(for: app)
        }
    }

    private func detectRaycastOverlay(for app: NSRunningApplication) -> Bool {
        print("[OverlayDetector] Starting Raycast overlay detection for PID: \(app.processIdentifier)")

        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        // Get all windows from the app
        var windowsRef: CFTypeRef?
        let windowsError = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)

        guard windowsError == .success else {
            print("[OverlayDetector] Failed to get windows for Raycast. Error: \(windowsError.rawValue)")
            return false
        }

        guard let windows = windowsRef as? [AXUIElement] else {
            print("[OverlayDetector] Windows result is not an array of AXUIElement")
            return false
        }

        print("[OverlayDetector] Found \(windows.count) windows for Raycast")

        for (index, window) in windows.enumerated() {
            print("[OverlayDetector] Analyzing window \(index + 1)/\(windows.count)")

            // Log basic window properties
            logWindowProperties(window, index: index)

            // Check if this window is the main Raycast search overlay
            if isRaycastSearchWindow(window) {
                print("[OverlayDetector] ✅ Found Raycast search overlay at index \(index)")
                return true
            }
        }

        print("[OverlayDetector] ❌ No Raycast overlay found after checking all \(windows.count) windows")
        return false
    }

    /// Log detailed window properties for debugging
    private func logWindowProperties(_ window: AXUIElement, index: Int) {
        print("[OverlayDetector] === Window \(index) Properties ===")

        // Window title
        var titleRef: CFTypeRef?
        let titleError = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
        if titleError == .success, let title = titleRef as? String {
            print("[OverlayDetector] Title: '\(title)'")
        } else {
            print("[OverlayDetector] Title: <unavailable> (error: \(titleError.rawValue))")
        }

        // Window position - try different approaches
        var positionRef: CFTypeRef?
        var posError = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        if posError == .success, let position = positionRef as? NSValue {
            let point = position.pointValue
            print("[OverlayDetector] Position: \(point)")
        } else {
            // Try alternative position attribute
            posError = AXUIElementCopyAttributeValue(window, "AXFrame" as CFString, &positionRef)
            if posError == .success, let frameValue = positionRef as? NSValue {
                let frame = frameValue.rectValue
                print("[OverlayDetector] Position (from frame): \(frame.origin)")
            } else {
                print("[OverlayDetector] Position: <unavailable> (kAXPosition error: \(posError.rawValue))")
            }
        }

        // Window size - try different approaches
        var sizeRef: CFTypeRef?
        var sizeError = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        if sizeError == .success, let size = sizeRef as? NSValue {
            let windowSize = size.sizeValue
            print("[OverlayDetector] Size: \(windowSize)")
        } else {
            // Try alternative size attribute
            sizeError = AXUIElementCopyAttributeValue(window, "AXFrame" as CFString, &sizeRef)
            if sizeError == .success, let frameValue = sizeRef as? NSValue {
                let frame = frameValue.rectValue
                print("[OverlayDetector] Size (from frame): \(frame.size)")
            } else {
                print("[OverlayDetector] Size: <unavailable> (kAXSize error: \(sizeError.rawValue))")
            }
        }

        // Window subrole
        var subroleRef: CFTypeRef?
        let subroleError = AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef)
        if subroleError == .success, let subrole = subroleRef as? String {
            print("[OverlayDetector] Subrole: '\(subrole)'")
        } else {
            print("[OverlayDetector] Subrole: <unavailable> (error: \(subroleError.rawValue))")
        }

        // Window role
        var roleRef: CFTypeRef?
        let roleError = AXUIElementCopyAttributeValue(window, kAXRoleAttribute as CFString, &roleRef)
        if roleError == .success, let role = roleRef as? String {
            print("[OverlayDetector] Role: '\(role)'")
        } else {
            print("[OverlayDetector] Role: <unavailable> (error: \(roleError.rawValue))")
        }

        // Minimized status
        var minimizedRef: CFTypeRef?
        let minimizedError = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedRef)
        if minimizedError == .success, let minimized = minimizedRef as? Bool {
            print("[OverlayDetector] Minimized: \(minimized)")
        } else {
            print("[OverlayDetector] Minimized: <unavailable> (error: \(minimizedError.rawValue))")
        }

        print("[OverlayDetector] === End Window \(index) Properties ===")
    }

    private func detectAlfredOverlay(for app: NSRunningApplication) -> Bool {
        print("[OverlayDetector] Starting Alfred overlay detection for PID: \(app.processIdentifier)")

        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        // Get all windows from the app
        var windowsRef: CFTypeRef?
        let windowsError = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)

        guard windowsError == .success else {
            print("[OverlayDetector] Failed to get windows for Alfred. Error: \(windowsError.rawValue)")
            return false
        }

        guard let windows = windowsRef as? [AXUIElement] else {
            print("[OverlayDetector] Windows result is not an array of AXUIElement")
            return false
        }

        print("[OverlayDetector] Found \(windows.count) windows for Alfred")

        for (index, window) in windows.enumerated() {
            print("[OverlayDetector] Analyzing Alfred window \(index + 1)/\(windows.count)")

            // Log basic window properties
            logWindowProperties(window, index: index)

            // Check if this window is the main Alfred search overlay
            if isAlfredSearchWindow(window) {
                print("[OverlayDetector] ✅ Found Alfred search overlay at index \(index)")
                return true
            }
        }

        print("[OverlayDetector] ❌ No Alfred overlay found after checking all \(windows.count) windows")
        return false
    }

    private func detectGenericOverlay(for app: NSRunningApplication) -> Bool {
        print("[OverlayDetector] Checking generic overlay for \(app.bundleIdentifier ?? "unknown")")

        let windows = getAppWindows(for: app)
        guard !windows.isEmpty else { return false }

        for window in windows {
            if isGenericOverlayWindow(window) {
                print("[OverlayDetector] ✅ Generic overlay found")
                return true
            }
        }

        return false
    }

    // MARK: - Window Analysis

    private func getAppWindows(for app: NSRunningApplication) -> [AXUIElement] {
        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)

        guard result == .success, let windows = windowsRef as? [AXUIElement] else {
            print("[OverlayDetector] Failed to get windows for \(app.bundleIdentifier ?? "unknown")")
            return []
        }

        print("[OverlayDetector] Found \(windows.count) windows")
        return windows
    }

    /// Check if a window is Raycast's main search overlay
    private func isRaycastSearchWindow(_ window: AXUIElement) -> Bool {
        print("[OverlayDetector] Evaluating if window is Raycast search overlay...")

        // Get window properties
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        var titleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        var minimizedRef: CFTypeRef?
        var roleRef: CFTypeRef?

        let posError = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        let sizeError = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        let titleError = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
        let subroleError = AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef)
        let minimizedError = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedRef)
        let roleError = AXUIElementCopyAttributeValue(window, kAXRoleAttribute as CFString, &roleRef)

        // Check if window is minimized (skip if it is)
        if minimizedError == .success, let minimized = minimizedRef as? Bool, minimized {
            print("[OverlayDetector] Window is minimized, skipping")
            return false
        }

        // Check role - should be a window
        var isWindow = false
        if roleError == .success, let role = roleRef as? String {
            isWindow = role == kAXWindowRole
            print("[OverlayDetector] Role analysis: '\(role)' → is window: \(isWindow)")
            if !isWindow {
                print("[OverlayDetector] Not a window, skipping")
                return false
            }
        }

        // Check title-based indicators - more flexible patterns
        var titleIndicatesOverlay = false
        if titleError == .success, let title = titleRef as? String {
            // Raycast overlay patterns: empty title, "Raycast", or specific search patterns
            let titleLower = title.lowercased()
            titleIndicatesOverlay = title.isEmpty ||
                                  title == "Raycast" ||
                                  titleLower.contains("raycast") ||
                                  titleLower.contains("search") ||
                                  title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            print("[OverlayDetector] Title analysis: '\(title)' → overlay indicator: \(titleIndicatesOverlay)")
        } else {
            // No title available might indicate overlay
            titleIndicatesOverlay = true
            print("[OverlayDetector] No title available → assuming overlay indicator: \(titleIndicatesOverlay)")
        }

        // Check subrole-based indicators
        var subroleIndicatesOverlay = false
        if subroleError == .success, let subrole = subroleRef as? String {
            // Look for floating window, dialog, or other overlay subroles
            subroleIndicatesOverlay = subrole == "AXFloatingWindow" ||
                                    subrole == "AXDialog" ||
                                    subrole == "AXSystemFloatingWindow" ||
                                    subrole == "AXApplicationDialog" ||
                                    subrole.contains("Float") ||
                                    subrole.contains("Dialog")
            print("[OverlayDetector] Subrole analysis: '\(subrole)' → overlay indicator: \(subroleIndicatesOverlay)")
        } else {
            print("[OverlayDetector] No subrole available")
        }

        // Check size and position with more flexible criteria
        var sizePositionIndicatesOverlay = false
        var hasSizePositionData = false

        // Try to get position/size data from multiple sources
        var windowPoint: NSPoint = NSPoint.zero
        var windowSize: NSSize = NSSize.zero

        // Method 1: Standard position/size attributes
        if posError == .success && sizeError == .success,
           let position = positionRef as? NSValue,
           let size = sizeRef as? NSValue {
            windowPoint = position.pointValue
            windowSize = size.sizeValue
            hasSizePositionData = true
        } else {
            // Method 2: Try frame attribute
            var frameRef: CFTypeRef?
            let frameError = AXUIElementCopyAttributeValue(window, "AXFrame" as CFString, &frameRef)
            if frameError == .success, let frameValue = frameRef as? NSValue {
                let frame = frameValue.rectValue
                windowPoint = frame.origin
                windowSize = frame.size
                hasSizePositionData = true
                print("[OverlayDetector] Using AXFrame for size/position data")
            }
        }

        if hasSizePositionData {
            // Broader size criteria - Raycast can be quite variable
            let isReasonableSize = windowSize.width >= 150 && windowSize.width <= 1200 &&
                                 windowSize.height >= 25 && windowSize.height <= 800

            // Get screen containing window
            let screens = NSScreen.screens
            let containingScreen = screens.first { $0.frame.contains(windowPoint) } ?? NSScreen.main

            if let screen = containingScreen {
                // More flexible positioning - Raycast can appear in different locations
                let screenHeight = screen.frame.height
                let screenWidth = screen.frame.width

                // Check if in reasonable position (not at very bottom or very edges)
                let isNotAtBottom = windowPoint.y > screenHeight * 0.1 // Not in bottom 10%
                let isNotAtEdges = windowPoint.x > -screenWidth * 0.1 &&
                                 windowPoint.x < screenWidth * 1.1 // Allow some off-screen tolerance

                // Check if window height suggests it's an overlay (not full screen)
                let isOverlayHeight = windowSize.height < screenHeight * 0.8 // Less than 80% of screen height

                sizePositionIndicatesOverlay = isReasonableSize && isNotAtBottom && isNotAtEdges && isOverlayHeight

                print("[OverlayDetector] Size/Position analysis:")
                print("[OverlayDetector]   Size: \(windowSize) → reasonable: \(isReasonableSize)")
                print("[OverlayDetector]   Position: \(windowPoint)")
                print("[OverlayDetector]   Not at bottom: \(isNotAtBottom)")
                print("[OverlayDetector]   Not at edges: \(isNotAtEdges)")
                print("[OverlayDetector]   Overlay height: \(isOverlayHeight)")
                print("[OverlayDetector]   Overall size/position indicator: \(sizePositionIndicatesOverlay)")
            }
        } else {
            print("[OverlayDetector] Could not get window size/position for analysis")
            // When we can't get size/position, be more lenient with other indicators
            print("[OverlayDetector] Will rely more heavily on title and subrole indicators")
        }

        // Enhanced overlay detection logic that works well even without size/position data:
        // 1. Strong indicators: title + size/position (when available)
        // 2. Moderate indicators: subrole + size/position (when available)
        // 3. Weak but valid: title + subrole (works without size/position)
        // 4. Fallback: reasonable size/position for Raycast (when other info unavailable)
        // 5. No size/position boost: Strong title/subrole indicators when no size/position available
        let strongIndicator = titleIndicatesOverlay && sizePositionIndicatesOverlay
        let moderateIndicator = subroleIndicatesOverlay && sizePositionIndicatesOverlay
        let weakIndicator = titleIndicatesOverlay && subroleIndicatesOverlay
        let fallbackIndicator = sizePositionIndicatesOverlay && (titleError != .success || subroleError != .success)

        // Special logic when size/position data is unavailable
        var noSizePositionBoost = false
        if !hasSizePositionData {
            // Get the actual subrole string for comparison
            var actualSubrole = ""
            if subroleError == .success, let subroleString = subroleRef as? String {
                actualSubrole = subroleString
            }

            // Be more lenient when we can't get size/position - strong title/subrole combos are very reliable
            noSizePositionBoost = (titleIndicatesOverlay && subroleIndicatesOverlay) ||
                                 (subroleIndicatesOverlay && (actualSubrole == "AXSystemDialog" || actualSubrole == "AXFloatingWindow"))
            print("[OverlayDetector] No size/position data available, using enhanced title/subrole logic: \(noSizePositionBoost)")
        }

        let isOverlay = strongIndicator || moderateIndicator || weakIndicator || fallbackIndicator || noSizePositionBoost

        print("[OverlayDetector] Final overlay determination: \(isOverlay)")
        print("[OverlayDetector]   Title indicator: \(titleIndicatesOverlay)")
        print("[OverlayDetector]   Subrole indicator: \(subroleIndicatesOverlay)")
        print("[OverlayDetector]   Size/Position indicator: \(sizePositionIndicatesOverlay)")
        print("[OverlayDetector]   Has size/position data: \(hasSizePositionData)")
        print("[OverlayDetector]   Strong: \(strongIndicator), Moderate: \(moderateIndicator), Weak: \(weakIndicator), Fallback: \(fallbackIndicator), NoSizeBoost: \(noSizePositionBoost)")

        return isOverlay
    }

    /// Check if a window is Alfred's main search overlay
    private func isAlfredSearchWindow(_ window: AXUIElement) -> Bool {
        print("[OverlayDetector] Evaluating if window is Alfred search overlay...")

        // Get window properties
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        var titleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        var minimizedRef: CFTypeRef?
        var roleRef: CFTypeRef?

        let posError = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        let sizeError = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        let titleError = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
        let subroleError = AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef)
        let minimizedError = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedRef)
        let roleError = AXUIElementCopyAttributeValue(window, kAXRoleAttribute as CFString, &roleRef)

        // Check if window is minimized (skip if it is)
        if minimizedError == .success, let minimized = minimizedRef as? Bool, minimized {
            print("[OverlayDetector] Alfred window is minimized, skipping")
            return false
        }

        // Check role - should be a window
        var isWindow = false
        if roleError == .success, let role = roleRef as? String {
            isWindow = role == kAXWindowRole
            print("[OverlayDetector] Alfred role analysis: '\(role)' → is window: \(isWindow)")
            if !isWindow {
                print("[OverlayDetector] Not a window, skipping")
                return false
            }
        }

        // Check title-based indicators for Alfred
        var titleIndicatesOverlay = false
        if titleError == .success, let title = titleRef as? String {
            // Alfred overlay patterns: empty title, "Alfred", or specific search patterns
            let titleLower = title.lowercased()
            titleIndicatesOverlay = title.isEmpty ||
                                  title == "Alfred" ||
                                  titleLower.contains("alfred") ||
                                  titleLower.contains("search") ||
                                  title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            print("[OverlayDetector] Alfred title analysis: '\(title)' → overlay indicator: \(titleIndicatesOverlay)")
        } else {
            // No title available might indicate overlay
            titleIndicatesOverlay = true
            print("[OverlayDetector] No title available → assuming overlay indicator: \(titleIndicatesOverlay)")
        }

        // Check subrole-based indicators
        var subroleIndicatesOverlay = false
        if subroleError == .success, let subrole = subroleRef as? String {
            // Look for floating window, dialog, or other overlay subroles
            subroleIndicatesOverlay = subrole == "AXFloatingWindow" ||
                                    subrole == "AXDialog" ||
                                    subrole == "AXSystemFloatingWindow" ||
                                    subrole == "AXApplicationDialog" ||
                                    subrole == "AXSystemDialog" ||
                                    subrole.contains("Float") ||
                                    subrole.contains("Dialog")
            print("[OverlayDetector] Alfred subrole analysis: '\(subrole)' → overlay indicator: \(subroleIndicatesOverlay)")
        } else {
            print("[OverlayDetector] No subrole available")
        }

        // Check size and position with flexible criteria
        var sizePositionIndicatesOverlay = false
        var hasSizePositionData = false

        // Try to get position/size data from multiple sources
        var windowPoint: NSPoint = NSPoint.zero
        var windowSize: NSSize = NSSize.zero

        // Method 1: Standard position/size attributes
        if posError == .success && sizeError == .success,
           let position = positionRef as? NSValue,
           let size = sizeRef as? NSValue {
            windowPoint = position.pointValue
            windowSize = size.sizeValue
            hasSizePositionData = true
        } else {
            // Method 2: Try frame attribute
            var frameRef: CFTypeRef?
            let frameError = AXUIElementCopyAttributeValue(window, "AXFrame" as CFString, &frameRef)
            if frameError == .success, let frameValue = frameRef as? NSValue {
                let frame = frameValue.rectValue
                windowPoint = frame.origin
                windowSize = frame.size
                hasSizePositionData = true
                print("[OverlayDetector] Using AXFrame for Alfred size/position data")
            }
        }

        if hasSizePositionData {
            // Alfred overlay characteristics - more flexible sizing
            let isReasonableSize = windowSize.width >= 150 && windowSize.width <= 1000 &&
                                 windowSize.height >= 25 && windowSize.height <= 700

            // Get screen containing window
            let screens = NSScreen.screens
            let containingScreen = screens.first { $0.frame.contains(windowPoint) } ?? NSScreen.main

            if let screen = containingScreen {
                // More flexible positioning for Alfred
                let screenHeight = screen.frame.height
                let screenWidth = screen.frame.width

                // Check if in reasonable position (not at very bottom or very edges)
                let isNotAtBottom = windowPoint.y > screenHeight * 0.1 // Not in bottom 10%
                let isNotAtEdges = windowPoint.x > -screenWidth * 0.1 &&
                                 windowPoint.x < screenWidth * 1.1 // Allow some off-screen tolerance

                // Check if window height suggests it's an overlay (not full screen)
                let isOverlayHeight = windowSize.height < screenHeight * 0.8 // Less than 80% of screen height

                sizePositionIndicatesOverlay = isReasonableSize && isNotAtBottom && isNotAtEdges && isOverlayHeight

                print("[OverlayDetector] Alfred Size/Position analysis:")
                print("[OverlayDetector]   Size: \(windowSize) → reasonable: \(isReasonableSize)")
                print("[OverlayDetector]   Position: \(windowPoint)")
                print("[OverlayDetector]   Not at bottom: \(isNotAtBottom)")
                print("[OverlayDetector]   Not at edges: \(isNotAtEdges)")
                print("[OverlayDetector]   Overlay height: \(isOverlayHeight)")
                print("[OverlayDetector]   Overall size/position indicator: \(sizePositionIndicatesOverlay)")
            }
        } else {
            print("[OverlayDetector] Could not get Alfred window size/position for analysis")
            print("[OverlayDetector] Will rely more heavily on title and subrole indicators")
        }

        // Enhanced Alfred overlay detection logic (same as Raycast):
        // 1. Strong indicators: title + size/position (when available)
        // 2. Moderate indicators: subrole + size/position (when available)
        // 3. Weak but valid: title + subrole (works without size/position)
        // 4. Fallback: reasonable size/position when other info unavailable
        // 5. No size/position boost: Strong title/subrole indicators when no size/position available
        let strongIndicator = titleIndicatesOverlay && sizePositionIndicatesOverlay
        let moderateIndicator = subroleIndicatesOverlay && sizePositionIndicatesOverlay
        let weakIndicator = titleIndicatesOverlay && subroleIndicatesOverlay
        let fallbackIndicator = sizePositionIndicatesOverlay && (titleError != .success || subroleError != .success)

        // Special logic when size/position data is unavailable
        var noSizePositionBoost = false
        if !hasSizePositionData {
            // Get the actual subrole string for comparison
            var actualSubrole = ""
            if subroleError == .success, let subroleString = subroleRef as? String {
                actualSubrole = subroleString
            }

            // Be more lenient when we can't get size/position - strong title/subrole combos are very reliable
            noSizePositionBoost = (titleIndicatesOverlay && subroleIndicatesOverlay) ||
                                 (subroleIndicatesOverlay && (actualSubrole == "AXSystemDialog" || actualSubrole == "AXFloatingWindow"))
            print("[OverlayDetector] No size/position data available, using enhanced title/subrole logic: \(noSizePositionBoost)")
        }

        let isOverlay = strongIndicator || moderateIndicator || weakIndicator || fallbackIndicator || noSizePositionBoost

        print("[OverlayDetector] Alfred final overlay determination: \(isOverlay)")
        print("[OverlayDetector]   Title indicator: \(titleIndicatesOverlay)")
        print("[OverlayDetector]   Subrole indicator: \(subroleIndicatesOverlay)")
        print("[OverlayDetector]   Size/Position indicator: \(sizePositionIndicatesOverlay)")
        print("[OverlayDetector]   Has size/position data: \(hasSizePositionData)")
        print("[OverlayDetector]   Strong: \(strongIndicator), Moderate: \(moderateIndicator), Weak: \(weakIndicator), Fallback: \(fallbackIndicator), NoSizeBoost: \(noSizePositionBoost)")

        return isOverlay
    }

    private func isGenericOverlayWindow(_ window: AXUIElement) -> Bool {
        let props = getWindowProperties(window)

        // Skip minimized windows
        if props.isMinimized {
            return false
        }

        // Must be a window
        if props.role != kAXWindowRole {
            return false
        }

        // Exclude common app windows that shouldn't be considered overlays
        let excludedTitles = ["Settings", "Preferences", "Advanced", "General", "Leader Key"]
        let isExcludedTitle = excludedTitles.contains { excluded in
            props.title.lowercased().contains(excluded.lowercased())
        }

        if isExcludedTitle {
            return false
        }

        // Conservative generic detection - only strong indicators
        let isFloatingSubrole = props.subrole == "AXFloatingWindow" ||
                               props.subrole == "AXSystemFloatingWindow"

        // Check window level for overlay characteristics
        var isOverlayLevel = false
        var levelRef: CFTypeRef?
        let levelError = AXUIElementCopyAttributeValue(window, "AXWindowLevel" as CFString, &levelRef)
        if levelError == .success, let level = levelRef as? Int {
            isOverlayLevel = level > 10 // Conservative threshold
        }

        let isOverlay = isFloatingSubrole || isOverlayLevel

        print("[OverlayDetector] Generic overlay: title='\(props.title)', subrole='\(props.subrole)' → \(isOverlay)")
        return isOverlay
    }

    // MARK: - Window Properties Helper

    private struct WindowProperties {
        let title: String
        let subrole: String
        let role: String
        let isMinimized: Bool
        let size: NSSize?
        let position: NSPoint?
    }

    private func getWindowProperties(_ window: AXUIElement) -> WindowProperties {
        var titleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        var roleRef: CFTypeRef?
        var minimizedRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        var positionRef: CFTypeRef?

        AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
        AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef)
        AXUIElementCopyAttributeValue(window, kAXRoleAttribute as CFString, &roleRef)
        AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedRef)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)

        let title = titleRef as? String ?? ""
        let subrole = subroleRef as? String ?? ""
        let role = roleRef as? String ?? ""
        let isMinimized = minimizedRef as? Bool ?? false
        let size = (sizeRef as? NSValue)?.sizeValue
        let position = (positionRef as? NSValue)?.pointValue

        return WindowProperties(
            title: title,
            subrole: subrole,
            role: role,
            isMinimized: isMinimized,
            size: size,
            position: position
        )
    }

    // MARK: - Permission Management

    func hasAccessibilityPermissions() -> Bool {
        let now = Date()

        // Use cached result if recent
        if let cache = permissionCache,
           let cacheTime = permissionCacheTime,
           now.timeIntervalSince(cacheTime) < permissionCacheInterval {
            return cache
        }

        // Check permissions without prompting
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false]
        let hasPermissions = AXIsProcessTrustedWithOptions(options as CFDictionary)

        // Update cache
        permissionCache = hasPermissions
        permissionCacheTime = now

        return hasPermissions
    }

    func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        let granted = AXIsProcessTrustedWithOptions(options as CFDictionary)

        // Update cache
        permissionCache = granted
        permissionCacheTime = Date()

        return granted
    }

    func openAccessibilitySettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Testing Infrastructure

    func testDetection() -> String {
        guard Defaults[.overlayDetectionEnabled] else {
            return "Overlay detection is disabled"
        }

        guard hasAccessibilityPermissions() else {
            return "Accessibility permissions required"
        }

        let (bundleId, isOverlay) = detectFrontmostAppWithOverlay()
        let configKey = isOverlay && bundleId != nil ? "\(bundleId!).overlay" : bundleId ?? "none"

        return "App: \(bundleId ?? "none")\nOverlay: \(isOverlay)\nConfig: \(configKey)"
    }

    func startContinuousTesting() {
        guard !isContinuousTestingEnabled else { return }

        print("[OverlayDetector] 🚀 Starting continuous testing")
        isContinuousTestingEnabled = true

        continuousTestingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.performContinuousTest()
        }
    }

    func stopContinuousTesting() {
        guard isContinuousTestingEnabled else { return }

        print("[OverlayDetector] 🛑 Stopping continuous testing")
        isContinuousTestingEnabled = false
        continuousTestingTimer?.invalidate()
        continuousTestingTimer = nil
    }

    func toggleContinuousTesting() {
        if isContinuousTestingEnabled {
            stopContinuousTesting()
        } else {
            startContinuousTesting()
        }
    }

    private func performContinuousTest() {
        guard Defaults[.overlayDetectionEnabled] else {
            print("[OverlayDetector] ⏸️ Detection disabled")
            return
        }

        guard hasAccessibilityPermissions() else {
            print("[OverlayDetector] ❌ No permissions")
            return
        }

        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        let frontmostBundleId = frontmostApp?.bundleIdentifier ?? "unknown"

        print("[OverlayDetector] 🔍 === TEST [\(timestamp)] (Frontmost: \(frontmostBundleId)) ===")

        // Check all overlay apps
        let overlayApps = Defaults[.overlayApps]
        let runningApps = NSWorkspace.shared.runningApplications
        var foundOverlay = false

        for overlayAppBundleId in overlayApps {
            if let overlayApp = runningApps.first(where: { $0.bundleIdentifier == overlayAppBundleId }) {
                let isOverlay = detectOverlay(for: overlayApp)
                let configKey = isOverlay ? "\(overlayAppBundleId).overlay" : overlayAppBundleId

                if isOverlay {
                    print("[OverlayDetector] ✅ OVERLAY: \(overlayAppBundleId) → \(configKey)")
                    foundOverlay = true
                } else {
                    print("[OverlayDetector] ⚪ Normal: \(overlayAppBundleId)")
                }
            }
        }

        if !foundOverlay {
            print("[OverlayDetector] ⚪ No overlays detected")
        }

        print("[OverlayDetector] 🔍 === END TEST ===")
    }
    
    // MARK: - Real-time Detection Display
    
    func startRealtimeDetection() {
        guard realtimeDetectionTimer == nil else { return }
        
        // Update immediately
        updateRealtimeDetection()
        
        // Start timer for periodic updates
        realtimeDetectionTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            self?.updateRealtimeDetection()
        }
    }
    
    func stopRealtimeDetection() {
        realtimeDetectionTimer?.invalidate()
        realtimeDetectionTimer = nil
        currentDetection = ""
    }
    
    private func updateRealtimeDetection() {
        guard Defaults[.overlayDetectionEnabled] else {
            currentDetection = "Overlay detection is disabled"
            lastUpdated = Date()
            return
        }
        
        guard hasAccessibilityPermissions() else {
            currentDetection = "Accessibility permissions required"
            lastUpdated = Date()
            return
        }
        
        currentDetection = testDetection()
        lastUpdated = Date()
    }
}
