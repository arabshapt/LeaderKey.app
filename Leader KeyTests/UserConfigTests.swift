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

  func testTagAssignmentsCreateVirtualAppConfigAndMergeInOrder() throws {
    let registry = TagsRegistry(
      tags: [
        TagDefinition(id: "browser", name: "Browser"),
        TagDefinition(id: "web", name: "Web"),
      ],
      assignments: TagAssignments(
        app: ["com.google.Chrome": ["browser", "web"]],
        normalApp: [:]
      )
    )
    let fallback = Group(
      actions: [
        .group(
          Group(
            key: "w",
            label: "Window",
            stickyMode: nil,
            actions: [
              .action(Action(key: "d", type: .command, value: "echo fallback duplicate")),
              .action(Action(key: "f", type: .command, value: "echo fallback only")),
            ]
          )
        )
      ]
    )
    let browserTag = Group(
      actions: [
        .group(
          Group(
            key: "w",
            label: "Window",
            stickyMode: nil,
            actions: [
              .action(Action(key: "d", type: .command, value: "echo browser wins")),
              .action(Action(key: "b", type: .command, value: "echo browser only")),
            ]
          )
        )
      ]
    )
    let webTag = Group(
      actions: [
        .group(
          Group(
            key: "w",
            label: "Window",
            stickyMode: nil,
            actions: [
              .action(Action(key: "d", type: .command, value: "echo web shadowed")),
              .action(Action(key: "x", type: .command, value: "echo web only")),
            ]
          )
        )
      ]
    )

    let encoder = JSONEncoder()
    try encoder.encode(registry).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("tags-registry.json"))
    )
    try encoder.encode(fallback).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("app-fallback-config.json"))
    )
    try encoder.encode(browserTag).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("tag.browser.json"))
    )
    try encoder.encode(webTag).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("tag.web.json"))
    )

    subject.ensureAndLoad()

    XCTAssertNotNil(subject.discoveredConfigFiles["App: com.google.Chrome"])
    XCTAssertFalse(
      FileManager.default.fileExists(
        atPath: (tempBaseDir as NSString).appendingPathComponent("app.com.google.Chrome.json")
      )
    )

    let merged = subject.getConfig(for: "com.google.Chrome")
    guard case .group(let windowGroup) = merged.actions.first(where: { $0.item.key == "w" }) else {
      return XCTFail("Expected merged window group")
    }

    let duplicate = windowGroup.actions.compactMap { item -> Action? in
      guard case .action(let action) = item, action.key == "d" else { return nil }
      return action
    }.first
    XCTAssertEqual(duplicate?.value, "echo browser wins")
    XCTAssertEqual(duplicate?.fallbackSource, "\(tagConfigDisplayPrefix)Browser")

    let webOnly = windowGroup.actions.compactMap { item -> Action? in
      guard case .action(let action) = item, action.key == "x" else { return nil }
      return action
    }.first
    XCTAssertEqual(webOnly?.value, "echo web only")
    XCTAssertEqual(webOnly?.fallbackSource, "\(tagConfigDisplayPrefix)Web")

    let fallbackOnly = windowGroup.actions.compactMap { item -> Action? in
      guard case .action(let action) = item, action.key == "f" else { return nil }
      return action
    }.first
    XCTAssertEqual(fallbackOnly?.value, "echo fallback only")
    XCTAssertEqual(fallbackOnly?.fallbackSource, defaultAppConfigDisplayName)
  }

  func testTagAssignmentsMergeWhenFallbackConfigIsMissing() throws {
    let registry = TagsRegistry(
      tags: [TagDefinition(id: "browser", name: "Browser")],
      assignments: TagAssignments(
        app: ["com.google.Chrome": ["browser"]],
        normalApp: [:]
      )
    )
    let browserTag = Group(
      actions: [
        .action(Action(key: "b", type: .command, value: "echo browser"))
      ]
    )

    let encoder = JSONEncoder()
    try encoder.encode(registry).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("tags-registry.json"))
    )
    try encoder.encode(browserTag).write(
      to: URL(fileURLWithPath: (tempBaseDir as NSString).appendingPathComponent("tag.browser.json"))
    )

    let merged = subject.getConfig(for: "com.google.Chrome")
    let inheritedTagAction = merged.actions.compactMap { item -> Action? in
      guard case .action(let action) = item, action.key == "b" else { return nil }
      return action
    }.first
    XCTAssertEqual(inheritedTagAction?.value, "echo browser")
    XCTAssertEqual(inheritedTagAction?.fallbackSource, "\(tagConfigDisplayPrefix)Browser")
  }

  func testTagCrudAssignmentReorderAndDeletionSemantics() throws {
    let browser = subject.createTag(name: "Browser Tools")
    XCTAssertEqual(browser?.id, "browser-tools")
    XCTAssertTrue(
      FileManager.default.fileExists(
        atPath: (tempBaseDir as NSString).appendingPathComponent("tag.browser-tools.json")
      )
    )

    let duplicate = subject.createTag(name: "Browser Tools", createRegularConfig: false)
    XCTAssertEqual(duplicate?.id, "browser-tools-2")

    let renamed = subject.renameTag(id: "browser-tools", name: "Web Browsers")
    XCTAssertEqual(renamed?.id, "browser-tools")
    XCTAssertEqual(renamed?.name, "Web Browsers")

    _ = subject.updateTagAssignments(
      bundleId: "com.google.Chrome",
      normalMode: false,
      tagIds: ["browser-tools", "browser-tools-2"]
    )
    _ = subject.moveAssignedTag(
      bundleId: "com.google.Chrome",
      normalMode: false,
      tagId: "browser-tools-2",
      direction: -1
    )
    var registry = subject.loadTagsRegistry()
    XCTAssertEqual(registry.assignments.app["com.google.Chrome"], ["browser-tools-2", "browser-tools"])

    XCTAssertFalse(subject.deleteTag(id: "browser-tools"))
    XCTAssertTrue(
      testAlertManager.shownAlerts.contains {
        $0.message.contains("assigned")
      }
    )

    XCTAssertTrue(subject.deleteTag(id: "browser-tools", removeAssignments: true))
    registry = subject.loadTagsRegistry()
    XCTAssertFalse(registry.tags.contains(where: { $0.id == "browser-tools" }))
    XCTAssertEqual(registry.assignments.app["com.google.Chrome"], ["browser-tools-2"])
    XCTAssertFalse(
      FileManager.default.fileExists(
        atPath: (tempBaseDir as NSString).appendingPathComponent("tag.browser-tools.json")
      )
    )
  }

  func testSavePrunesEmptyDraftActionsBeforeValidation() throws {
    let chromeConfigPath = (tempBaseDir as NSString).appendingPathComponent(
      "app.com.google.Chrome.json")
    let chromeConfig = Group(
      key: nil,
      label: "Chrome",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .group(
          Group(
            key: "w",
            label: "Window",
            stickyMode: nil,
            actions: [
              .action(Action(key: ";", type: .url, value: "")),
              .action(Action(key: "n", type: .shortcut, label: "New Window", value: "Cn")),
            ]
          )
        )
      ]
    )
    let encoder = JSONEncoder()
    try encoder.encode(chromeConfig).write(to: URL(fileURLWithPath: chromeConfigPath))

    subject.ensureAndLoad()
    testAlertManager.reset()
    subject.loadConfigForEditing(key: "App: com.google.Chrome")
    subject.saveCurrentlyEditingConfig()

    let savedData = try Data(contentsOf: URL(fileURLWithPath: chromeConfigPath))
    let savedConfig = try JSONDecoder().decode(Group.self, from: savedData)

    guard case .group(let windowGroup) = savedConfig.actions.first else {
      return XCTFail("Expected saved Chrome config to keep the Window group")
    }

    XCTAssertFalse(
      windowGroup.actions.contains(where: {
        guard case .action(let action) = $0 else { return false }
        return action.key == ";" && action.type == .url && action.value.isEmpty
      })
    )
    XCTAssertTrue(
      windowGroup.actions.contains(where: {
        guard case .action(let action) = $0 else { return false }
        return action.key == "n" && action.type == .shortcut && action.value == "Cn"
      })
    )
    XCTAssertFalse(
      testAlertManager.shownAlerts.contains(where: {
        $0.message.contains("validation issue")
      })
    )
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
    XCTAssertTrue(
      testAlertManager.shownAlerts.contains {
        $0.style == .warning && $0.message.contains("Config directory does not exist")
      })
    XCTAssertTrue(subject.exists)
  }

  /// Hammers the app-config cache from concurrent readers while the main
  /// thread clears it, mirroring export-queue getConfig vs reloadConfig.
  /// Guards the locked accessors — with an unsynchronized dictionary this
  /// crashes or trips TSan.
  func testConcurrentGetConfigWhileClearingCacheDoesNotCrash() throws {
    Defaults[.configDir] = tempBaseDir
    subject.ensureAndLoad()

    let appJSON = """
      {"type":"group","actions":[{"key":"a","type":"command","value":"true","label":"Test"}]}
      """
    try appJSON.write(
      toFile: tempBaseDir + "/app.com.test.one.json", atomically: true, encoding: .utf8)
    try appJSON.write(
      toFile: tempBaseDir + "/app.com.test.two.json", atomically: true, encoding: .utf8)

    // A handful of dedicated workers mirrors production concurrency (main +
    // export queues) without exhausting the GCD thread pool.
    let workerCount = 4
    let iterationsPerWorker = 25
    let group = DispatchGroup()
    for worker in 0..<workerCount {
      DispatchQueue(label: "hammer-\(worker)").async(group: group) {
        for i in 0..<iterationsPerWorker {
          let bundleId = (worker + i) % 2 == 0 ? "com.test.one" : "com.test.two"
          _ = self.subject.getConfig(for: bundleId)
          _ = self.subject.getNormalConfig(for: bundleId)
        }
      }
    }

    let hammerDone = expectation(description: "hammer done")
    group.notify(queue: .main) { hammerDone.fulfill() }

    // Interleave cache clears while the workers run.
    for _ in 0..<25 {
      subject.clearAppConfigCache()
      RunLoop.current.run(until: Date().addingTimeInterval(0.002))
    }

    // Generous timeout: ThreadSanitizer slows the decode/merge path heavily.
    wait(for: [hammerDone], timeout: 60)
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
