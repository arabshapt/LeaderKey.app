import Cocoa
import Defaults
import XCTest
@testable import Leader_Key

final class KarCompilerServiceTests: XCTestCase {
  func testPatchedKarabinerRootReplacesOnlyManagedRulesInSelectedProfile() throws {
    let unmanagedRule: [String: Any] = [
      "description": "KeepMe",
      "manipulators": [["type": "basic"]]
    ]
    let managedRule: [String: Any] = [
      "description": "LeaderKeyManaged/Old",
      "manipulators": [["type": "basic", "from": ["key_code": "a"]]]
    ]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "Default",
          "selected": true,
          "complex_modifications": [
            "rules": [unmanagedRule, managedRule]
          ]
        ]
      ]
    ]

    let compiledRules: [[String: Any]] = [
      [
        "description": "LeaderKeyManaged/New",
        "manipulators": [["type": "basic", "from": ["key_code": "b"]]]
      ]
    ]

    let patched = try KarCompilerService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])
    let profile = try XCTUnwrap(profiles.first)
    let complex = try XCTUnwrap(profile["complex_modifications"] as? [String: Any])
    let rules = try XCTUnwrap(complex["rules"] as? [[String: Any]])

    XCTAssertEqual(rules.count, 2)
    XCTAssertEqual(rules[0]["description"] as? String, "KeepMe")
    XCTAssertEqual(rules[1]["description"] as? String, "LeaderKeyManaged/New")
  }

  func testPatchedKarabinerRootOnlyTouchesSelectedProfile() throws {
    let unselectedRule: [String: Any] = ["description": "UnselectedRule"]
    let selectedRule: [String: Any] = ["description": "LeaderKeyManaged/SelectedOld"]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "ProfileA",
          "selected": false,
          "complex_modifications": ["rules": [unselectedRule]]
        ],
        [
          "name": "ProfileB",
          "selected": true,
          "complex_modifications": ["rules": [selectedRule]]
        ]
      ]
    ]

    let compiledRules: [[String: Any]] = [["description": "LeaderKeyManaged/NewRule"]]

    let patched = try KarCompilerService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])

    let firstProfileRules = try XCTUnwrap(
      (profiles[0]["complex_modifications"] as? [String: Any])?["rules"] as? [[String: Any]])
    XCTAssertEqual(firstProfileRules.count, 1)
    XCTAssertEqual(firstProfileRules[0]["description"] as? String, "UnselectedRule")

    let secondProfileRules = try XCTUnwrap(
      (profiles[1]["complex_modifications"] as? [String: Any])?["rules"] as? [[String: Any]])
    XCTAssertEqual(secondProfileRules.count, 1)
    XCTAssertEqual(secondProfileRules[0]["description"] as? String, "LeaderKeyManaged/NewRule")
    XCTAssertEqual(profiles[1]["selected"] as? Bool, true)
  }

  func testPatchedKarabinerRootKeepsManagedBlockPosition() throws {
    let leadingRule: [String: Any] = ["description": "LeadingRule"]
    let managedRuleA: [String: Any] = ["description": "LeaderKeyManaged/OldA"]
    let managedRuleB: [String: Any] = ["description": "LeaderKeyManaged/OldB"]
    let trailingRule: [String: Any] = ["description": "TrailingRule"]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "Default",
          "selected": true,
          "complex_modifications": [
            "rules": [leadingRule, managedRuleA, managedRuleB, trailingRule]
          ]
        ]
      ]
    ]

    let compiledRules: [[String: Any]] = [
      ["description": "LeaderKeyManaged/NewA"],
      ["description": "LeaderKeyManaged/NewB"]
    ]

    let patched = try KarCompilerService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])
    let profile = try XCTUnwrap(profiles.first)
    let complex = try XCTUnwrap(profile["complex_modifications"] as? [String: Any])
    let rules = try XCTUnwrap(complex["rules"] as? [[String: Any]])
    let descriptions = rules.compactMap { $0["description"] as? String }

    XCTAssertEqual(
      descriptions,
      ["LeadingRule", "LeaderKeyManaged/NewA", "LeaderKeyManaged/NewB", "TrailingRule"])
  }
}

final class StatusItemTests: XCTestCase {
  private var statusItem: TestStatusItem!

  override func setUp() {
    super.setUp()
    defaultsSuite = UserDefaults(suiteName: name)!
    defaultsSuite.removePersistentDomain(forName: name)
    Defaults[.playReloadSuccessSound] = false

    statusItem = TestStatusItem()
    statusItem.reloadSuccessFeedbackTiming = .init(fadeDuration: 0.005, holdDuration: 0.05)
  }

  override func tearDown() {
    statusItem = nil
    defaultsSuite.removePersistentDomain(forName: name)
    super.tearDown()
  }

  func testIndicateReloadSuccessNoOpsWithoutStatusItem() {
    statusItem.providesFeedbackButton = false
    statusItem.indicateReloadSuccess()

    XCTAssertFalse(statusItem.isShowingReloadSuccessFeedback)
    XCTAssertEqual(statusItem.renderedAppearance, .normal)
  }

  func testIndicateReloadSuccessRestoresActiveAppearanceAfterPulse() {
    statusItem.appearance = .active

    statusItem.indicateReloadSuccess()

    XCTAssertTrue(statusItem.isShowingReloadSuccessFeedback)
    XCTAssertEqual(statusItem.renderedAppearance, .reloadSuccess)
    XCTAssertNotNil(statusItem.testButton.contentTintColor)
    XCTAssertEqual(statusItem.testButton.alphaValue, 1.0)

    statusItem.fireLatestScheduledReset()

    XCTAssertFalse(statusItem.isShowingReloadSuccessFeedback)
    XCTAssertEqual(statusItem.renderedAppearance, .active)
    XCTAssertNil(statusItem.testButton.contentTintColor)
    XCTAssertEqual(statusItem.testButton.alphaValue, 1.0)
  }

  func testIndicateReloadSuccessRestartsExistingPulse() throws {
    statusItem.indicateReloadSuccess()
    let firstReset = try XCTUnwrap(statusItem.scheduledResetWorkItems.last)

    statusItem.indicateReloadSuccess()
    let secondReset = try XCTUnwrap(statusItem.scheduledResetWorkItems.last)

    XCTAssertFalse(firstReset === secondReset)
    XCTAssertEqual(statusItem.scheduledResetWorkItems.count, 2)
    XCTAssertTrue(statusItem.isShowingReloadSuccessFeedback)
    XCTAssertEqual(statusItem.renderedAppearance, .reloadSuccess)

    statusItem.fireLatestScheduledReset()

    XCTAssertFalse(statusItem.isShowingReloadSuccessFeedback)
    XCTAssertEqual(statusItem.renderedAppearance, .normal)
  }
}

private final class TestStatusItem: StatusItem {
  let testButton = NSButton(frame: NSRect(x: 0, y: 0, width: 18, height: 18))
  var providesFeedbackButton = true
  var scheduledResetWorkItems: [DispatchWorkItem] = []

  override func feedbackButton() -> NSButton? {
    providesFeedbackButton ? testButton : nil
  }

  override func performOnMain(_ work: @escaping () -> Void) {
    work()
  }

  override func scheduleReloadSuccessReset(after delay: TimeInterval, workItem: DispatchWorkItem) {
    _ = delay
    scheduledResetWorkItems.append(workItem)
  }

  override func animate(
    button: NSButton,
    toAlpha alphaValue: CGFloat,
    duration: TimeInterval,
    completion: (() -> Void)? = nil
  ) {
    button.alphaValue = alphaValue
    completion?()
  }

  func fireLatestScheduledReset() {
    let workItem = scheduledResetWorkItems.removeLast()
    workItem.perform()
  }
}

private final class StatusItemSpy: StatusItem {
  var reloadSuccessCount = 0

  override func indicateReloadSuccess() {
    reloadSuccessCount += 1
  }
}

final class AppDelegateConfigEventTests: XCTestCase {
  override func setUp() {
    super.setUp()
    defaultsSuite = UserDefaults(suiteName: name)!
    defaultsSuite.removePersistentDomain(forName: name)
  }

  override func tearDown() {
    defaultsSuite.removePersistentDomain(forName: name)
    super.tearDown()
  }

  func testHandleConfigEventTriggersSuccessFeedbackOnlyForDidReload() {
    let appDelegate = AppDelegate()
    let statusItemSpy = StatusItemSpy()
    appDelegate.statusItem = statusItemSpy

    appDelegate.handleConfigEvent(
      .didSaveConfig,
      refreshStateMappings: {},
      refreshActiveSequenceAfterReload: {}
    )
    XCTAssertEqual(statusItemSpy.reloadSuccessCount, 0)

    appDelegate.handleConfigEvent(
      .didReload,
      refreshStateMappings: {},
      refreshActiveSequenceAfterReload: {}
    )
    XCTAssertEqual(statusItemSpy.reloadSuccessCount, 1)
  }
}
