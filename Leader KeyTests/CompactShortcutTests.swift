import Carbon.HIToolbox
import XCTest
@testable import Leader_Key

final class CompactShortcutTests: XCTestCase {
  func testParseValidShortcuts() {
    let cmdShiftB = CompactShortcut.parse("CSb")
    XCTAssertEqual(cmdShiftB?.keyCode, CGKeyCode(kVK_ANSI_B))
    XCTAssertEqual(cmdShiftB?.flags, [.maskCommand, .maskShift])

    let ctrlOptionF12 = CompactShortcut.parse("TOf12")
    XCTAssertEqual(ctrlOptionF12?.keyCode, CGKeyCode(kVK_F12))
    XCTAssertEqual(ctrlOptionF12?.flags, [.maskControl, .maskAlternate])

    let duplicateModifiers = CompactShortcut.parse("CCTOSa")
    XCTAssertEqual(duplicateModifiers?.keyCode, CGKeyCode(kVK_ANSI_A))
    XCTAssertEqual(duplicateModifiers?.flags, [.maskCommand, .maskControl, .maskAlternate, .maskShift])
  }

  func testParseSupportedNonLetterKeys() {
    XCTAssertEqual(CompactShortcut.parse("Cspacebar")?.keyCode, CGKeyCode(kVK_Space))
    XCTAssertEqual(CompactShortcut.parse("page_down")?.keyCode, CGKeyCode(kVK_PageDown))
    XCTAssertEqual(CompactShortcut.parse("Okeypad_plus")?.keyCode, CGKeyCode(kVK_ANSI_KeypadPlus))
    XCTAssertEqual(CompactShortcut.parse("japanese_kana")?.keyCode, CGKeyCode(kVK_JIS_Kana))
  }

  func testParseInvalidShortcuts() {
    XCTAssertNil(CompactShortcut.parse(""))
    XCTAssertNil(CompactShortcut.parse("CSCTO"))
    XCTAssertNil(CompactShortcut.parse("OSinvalidkey"))
    XCTAssertNil(CompactShortcut.parse("Xb"))
  }

  func testParseKeystrokeActionValuePreservesBackwardCompatibleTargeting() {
    let systemWide = KeystrokeActionValue.parse("Ct")
    XCTAssertNil(systemWide.app)
    XCTAssertEqual(systemWide.spec, "Ct")
    XCTAssertFalse(systemWide.focusTargetApp)

    let targeted = KeystrokeActionValue.parse("Google Chrome > Ct")
    XCTAssertEqual(targeted.app, "Google Chrome")
    XCTAssertEqual(targeted.spec, "Ct")
    XCTAssertFalse(targeted.focusTargetApp)
    XCTAssertEqual(targeted.serialized, "Google Chrome > Ct")
  }

  func testParseKeystrokeActionValueWithFocusMarker() {
    let focused = KeystrokeActionValue.parse("Safari > [focus] > CSf")
    XCTAssertEqual(focused.app, "Safari")
    XCTAssertEqual(focused.spec, "CSf")
    XCTAssertTrue(focused.focusTargetApp)
    XCTAssertEqual(focused.serialized, "Safari > [focus] > CSf")
  }
}
