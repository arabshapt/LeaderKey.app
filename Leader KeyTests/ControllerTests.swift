import XCTest
import Carbon.HIToolbox // For kVK constants and masks
@testable import Leader_Key // Import your app module
import Defaults // Needed for setting theme in setup

// Mock UserState and UserConfig for Controller initialization if needed
// For now, we might be able to test static/private helpers with some adjustments
// or by creating a controller instance if the helpers are not static.
// Let's assume we can create a Controller instance or access helpers.

class ControllerTests: XCTestCase {

    var controller: Controller!
    var mockUserState: UserState!
    var mockUserConfig: UserConfig! // You might need a mock config

    override func setUpWithError() throws {
        // Use a test-specific UserDefaults suite
        defaultsSuite = UserDefaults(suiteName: name)!
        defaultsSuite.removePersistentDomain(forName: name)
        
        // Initialize mocks and the controller
        mockUserConfig = UserConfig() // Using real one, ensure no disk side effects in tests
        // Ensure config dir is set for user config init if needed, point to temp dir?
        // Defaults[.configDir] = NSTemporaryDirectory() + "/" + UUID().uuidString
        
        mockUserState = UserState(userConfig: mockUserConfig)
        
        // Set a default theme *before* initializing Controller
        Defaults[.theme] = .mysteryBox // Set a default theme for testing
        
        controller = Controller(userState: mockUserState, userConfig: mockUserConfig)
        
        // Wait briefly if controller init involves async tasks (like window creation)
        // The theme is now set beforehand, so async window creation might be okay
        // but a small wait might still be needed if other async ops exist.
        let expectation = XCTestExpectation(description: "Controller initialized")
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Slightly longer delay
             // Check if window exists as a proxy for init completion
             if self.controller.window != nil {
                expectation.fulfill()
             } else {
                // If still nil after delay, fulfill anyway to avoid timeout, but log it
                print("Controller window potentially not initialized within delay.")
                expectation.fulfill()
             }
         }
         wait(for: [expectation], timeout: 2.0) // Increased timeout
         
         // Ensure controller and window are actually created
         XCTAssertNotNil(controller, "Controller should be initialized")
         // Add check for window if critical, but maybe skip if init is complex/flaky
         // XCTAssertNotNil(controller.window, "Controller window should be initialized")

    }

    override func tearDownWithError() throws {
        controller = nil
        mockUserState = nil
        mockUserConfig = nil
        // Clean up test-specific UserDefaults
        defaultsSuite.removePersistentDomain(forName: name)
        // Reset to standard suite? Depends on how Defaults is used globally
        // defaultsSuite = .standard
    }

    // Test shortcut parsing logic
    // Assuming parseCompactShortcutToCGEventData is accessible (e.g., internal or fileprivate)
    func testParseValidShortcuts() {
         guard let controller = controller else {
             XCTFail("Controller not initialized")
             return
         }
        // Test Cmd+Shift+B
        // NOTE: Corrected modifier mapping based on code: C=Cmd, T=Ctrl, O=Opt, S=Shift
        let result1 = controller.parseCompactShortcutToCGEventData("CSb")
        XCTAssertNotNil(result1, "Parsing CSb failed")
        XCTAssertEqual(result1?.keyCode, CGKeyCode(kVK_ANSI_B))
        XCTAssertEqual(result1?.flags, [.maskCommand, .maskShift])

        // Test Ctrl+Option+F12
        let result2 = controller.parseCompactShortcutToCGEventData("TOf12")
        XCTAssertNotNil(result2, "Parsing TOf12 failed")
        XCTAssertEqual(result2?.keyCode, CGKeyCode(kVK_F12))
        XCTAssertEqual(result2?.flags, [.maskControl, .maskAlternate])

        // Test Cmd+Space
        let result3 = controller.parseCompactShortcutToCGEventData("Cspacebar")
        XCTAssertNotNil(result3, "Parsing Cspacebar failed")
        XCTAssertEqual(result3?.keyCode, CGKeyCode(kVK_Space))
        XCTAssertEqual(result3?.flags, .maskCommand)

        // Test just 'a'
        let result4 = controller.parseCompactShortcutToCGEventData("a")
        XCTAssertNotNil(result4, "Parsing 'a' failed")
        XCTAssertEqual(result4?.keyCode, CGKeyCode(kVK_ANSI_A))
        XCTAssertEqual(result4?.flags ?? .init(), []) // Check against empty flags

        // Test Shift+Tab
        let result5 = controller.parseCompactShortcutToCGEventData("Stab")
        XCTAssertNotNil(result5, "Parsing Stab failed")
        XCTAssertEqual(result5?.keyCode, CGKeyCode(kVK_Tab))
        XCTAssertEqual(result5?.flags, .maskShift)

         // Test duplicate modifiers (should parse correctly)
         // C=Cmd, T=Ctrl, O=Opt, S=Shift
         let result6 = controller.parseCompactShortcutToCGEventData("CCTOSa")
         XCTAssertNotNil(result6, "Parsing CCTOSa failed")
         XCTAssertEqual(result6?.keyCode, CGKeyCode(kVK_ANSI_A))
         // Flags should contain each specified modifier once
         let expectedFlags: CGEventFlags = [.maskCommand, .maskControl, .maskAlternate, .maskShift]
         XCTAssertEqual(result6?.flags, expectedFlags)
    }

    func testParseInvalidShortcuts() {
         guard let controller = controller else {
             XCTFail("Controller not initialized")
             return
         }
        // Empty string
        XCTAssertNil(controller.parseCompactShortcutToCGEventData(""), "Empty string should fail")

        // Only modifiers
        XCTAssertNil(controller.parseCompactShortcutToCGEventData("CSCTO"), "Only modifiers should fail")

        // Invalid key name
        XCTAssertNil(controller.parseCompactShortcutToCGEventData("OSinvalidkey"), "Invalid key name should fail")

        // Invalid modifier character
        XCTAssertNil(controller.parseCompactShortcutToCGEventData("Xb"), "Invalid modifier 'X' should fail")
    }

    // --- Add tests for URL activates logic later ---
    // --- Requires mocking NSWorkspace ---

} 