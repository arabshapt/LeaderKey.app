import AppKit
import XCTest
@testable import Leader_Key

final class KarabinerCommandRouterTests: XCTestCase {
  private final class MockDelegate: UnixSocketServerDelegate {
    var activationBundleId: String?
    var applyConfigCount = 0
    var deactivationCount = 0
    var settingsCount = 0
    var shakeCount = 0
    var lastKeyCode: UInt16?
    var lastModifiers: NSEvent.ModifierFlags?
    var lastSequence: String?
    var lastStateId: Int32?
    var lastSticky = false
    var state: [String: Any] = ["active": true, "mode": "karabiner2"]

    func unixSocketServerDidReceiveActivation(bundleId: String?) {
      activationBundleId = bundleId
    }

    func unixSocketServerDidReceiveApplyConfig() {
      applyConfigCount += 1
    }

    func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
      lastKeyCode = keyCode
      lastModifiers = modifiers
    }

    func unixSocketServerDidReceiveDeactivation() {
      deactivationCount += 1
    }

    func unixSocketServerDidReceiveSettings() {
      settingsCount += 1
    }

    func unixSocketServerDidReceiveSequence(_ sequence: String) {
      lastSequence = sequence
    }

    func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool) {
      lastStateId = stateId
      lastSticky = sticky
    }

    func unixSocketServerDidReceiveShake() {
      shakeCount += 1
    }

    func unixSocketServerRequestState() -> [String: Any] {
      state
    }
  }

  func testRouteActivationAndDeactivationCommands() {
    let delegate = MockDelegate()

    XCTAssertEqual(
      KarabinerCommandRouter.route(command: "activate com.example.app", delegate: delegate),
      "OK")
    XCTAssertEqual(delegate.activationBundleId, "com.example.app")

    XCTAssertEqual(KarabinerCommandRouter.route(command: "deactivate", delegate: delegate), "OK")
    XCTAssertEqual(delegate.deactivationCount, 1)
  }

  func testRouteApplyConfigCommand() {
    let delegate = MockDelegate()

    XCTAssertEqual(KarabinerCommandRouter.route(command: "apply-config", delegate: delegate), "OK")
    XCTAssertEqual(delegate.applyConfigCount, 1)
  }

  func testRouteKeyCommandParsesCharacterAndModifiers() {
    let delegate = MockDelegate()

    XCTAssertEqual(KarabinerCommandRouter.route(command: "key a cmd shift", delegate: delegate), "OK")
    XCTAssertEqual(delegate.lastKeyCode, 0)
    XCTAssertTrue(delegate.lastModifiers?.contains(.command) == true)
    XCTAssertTrue(delegate.lastModifiers?.contains(.shift) == true)
  }

  func testRouteStateIdSequenceSettingsAndShakeCommands() {
    let delegate = MockDelegate()

    XCTAssertEqual(KarabinerCommandRouter.route(command: "stateid 42 sticky", delegate: delegate), "OK")
    XCTAssertEqual(delegate.lastStateId, 42)
    XCTAssertTrue(delegate.lastSticky)

    XCTAssertEqual(KarabinerCommandRouter.route(command: "sequence a b c", delegate: delegate), "OK")
    XCTAssertEqual(delegate.lastSequence, "a b c")

    XCTAssertEqual(KarabinerCommandRouter.route(command: "settings", delegate: delegate), "OK")
    XCTAssertEqual(delegate.settingsCount, 1)

    XCTAssertEqual(KarabinerCommandRouter.route(command: "shake", delegate: delegate), "OK")
    XCTAssertEqual(delegate.shakeCount, 1)
  }

  func testRouteStateReturnsJSON() {
    let delegate = MockDelegate()

    let response = KarabinerCommandRouter.route(command: "state", delegate: delegate)

    XCTAssertTrue(response.contains("\"active\""))
    XCTAssertTrue(response.contains("\"mode\""))
  }

  func testRouteRejectsUnknownCommand() {
    let delegate = MockDelegate()

    let response = KarabinerCommandRouter.route(command: "unknown", delegate: delegate)

    XCTAssertTrue(response.hasPrefix("ERROR: Unknown command"))
  }

  func testNormalizePayloadString() {
    XCTAssertEqual(KarabinerCommandRouter.normalizeSendUserCommandPayload(" activate "), "activate")
  }

  func testNormalizePayloadStringArray() {
    XCTAssertEqual(
      KarabinerCommandRouter.normalizeSendUserCommandPayload(["stateid", "12", "sticky"]),
      "stateid 12 sticky")
  }

  func testNormalizePayloadObjectCommandLineArguments() {
    let payload: [String: Any] = ["command_line_arguments": ["key", "a", "cmd"]]
    XCTAssertEqual(KarabinerCommandRouter.normalizeSendUserCommandPayload(payload), "key a cmd")
  }

  func testNormalizePayloadObjectCommand() {
    let payload: [String: Any] = ["command": "settings"]
    XCTAssertEqual(KarabinerCommandRouter.normalizeSendUserCommandPayload(payload), "settings")
  }

  func testNormalizePayloadInvalidReturnsNil() {
    let payload: [String: Any] = ["command_line_arguments": ["stateid", 12]]
    XCTAssertNil(KarabinerCommandRouter.normalizeSendUserCommandPayload(payload))
  }
}
