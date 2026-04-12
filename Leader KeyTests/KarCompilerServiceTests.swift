import Cocoa
import Defaults
import XCTest
@testable import Leader_Key

final class KarabinerTsExportServiceTests: XCTestCase {
  func testValidateKarabinerTsRepoRejectsPathWithoutWorkspaceMarkers() throws {
    let repoURL = try makeTemporaryDirectory()

    let result = KarabinerTsExportService.shared.validateKarabinerTsRepo(repoPath: repoURL.path)

    XCTAssertFalse(result.success)
    XCTAssertTrue(result.message.contains("workspace marker"))
  }

  func testCompileAndApplyWritesManagedRepoFilesAndPreservesBootstrap() throws {
    let repoURL = try makeTemporaryDirectory()
    let karabinerJSONURL = repoURL.appendingPathComponent("karabiner.json")
    let bootstrapURL = repoURL.appendingPathComponent("configs/leaderkey/index.ts")
    let unrelatedURL = repoURL.appendingPathComponent("README.md")

    try "{}".write(to: repoURL.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)
    try FileManager.default.createDirectory(
      at: bootstrapURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try "export const preserved = true\n".write(to: bootstrapURL, atomically: true, encoding: .utf8)
    try "keep me\n".write(to: unrelatedURL, atomically: true, encoding: .utf8)
    try writeKarabinerJSON(
      [
        "profiles": [
          [
            "name": "Default",
            "selected": true,
            "complex_modifications": [
              "rules": [
                ["description": "KeepMe", "manipulators": [["type": "basic"]]]
              ]
            ],
          ]
        ]
      ], to: karabinerJSONURL)

    let result = KarabinerTsExportService.shared.compileAndApply(
      managedRules: [
        ["description": "LeaderKeyManaged/NewRule", "manipulators": [["type": "basic", "from": ["key_code": "b"]]]]
      ],
      repoModuleData: Data("[]".utf8),
      repoPath: repoURL.path,
      karabinerJsonPath: karabinerJSONURL.path
    )

    XCTAssertTrue(result.success)
    let generatedModulePath = repoURL.appendingPathComponent(KarabinerTsExportService.generatedModuleRelativePath)
    let legacyModulePath = repoURL.appendingPathComponent(KarabinerTsExportService.legacyGeneratedModuleRelativePath)
    XCTAssertTrue(FileManager.default.fileExists(atPath: generatedModulePath.path))
    XCTAssertTrue(FileManager.default.fileExists(atPath: legacyModulePath.path))
    XCTAssertTrue(try String(contentsOf: legacyModulePath).contains("leaderkey-generated.json"))
    XCTAssertEqual(try String(contentsOf: bootstrapURL), "export const preserved = true\n")
    XCTAssertEqual(try String(contentsOf: unrelatedURL), "keep me\n")

    let patchedRoot = try readKarabinerJSON(from: karabinerJSONURL)
    let profiles = try XCTUnwrap(patchedRoot["profiles"] as? [[String: Any]])
    let rules = try XCTUnwrap(
      (profiles[0]["complex_modifications"] as? [String: Any])?["rules"] as? [[String: Any]])
    XCTAssertEqual(rules.count, 2)
    XCTAssertEqual(rules[0]["description"] as? String, "KeepMe")
    XCTAssertEqual(rules[1]["description"] as? String, "LeaderKeyManaged/NewRule")
  }

  func testCompileAndApplySkipsUnchangedGeneratedOutputs() throws {
    let repoURL = try makeTemporaryDirectory()
    let karabinerJSONURL = repoURL.appendingPathComponent("karabiner.json")
    try "{}".write(to: repoURL.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)
    try writeKarabinerJSON(
      [
        "profiles": [
          [
            "name": "Default",
            "selected": true,
            "complex_modifications": [
              "rules": [
                ["description": "KeepMe", "manipulators": [["type": "basic"]]]
              ]
            ],
          ]
        ]
      ], to: karabinerJSONURL)

    let managedRules = [
      ["description": "LeaderKeyManaged/NewRule", "manipulators": [["type": "basic", "from": ["key_code": "b"]]]]
    ]
    let moduleData = Data("[]".utf8)

    let firstResult = KarabinerTsExportService.shared.compileAndApply(
      managedRules: managedRules,
      repoModuleData: moduleData,
      repoPath: repoURL.path,
      karabinerJsonPath: karabinerJSONURL.path
    )
    XCTAssertTrue(firstResult.success)

    let generatedModuleURL = repoURL.appendingPathComponent(KarabinerTsExportService.generatedModuleRelativePath)
    let legacyModuleURL = repoURL.appendingPathComponent(KarabinerTsExportService.legacyGeneratedModuleRelativePath)
    let firstKarabinerModifiedAt = try modificationDate(for: karabinerJSONURL)
    let firstModuleModifiedAt = try modificationDate(for: generatedModuleURL)
    let firstLegacyModuleModifiedAt = try modificationDate(for: legacyModuleURL)

    Thread.sleep(forTimeInterval: 1.1)

    let secondResult = KarabinerTsExportService.shared.compileAndApply(
      managedRules: managedRules,
      repoModuleData: moduleData,
      repoPath: repoURL.path,
      karabinerJsonPath: karabinerJSONURL.path
    )
    XCTAssertTrue(secondResult.success)

    XCTAssertEqual(try modificationDate(for: karabinerJSONURL), firstKarabinerModifiedAt)
    XCTAssertEqual(try modificationDate(for: generatedModuleURL), firstModuleModifiedAt)
    XCTAssertEqual(try modificationDate(for: legacyModuleURL), firstLegacyModuleModifiedAt)
  }

  func testMigrateGokuProfileWritesCompactManualSnapshotAndFiltersLegacyLeaderKeyRules() throws {
    let repoURL = try makeTemporaryDirectory()
    try "{}".write(to: repoURL.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)

    let ednURL = repoURL.appendingPathComponent("karabiner.edn")
    try "{:profiles {:Default {:default true}}}\n".write(to: ednURL, atomically: true, encoding: .utf8)

    let fakeGokuURL = repoURL.appendingPathComponent("fake-goku")
    try """
      #!/bin/sh
      cat <<'JSON'
      {"complex_modifications":{"parameters":{"basic.to_if_alone_timeout_milliseconds":260},"rules":[{"description":"KeepManual","manipulators":[{"type":"basic"}]},{"description":"LeaderKeyManaged/Old","manipulators":[{"type":"basic"},{"type":"basic"}]},{"description":"Leader Key - Old Global","manipulators":[{"type":"basic"}]}]}}
      JSON
      """.write(to: fakeGokuURL, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fakeGokuURL.path)

    let result = KarabinerTsExportService.shared.migrateGokuProfileToKarabinerTs(
      repoPath: repoURL.path,
      ednPath: ednURL.path,
      profileName: "Default",
      gokuBinaryPath: fakeGokuURL.path
    )

    XCTAssertTrue(result.success, result.message)

    let snapshotURL = repoURL.appendingPathComponent(
      KarabinerTsExportService.migratedGokuComplexModificationsRelativePath)
    let moduleURL = repoURL.appendingPathComponent(
      KarabinerTsExportService.migratedGokuProfileModuleRelativePath)
    let metadataURL = repoURL.appendingPathComponent(
      KarabinerTsExportService.migratedGokuMetadataRelativePath)

    let snapshot = try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(contentsOf: snapshotURL)) as? [String: Any])
    let rules = try XCTUnwrap(snapshot["rules"] as? [[String: Any]])
    XCTAssertEqual(rules.count, 1)
    XCTAssertEqual(rules.first?["description"] as? String, "KeepManual")

    let module = try String(contentsOf: moduleURL)
    XCTAssertTrue(module.contains("default-complex-modifications.json"))
    XCTAssertTrue(module.contains("replaceProfileComplexModifications"))

    let metadata = try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(contentsOf: metadataURL)) as? [String: Any])
    XCTAssertEqual(metadata["source_rules"] as? Int, 3)
    XCTAssertEqual(metadata["rules"] as? Int, 1)
    XCTAssertEqual(metadata["removed_legacy_leaderkey_rules"] as? Int, 2)
    XCTAssertEqual(metadata["removed_legacy_leaderkey_manipulators"] as? Int, 3)
  }

  func testCompileAndApplyDoesNotTouchKarabinerJSONWhenRepoExportFails() throws {
    let repoURL = try makeTemporaryDirectory()
    let karabinerJSONURL = repoURL.appendingPathComponent("karabiner.json")
    let originalRoot: [String: Any] = [
      "profiles": [
        [
          "name": "Default",
          "selected": true,
          "complex_modifications": [
            "rules": [
              ["description": "KeepMe", "manipulators": [["type": "basic"]]]
            ]
          ],
        ]
      ]
    ]
    try writeKarabinerJSON(originalRoot, to: karabinerJSONURL)

    let invalidRepoPath = repoURL.appendingPathComponent("missing-workspace").path
    let result = KarabinerTsExportService.shared.compileAndApply(
      managedRules: [
        ["description": "LeaderKeyManaged/NewRule", "manipulators": [["type": "basic", "from": ["key_code": "b"]]]]
      ],
      repoModuleData: Data("[]".utf8),
      repoPath: invalidRepoPath,
      karabinerJsonPath: karabinerJSONURL.path
    )

    XCTAssertFalse(result.success)
    let currentRoot = try readKarabinerJSON(from: karabinerJSONURL)
    XCTAssertEqual(try serializedJSON(currentRoot), try serializedJSON(originalRoot))
  }

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

    let patched = try KarabinerTsExportService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])
    let profile = try XCTUnwrap(profiles.first)
    let complex = try XCTUnwrap(profile["complex_modifications"] as? [String: Any])
    let rules = try XCTUnwrap(complex["rules"] as? [[String: Any]])

    XCTAssertEqual(rules.count, 2)
    XCTAssertEqual(rules[0]["description"] as? String, "KeepMe")
    XCTAssertEqual(rules[1]["description"] as? String, "LeaderKeyManaged/New")
  }

  func testPatchedKarabinerRootReplacesLegacyLeaderKeyRulesDuringMigration() throws {
    let unmanagedRule: [String: Any] = [
      "description": "KeepMe",
      "manipulators": [["type": "basic"]]
    ]
    let legacyLeaderKeyRule: [String: Any] = [
      "description": "Leader Key - Global Mode",
      "manipulators": [["type": "basic", "from": ["key_code": "a"]]]
    ]

    let root: [String: Any] = [
      "profiles": [
        [
          "name": "Default",
          "selected": true,
          "complex_modifications": [
            "rules": [unmanagedRule, legacyLeaderKeyRule]
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

    let patched = try KarabinerTsExportService.patchedKarabinerRoot(root, compiledRules: compiledRules)
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

    let patched = try KarabinerTsExportService.patchedKarabinerRoot(root, compiledRules: compiledRules)
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

    let patched = try KarabinerTsExportService.patchedKarabinerRoot(root, compiledRules: compiledRules)
    let profiles = try XCTUnwrap(patched["profiles"] as? [[String: Any]])
    let profile = try XCTUnwrap(profiles.first)
    let complex = try XCTUnwrap(profile["complex_modifications"] as? [String: Any])
    let rules = try XCTUnwrap(complex["rules"] as? [[String: Any]])
    let descriptions = rules.compactMap { $0["description"] as? String }

    XCTAssertEqual(
      descriptions,
      ["LeadingRule", "LeaderKeyManaged/NewA", "LeaderKeyManaged/NewB", "TrailingRule"])
  }

  private func makeTemporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }

  private func modificationDate(for url: URL) throws -> Date {
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    return try XCTUnwrap(attributes[.modificationDate] as? Date)
  }

  private func writeKarabinerJSON(_ root: [String: Any], to url: URL) throws {
    let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
    try data.write(to: url, options: .atomic)
  }

  private func readKarabinerJSON(from url: URL) throws -> [String: Any] {
    let data = try Data(contentsOf: url)
    return try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
  }

  private func serializedJSON(_ object: Any) throws -> Data {
    try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
  }
}

final class StatusItemTests: XCTestCase {
  private var statusItem: TestStatusItem!

  override func setUp() {
    super.setUp()
    defaultsSuite = UserDefaults(suiteName: name)!
    defaultsSuite.removePersistentDomain(forName: name)
    Defaults[.reloadSuccessSound] = .off

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

  func testReloadSuccessSoundSelectionMapsToBuiltInSystemSounds() {
    XCTAssertNil(ReloadSuccessSound.off.soundName)
    XCTAssertEqual(ReloadSuccessSound.glass.soundName, "Glass")
    XCTAssertEqual(ReloadSuccessSound.hero.soundName, "Hero")
    XCTAssertEqual(ReloadSuccessSound.ping.soundName, "Ping")
    XCTAssertEqual(ReloadSuccessSound.pop.soundName, "Pop")
    XCTAssertEqual(ReloadSuccessSound.funk.soundName, "Funk")
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

private final class TestLeaderKeyWindow: MainWindow {
  override var hasCheatsheet: Bool { false }

  required init(controller: Controller) {
    super.init(controller: controller, contentRect: NSRect(x: 100, y: 100, width: 640, height: 480))
  }

  override func show(at origin: NSPoint? = nil, after: (() -> Void)? = nil) {
    shouldBeVisible = true
    if let origin {
      setFrameOrigin(origin)
    }
    alphaValue = 1
    orderFront(nil)
    after?()
  }

  override func hide(after: (() -> Void)?) {
    shouldBeVisible = false
    alphaValue = 0
    orderOut(nil)
    after?()
  }
}

final class AppDelegateConfigEventTests: XCTestCase {
  private enum TestStateId {
    static let globalGroup: Int32 = 3001
    static let sharedAppGroup: Int32 = 3002
  }

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

  func testSharedAppStateUsesActivationContextToReopenMergedAppConfig() throws {
    let fixture = try makeActivationFixture()

    fixture.appDelegate.inputMethodDidReceiveActivation(bundleId: fixture.bundleId)
    drainMainQueue()
    drainMainQueue()

    fixture.appDelegate.controller.window.hide(after: nil)
    fixture.appDelegate.inputMethodDidReceiveStateId(TestStateId.sharedAppGroup)
    drainMainQueue()
    drainMainQueue()

    XCTAssertEqual(fixture.appDelegate.controller.userState.activeRoot?.label, "App Root")
  }

  func testFallbackActivationKeepsSharedAppStateInFallbackConfig() throws {
    let fixture = try makeActivationFixture()

    fixture.appDelegate.inputMethodDidReceiveActivation(bundleId: "__FALLBACK__")
    drainMainQueue()
    drainMainQueue()

    fixture.appDelegate.controller.window.hide(after: nil)
    fixture.appDelegate.inputMethodDidReceiveStateId(TestStateId.sharedAppGroup)
    drainMainQueue()
    drainMainQueue()

    XCTAssertEqual(fixture.appDelegate.controller.userState.activeRoot?.label, "Fallback Root")
  }

  func testGlobalStateIdResolvesWithoutActivationContext() throws {
    let fixture = try makeActivationFixture()

    fixture.appDelegate.inputMethodDidReceiveStateId(TestStateId.globalGroup)
    drainMainQueue()
    drainMainQueue()

    XCTAssertEqual(fixture.appDelegate.controller.userState.activeRoot?.label, "Global Root")
  }

  private func makeActivationFixture() throws -> (appDelegate: AppDelegate, bundleId: String, configURL: URL) {
    let configURL = try makeTemporaryDirectory()
    Defaults[.configDir] = configURL.path

    let globalRoot = Group(
      key: nil,
      label: "Global Root",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .group(Group(key: "g", label: "Global Child", iconPath: nil, stickyMode: nil, actions: []))
      ]
    )
    let fallbackRoot = Group(
      key: nil,
      label: "Fallback Root",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .group(Group(key: "f", label: "Fallback Child", iconPath: nil, stickyMode: nil, actions: []))
      ]
    )
    let appRoot = Group(
      key: nil,
      label: "App Root",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .group(Group(key: "a", label: "App Child", iconPath: nil, stickyMode: nil, actions: []))
      ]
    )

    try writeConfig(globalRoot, named: "global-config.json", into: configURL)
    try writeConfig(fallbackRoot, named: "app-fallback-config.json", into: configURL)

    let bundleId = "com.example.Editor"
    try writeConfig(appRoot, named: "app.\(bundleId).json", into: configURL)
    try writeStateMappings(
      [
        Karabiner2Exporter.StateMapping(
          stateId: TestStateId.globalGroup,
          path: ["g"],
          scope: .global,
          appAlias: nil,
          bundleId: nil,
          actionType: "group",
          actionTypeRaw: nil,
          actionValue: nil,
          actionLabel: "Global Child"
        ),
        Karabiner2Exporter.StateMapping(
          stateId: TestStateId.sharedAppGroup,
          path: ["f"],
          scope: .appShared,
          appAlias: nil,
          bundleId: nil,
          actionType: "group",
          actionTypeRaw: nil,
          actionValue: nil,
          actionLabel: "Fallback Child"
        ),
      ],
      into: configURL
    )

    let appDelegate = AppDelegate()
    appDelegate.config.discoverConfigFiles()
    appDelegate.config.loadConfig()

    let userState = UserState(userConfig: appDelegate.config)
    appDelegate.state = userState
    let controller = Controller(userState: userState, userConfig: appDelegate.config, appDelegate: appDelegate)
    controller.window = TestLeaderKeyWindow(controller: controller)
    appDelegate.controller = controller

    return (appDelegate, bundleId, configURL)
  }

  private func writeConfig(_ group: Group, named fileName: String, into directory: URL) throws {
    let data = try JSONEncoder().encode(group)
    try data.write(to: directory.appendingPathComponent(fileName), options: .atomic)
  }

  private func writeStateMappings(_ mappings: [Karabiner2Exporter.StateMapping], into directory: URL) throws {
    let exportDirectory = directory.appendingPathComponent("export", isDirectory: true)
    try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
    let data = try JSONEncoder().encode(mappings)
    try data.write(
      to: exportDirectory.appendingPathComponent("leaderkey-state-mappings.json"),
      options: .atomic
    )
  }

  private func makeTemporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }

  private func drainMainQueue(file: StaticString = #filePath, line: UInt = #line) {
    let expectation = expectation(description: "main-queue-drain")
    DispatchQueue.main.async {
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
