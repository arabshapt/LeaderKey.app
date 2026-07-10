import Carbon.HIToolbox  // For kVK constants and masks
import Defaults
import XCTest

@testable import Leader_Key

class ControllerTests: XCTestCase {

  var controller: Controller!
  var mockUserState: UserState!
  var mockUserConfig: UserConfig!
  var mockAppDelegate: AppDelegate!  // strong ref: Controller only holds it weakly
  var tempConfigDir: String!
  var originalSuite: UserDefaults!

  override func setUpWithError() throws {
    // Use a test-specific UserDefaults suite
    originalSuite = defaultsSuite
    defaultsSuite = UserDefaults(suiteName: UUID().uuidString)!

    // Point the config dir at a throwaway temp dir so UserConfig never touches real configs
    tempConfigDir = NSTemporaryDirectory().appending("/LeaderKeyControllerTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(atPath: tempConfigDir, withIntermediateDirectories: true)
    Defaults[.configDir] = tempConfigDir

    mockUserConfig = UserConfig()
    mockUserState = UserState(userConfig: mockUserConfig)

    // Set a default theme *before* initializing Controller
    Defaults[.theme] = .mysteryBox

    mockAppDelegate = AppDelegate()
    controller = Controller(
      userState: mockUserState, userConfig: mockUserConfig, appDelegate: mockAppDelegate)

    XCTAssertNotNil(controller, "Controller should be initialized")
  }

  override func tearDownWithError() throws {
    controller = nil
    mockUserState = nil
    mockUserConfig = nil
    mockAppDelegate = nil
    try? FileManager.default.removeItem(atPath: tempConfigDir)
    defaultsSuite = originalSuite
  }

  // Test shortcut parsing logic
  func testParseValidShortcuts() {
    // Test Cmd+Shift+B
    // NOTE: Modifier mapping: C=Cmd, T=Ctrl, O=Opt, S=Shift
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
    XCTAssertEqual(result4?.flags ?? .init(), [])

    // Test Shift+Tab
    let result5 = controller.parseCompactShortcutToCGEventData("Stab")
    XCTAssertNotNil(result5, "Parsing Stab failed")
    XCTAssertEqual(result5?.keyCode, CGKeyCode(kVK_Tab))
    XCTAssertEqual(result5?.flags, .maskShift)

    // Test duplicate modifiers (should parse correctly)
    let result6 = controller.parseCompactShortcutToCGEventData("CCTOSa")
    XCTAssertNotNil(result6, "Parsing CCTOSa failed")
    XCTAssertEqual(result6?.keyCode, CGKeyCode(kVK_ANSI_A))
    let expectedFlags: CGEventFlags = [.maskCommand, .maskControl, .maskAlternate, .maskShift]
    XCTAssertEqual(result6?.flags, expectedFlags)
  }

  func testParseInvalidShortcuts() {
    // Empty string
    XCTAssertNil(controller.parseCompactShortcutToCGEventData(""), "Empty string should fail")

    // Only modifiers
    XCTAssertNil(
      controller.parseCompactShortcutToCGEventData("CSCTO"), "Only modifiers should fail")

    // Invalid key name
    XCTAssertNil(
      controller.parseCompactShortcutToCGEventData("OSinvalidkey"), "Invalid key name should fail")

    // Invalid modifier character
    XCTAssertNil(controller.parseCompactShortcutToCGEventData("Xb"), "Invalid modifier 'X' should fail")
  }
}
