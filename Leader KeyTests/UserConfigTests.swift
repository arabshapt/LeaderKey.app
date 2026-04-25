import Defaults
import XCTest

@testable import Leader_Key

class TestAlertManager: AlertHandler {
  var shownAlerts: [(style: NSAlert.Style, message: String)] = []

  func showAlert(style: NSAlert.Style, message: String) {
    shownAlerts.append((style: style, message: message))
  }

  func reset() {
    shownAlerts = []
  }
}

final class UserConfigTests: XCTestCase {
  var tempBaseDir: String!
  var testAlertManager: TestAlertManager!
  var subject: UserConfig!
  var originalSuite: UserDefaults!

  override func setUp() {
    super.setUp()

    // Create a temporary UserDefaults suite for testing
    originalSuite = defaultsSuite
    defaultsSuite = UserDefaults(suiteName: UUID().uuidString)!

    // Create a unique temporary directory for each test
    tempBaseDir = NSTemporaryDirectory().appending("/LeaderKeyTests-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(atPath: tempBaseDir, withIntermediateDirectories: true)

    testAlertManager = TestAlertManager()
    subject = UserConfig(alertHandler: testAlertManager)

    // Set the config directory to our temp directory by default
    Defaults[.configDir] = tempBaseDir
  }

  override func tearDown() {
    try? FileManager.default.removeItem(atPath: tempBaseDir)
    testAlertManager.reset()

    // Restore original UserDefaults suite
    defaultsSuite = originalSuite

    subject = nil
    super.tearDown()
  }

  func testInitializesWithDefaults() throws {
    subject.ensureAndLoad()

    XCTAssertNotEqual(subject.root, emptyRoot)
    XCTAssertTrue(subject.exists)
    XCTAssertTrue(
      FileManager.default.fileExists(
        atPath: (Defaults[.configDir] as NSString).appendingPathComponent("normal-fallback-config.json")
      )
    )
    XCTAssertEqual(testAlertManager.shownAlerts.count, 0)
  }

  func testDiscoversNormalModeConfigsAndMergesFallback() throws {
    let normalFallback = Group(
      key: nil,
      label: "Normal Fallback",
      iconPath: nil,
      stickyMode: nil,
      actions: [.action(Action(key: "f", type: .command, label: "Fallback", value: "echo fallback", iconPath: nil, activates: nil, stickyMode: nil, macroSteps: nil))]
    )
    let normalApp = Group(
      key: nil,
      label: "Chrome Normal",
      iconPath: nil,
      stickyMode: nil,
      actions: [.action(Action(key: "b", type: .command, label: "Browser", value: "echo browser", iconPath: nil, activates: nil, stickyMode: nil, macroSteps: nil))]
    )
    let encoder = JSONEncoder()
    try encoder.encode(normalFallback).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("normal-fallback-config.json"))
    )
    try encoder.encode(normalApp).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("normal-app.com.google.Chrome.json"))
    )

    subject.ensureAndLoad()

    XCTAssertNotNil(subject.discoveredConfigFiles[normalFallbackConfigDisplayName])
    XCTAssertNotNil(subject.discoveredConfigFiles["Normal: com.google.Chrome"])
    XCTAssertEqual(subject.extractNormalAppBundleId(from: "Normal: com.google.Chrome"), "com.google.Chrome")

    let mergedNormal = subject.getNormalConfig(for: "com.google.Chrome")
    XCTAssertTrue(mergedNormal.actions.contains(where: { $0.item.key == "b" }))
    XCTAssertTrue(mergedNormal.actions.contains(where: {
      guard case .action(let action) = $0 else { return false }
      return action.key == "f" && action.fallbackSource == normalFallbackConfigDisplayName
    }))
  }

  func testCreatesDefaultConfigDirIfNotExists() throws {
    // Pre-create the directory so ensureValidConfigDirectory doesn't reset to default.
    // This test verifies that ensureAndLoad creates the config *files* inside an existing dir.
    let testDir = tempBaseDir.appending("/FreshConfigDir")
    try? FileManager.default.removeItem(atPath: testDir)
    try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    Defaults[.configDir] = testDir

    subject.ensureAndLoad()

    XCTAssertTrue(FileManager.default.fileExists(atPath: testDir))
    XCTAssertTrue(subject.exists)
    XCTAssertEqual(testAlertManager.shownAlerts.count, 0)
    XCTAssertNotEqual(subject.root, emptyRoot)  // Verify the config was parsed successfully
  }

  func testResetsToDefaultDirWhenCustomDirDoesNotExist() throws {
    let nonExistentDir = tempBaseDir.appending("/DoesNotExist")
    Defaults[.configDir] = nonExistentDir

    subject.ensureAndLoad()

    XCTAssertEqual(Defaults[.configDir], UserConfig.defaultDirectory())
    XCTAssertEqual(testAlertManager.shownAlerts.count, 1)
    XCTAssertEqual(testAlertManager.shownAlerts[0].style, .warning)
    XCTAssertTrue(
      testAlertManager.shownAlerts[0].message.contains("Config directory does not exist"))
    XCTAssertTrue(subject.exists)
  }

  func testShowsAlertWhenConfigFileFailsToParse() throws {
    // Use temp dir with a valid config first, then corrupt it (never touch real config dir)
    Defaults[.configDir] = tempBaseDir
    subject.ensureAndLoad()  // Creates valid global-config.json in temp dir

    let invalidJSON = "{ invalid json }"
    try invalidJSON.write(to: subject.url, atomically: true, encoding: .utf8)

    subject.ensureAndLoad()

    XCTAssertEqual(subject.root, emptyRoot)
    XCTAssertGreaterThan(testAlertManager.shownAlerts.count, 0)
    // Verify that at least one critical alert was shown
    XCTAssertTrue(
      testAlertManager.shownAlerts.contains { alert in
        alert.style == .critical
      })
  }
}
