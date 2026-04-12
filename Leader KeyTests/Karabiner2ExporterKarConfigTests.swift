import XCTest
import KeyboardShortcuts
import Defaults
@testable import Leader_Key

final class Karabiner2BackendTests: XCTestCase {
  func testVisibleBackendsExcludeLegacyBothAndPreferKarabinerTS() {
    XCTAssertEqual(Karabiner2Backend.allCases, [.karabinerTS, .goku])
    XCTAssertEqual(Karabiner2Backend.legacyBoth.normalized, .karabinerTS)
    XCTAssertTrue(Karabiner2Backend.karabinerTS.usesKarabinerTsExport)
    XCTAssertFalse(Karabiner2Backend.karabinerTS.usesLegacyGoku)
    XCTAssertFalse(Karabiner2Backend.goku.usesKarabinerTsExport)
    XCTAssertTrue(Karabiner2Backend.goku.usesLegacyGoku)
  }
}

final class Karabiner2ExporterKarabinerTSExportTests: XCTestCase {
  override func setUp() {
    super.setUp()
    Karabiner2Exporter.alternativeMappingsOverride = []
    Karabiner2Exporter.stateIdOverride = nil
  }

  override func tearDown() {
    Karabiner2Exporter.alternativeMappingsOverride = nil
    Karabiner2Exporter.stateIdOverride = nil
    super.tearDown()
  }

  func testGenerateKarabinerTSExportContainsSendUserCommandRoutes() throws {
    let config = makeSampleConfig()

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let payloads = extractSendUserCommandPayloads(from: result.managedRules)

    XCTAssertTrue(payloads.contains("activate"))
    XCTAssertTrue(payloads.contains("deactivate"))
    XCTAssertTrue(payloads.contains("settings"))
    XCTAssertTrue(payloads.contains(where: { $0.hasPrefix("stateid ") }))
    XCTAssertTrue(payloads.contains("shake"))
  }

  func testGenerateKarabinerTSExportPreservesStickyAndResetBehavior() throws {
    let config = makeSampleConfig()
    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let allManipulators = flattenManipulators(from: result.managedRules)

    let stickyTransition = allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "g"
        && hasSendUserCommand(manipulator: manipulator, prefix: "stateid ")
        && hasSetVariable(manipulator: manipulator, name: "leaderkey_sticky", value: 1)
    })
    XCTAssertNotNil(stickyTransition)

    let nonStickyTerminal = allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "x"
        && hasSendUserCommand(manipulator: manipulator, prefix: "deactivate")
        && hasSetVariable(manipulator: manipulator, name: "leader_state", value: 0)
    })
    XCTAssertNotNil(nonStickyTerminal)
  }

  func testStateMappingsAreDeterministic() throws {
    let config = makeSampleConfig()

    let first = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let second = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])

    // Sort mappings before comparing since generateKarabinerTSExport returns unsorted order.
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let firstSorted = Karabiner2Exporter.sortMappings(first.stateMappings)
    let secondSorted = Karabiner2Exporter.sortMappings(second.stateMappings)
    XCTAssertEqual(try encoder.encode(firstSorted), try encoder.encode(secondSorted))
    XCTAssertEqual(try serializeJSON(first.managedRules), try serializeJSON(second.managedRules))
  }

  func testGenerateKarabinerTSExportEncodesKeystrokePayloadsAndStickyBehavior() throws {
    let config = UserConfig()
    let targetedAction = Action(
      key: "k",
      type: .keystroke,
      label: "Targeted Keystroke",
      value: "Google Chrome > Ct",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )
    let focusedAction = Action(
      key: "f",
      type: .keystroke,
      label: "Focused Keystroke",
      value: "Safari > [focus] > CSf",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )
    let stickyAction = Action(
      key: "s",
      type: .keystroke,
      label: "Sticky Keystroke",
      value: "escape",
      iconPath: nil,
      activates: nil,
      stickyMode: true,
      macroSteps: nil
    )

    config.root.actions = [.action(targetedAction), .action(focusedAction), .action(stickyAction)]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let allManipulators = flattenManipulators(from: result.managedRules)

    let targetedMapping = try XCTUnwrap(allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "k"
        && structuredPayloads(manipulator: manipulator).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "Ct"
        })
    }))
    let targetedPayload = try XCTUnwrap(
      structuredPayloads(manipulator: targetedMapping).first(where: {
        ($0["type"] as? String) == "keystroke"
      }))
    XCTAssertEqual(targetedPayload["v"] as? Int, 1)
    XCTAssertEqual(targetedPayload["app"] as? String, "Google Chrome")
    XCTAssertEqual(targetedPayload["spec"] as? String, "Ct")
    XCTAssertNil(targetedPayload["focus"])
    XCTAssertTrue(hasSendUserCommand(manipulator: targetedMapping, prefix: "deactivate"))
    XCTAssertTrue(hasSetVariable(manipulator: targetedMapping, name: "leader_state", value: 0))

    let focusedMapping = try XCTUnwrap(allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "f"
        && structuredPayloads(manipulator: manipulator).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "CSf"
        })
    }))
    let focusedPayload = try XCTUnwrap(
      structuredPayloads(manipulator: focusedMapping).first(where: {
        ($0["type"] as? String) == "keystroke"
      }))
    XCTAssertEqual(focusedPayload["v"] as? Int, 1)
    XCTAssertEqual(focusedPayload["app"] as? String, "Safari")
    XCTAssertEqual(focusedPayload["spec"] as? String, "CSf")
    XCTAssertEqual(focusedPayload["focus"] as? Bool, true)

    let stickyMapping = try XCTUnwrap(allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "s"
        && structuredPayloads(manipulator: manipulator).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "escape"
        })
    }))
    let stickyPayload = try XCTUnwrap(
      structuredPayloads(manipulator: stickyMapping).first(where: {
        ($0["type"] as? String) == "keystroke"
      }))
    XCTAssertEqual(stickyPayload["v"] as? Int, 1)
    XCTAssertNil(stickyPayload["app"])
    XCTAssertEqual(stickyPayload["spec"] as? String, "escape")
    XCTAssertTrue(hasSetVariable(manipulator: stickyMapping, name: "leaderkey_sticky", value: 1))
    XCTAssertFalse(hasSendUserCommand(manipulator: stickyMapping, prefix: "deactivate"))
  }

  func testGenerateKarabinerTSExportProducesDeterministicRepoModuleExports() throws {
    let config = makeSampleConfig()

    let first = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let second = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])

    // Module generation now produces raw JSON data
    let firstJSON = Karabiner2Exporter.generateModuleJSON(managedRules: first.managedRules)
    let secondJSON = Karabiner2Exporter.generateModuleJSON(managedRules: second.managedRules)

    XCTAssertEqual(firstJSON, secondJSON)
    // Verify it's valid JSON array
    let parsed = try JSONSerialization.jsonObject(with: firstJSON, options: [])
    XCTAssertTrue(parsed is [[String: Any]])
  }

  func testGenerateKarabinerTSExportUsesSingleAnyKeyCatchAllMappings() throws {
    let config = makeSampleConfig()

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let allManipulators = flattenManipulators(from: result.managedRules)
    let shakeManipulator = try XCTUnwrap(allManipulators.first(where: { manipulator in
      hasSendUserCommand(manipulator: manipulator, prefix: "shake")
    }))
    let from = try XCTUnwrap(shakeManipulator["from"] as? [String: Any])
    let modifiers = try XCTUnwrap(from["modifiers"] as? [String: Any])

    XCTAssertEqual(from["any"] as? String, "key_code")
    XCTAssertEqual(modifiers["mandatory"] as? [String], ["any"])
  }

  func testGenerateKarabinerTSExportCompactsModeRuleDescriptions() throws {
    let config = makeSampleConfig()

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let descriptions = result.managedRules.compactMap { $0["description"] as? String }

    XCTAssertFalse(descriptions.contains(where: { $0.contains("/State/") || $0.contains("/CatchAll/") }))
    XCTAssertTrue(descriptions.contains("LeaderKeyManaged/GlobalMode"))
    XCTAssertTrue(descriptions.contains("LeaderKeyManaged/FallbackMode"))
    XCTAssertEqual(Set(descriptions).count, descriptions.count)
  }

  func testGenerateKarabinerTSExportCompactsAppSpecificModeRules() throws {
    let globalConfig = makeSampleConfig()
    let appConfig = makeSampleConfig()

    let result = try Karabiner2Exporter.generateKarabinerTSExport(
      globalConfig: globalConfig,
      appConfigs: [(bundleId: "com.apple.Safari", config: appConfig, customName: "Safari")]
    )
    let descriptions = result.managedRules.compactMap { $0["description"] as? String }

    XCTAssertTrue(descriptions.contains("LeaderKeyManaged/AppMode/safari"))
    XCTAssertFalse(descriptions.contains(where: { $0.hasPrefix("LeaderKeyManaged/AppMode/safari/") }))
  }

  func testGenerateKarabinerTSExportIncludesLegacyActivationBranches() throws {
    let globalConfig = makeSampleConfig()
    let appConfig = makeSampleConfig()

    let result = try Karabiner2Exporter.generateKarabinerTSExport(
      globalConfig: globalConfig,
      appConfigs: [(bundleId: "com.apple.Safari", config: appConfig, customName: "Safari")]
    )
    let activationRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/ActivationShortcuts" }))
    let manipulators = flattenManipulators(from: [activationRule])

    XCTAssertTrue(manipulators.contains(where: { fromKeyCode(in: $0) == "semicolon" }))
    XCTAssertTrue(manipulators.contains(where: { fromKeyCode(in: $0) == "right_command" }))
    XCTAssertTrue(manipulators.contains(where: {
      fromKeyCode(in: $0) == "keypad_4"
        && mandatoryModifiers(in: $0) == ["left_command", "left_option", "left_control", "left_shift"]
    }))
    XCTAssertTrue(manipulators.contains(where: {
      fromKeyCode(in: $0) == "keypad_7"
        && mandatoryModifiers(in: $0) == ["left_command", "left_option", "left_control", "left_shift"]
    }))
  }

  func testGenerateKarabinerTSExportIncludesModeGuards() throws {
    let globalConfig = makeSampleConfig()
    let appConfig = makeSampleConfig()

    let result = try Karabiner2Exporter.generateKarabinerTSExport(
      globalConfig: globalConfig,
      appConfigs: [(bundleId: "com.apple.Safari", config: appConfig, customName: "Safari")]
    )

    let appRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/AppMode/safari" }))
    let appManipulator = try XCTUnwrap(flattenManipulators(from: [appRule]).first)
    XCTAssertTrue(hasCondition(appManipulator, name: "leader_state", type: "variable_if"))
    XCTAssertTrue(hasConditionType(appManipulator, type: "frontmost_application_if"))

    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" }))
    let globalManipulator = try XCTUnwrap(flattenManipulators(from: [globalRule]).first)
    XCTAssertTrue(hasCondition(globalManipulator, name: "leader_state", type: "variable_if"))
    XCTAssertFalse(hasConditionType(globalManipulator, type: "frontmost_application_if"))

    let fallbackRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/FallbackMode" }))
    let fallbackManipulator = try XCTUnwrap(flattenManipulators(from: [fallbackRule]).first)
    XCTAssertTrue(hasCondition(fallbackManipulator, name: "leader_state", type: "variable_if"))
    XCTAssertFalse(hasConditionType(fallbackManipulator, type: "frontmost_application_if"))
  }

  func testGenerateKarabinerTSExportRemovesLegacyLeaderVariables() throws {
    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: makeSampleConfig(), appConfigs: [])
    let serialized = String(data: try serializeJSON(result.managedRules), encoding: .utf8) ?? ""

    XCTAssertFalse(serialized.contains("leaderkey_active"))
    XCTAssertFalse(serialized.contains("leaderkey_global"))
    XCTAssertFalse(serialized.contains("leaderkey_appspecific"))
    XCTAssertFalse(serialized.contains("leaderkey_mode"))
  }

  func testGenerateKarabinerTSExportSharesFallbackAcrossAppsWithoutEmptyDeltaRules() throws {
    let fallbackRoot = Group(
      key: nil,
      label: "Fallback",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .action(makeCommandAction(key: "f", label: "Fallback", value: "echo fallback")),
      ]
    )
    let globalConfig = UserConfig()
    let appOne = UserConfig()
    let appTwo = UserConfig()
    appOne.root = fallbackRoot
    appTwo.root = fallbackRoot

    try withTemporaryConfigDirectory(fallbackRoot: fallbackRoot) {
      let result = try Karabiner2Exporter.generateKarabinerTSExport(
        globalConfig: globalConfig,
        appConfigs: [
          (bundleId: "com.apple.Safari", config: appOne, customName: "Safari"),
          (bundleId: "com.google.Chrome", config: appTwo, customName: "Chrome"),
        ]
      )
      let descriptions = result.managedRules.compactMap { $0["description"] as? String }
      XCTAssertTrue(descriptions.contains("LeaderKeyManaged/FallbackMode"))
      XCTAssertEqual(descriptions.filter { $0.hasPrefix("LeaderKeyManaged/AppMode/") }.count, 0)
    }
  }

  func testGenerateKarabinerTSExportEmitsAppOverrideAddAndSuppressDeltas() throws {
    let fallbackRoot = Group(
      key: nil,
      label: "Fallback",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .action(makeCommandAction(key: "o", label: "Fallback Override", value: "echo fallback")),
        .action(makeCommandAction(key: "s", label: "Fallback Suppress", value: "echo suppress")),
        .action(makeCommandAction(key: "k", label: "Fallback Keep", value: "echo keep")),
      ]
    )
    let globalConfig = UserConfig()
    let appConfig = UserConfig()
    appConfig.root = Group(
      key: nil,
      label: "Safari",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .action(makeCommandAction(key: "o", label: "App Override", value: "echo app")),
        .action(makeCommandAction(key: "a", label: "App Add", value: "echo add")),
        .action(makeShortcutAction(key: "s", label: "Suppress", value: "vk_none")),
        .action(makeCommandAction(key: "k", label: "Fallback Keep", value: "echo keep")),
      ]
    )

    try withTemporaryConfigDirectory(fallbackRoot: fallbackRoot) {
      let result = try Karabiner2Exporter.generateKarabinerTSExport(
        globalConfig: globalConfig,
        appConfigs: [(bundleId: "com.apple.Safari", config: appConfig, customName: "Safari")]
      )

      let descriptions = result.managedRules.compactMap { $0["description"] as? String }
      let appRuleIndex = try XCTUnwrap(descriptions.firstIndex(of: "LeaderKeyManaged/AppMode/safari"))
      let fallbackRuleIndex = try XCTUnwrap(descriptions.firstIndex(of: "LeaderKeyManaged/FallbackMode"))
      XCTAssertLessThan(appRuleIndex, fallbackRuleIndex)

      let appRule = try XCTUnwrap(
        result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/AppMode/safari" })
      )
      let fallbackRule = try XCTUnwrap(
        result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/FallbackMode" })
      )
      let appManipulators = flattenManipulators(from: [appRule])
      let fallbackManipulators = flattenManipulators(from: [fallbackRule])

      XCTAssertTrue(appManipulators.contains(where: { fromKeyCode(in: $0) == "o" }))
      XCTAssertTrue(appManipulators.contains(where: { fromKeyCode(in: $0) == "a" }))
      XCTAssertTrue(appManipulators.contains(where: {
        fromKeyCode(in: $0) == "s" && hasKeyCodeEvent($0, keyCode: "vk_none")
      }))
      XCTAssertFalse(appManipulators.contains(where: { fromKeyCode(in: $0) == "k" }))

      XCTAssertTrue(fallbackManipulators.contains(where: { fromKeyCode(in: $0) == "o" }))
      XCTAssertTrue(fallbackManipulators.contains(where: { fromKeyCode(in: $0) == "s" }))
      XCTAssertTrue(fallbackManipulators.contains(where: { fromKeyCode(in: $0) == "k" }))
      XCTAssertFalse(fallbackManipulators.contains(where: { fromKeyCode(in: $0) == "a" }))
    }
  }

  func testGenerateKarabinerTSExportFailsOnStateIdCollision() {
    let config = UserConfig()
    config.root.actions = [
      .group(
        Group(
          key: "a",
          label: "A",
          iconPath: nil,
          stickyMode: nil,
          actions: [.action(makeCommandAction(key: "x", label: "X", value: "echo x"))]
        )
      ),
      .group(
        Group(
          key: "b",
          label: "B",
          iconPath: nil,
          stickyMode: nil,
          actions: [.action(makeCommandAction(key: "y", label: "Y", value: "echo y"))]
        )
      ),
    ]

    Karabiner2Exporter.stateIdOverride = { path, _ in
      path.isEmpty ? nil : 42
    }
    defer { Karabiner2Exporter.stateIdOverride = nil }

    XCTAssertThrowsError(try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])) { error in
      XCTAssertTrue(error.localizedDescription.contains("state-id collision"))
    }
  }

  func testGenerateUnifiedGokuEDNHierarchicalUsesSharedManagedStructure() throws {
    let globalConfig = makeSampleConfig()
    let appConfig = makeSampleConfig()

    let (edn, stateMappings) = try Karabiner2Exporter.generateUnifiedGokuEDNHierarchical(
      globalConfig: globalConfig,
      appConfigs: [(bundleId: "com.apple.Safari", config: appConfig, customName: "Safari")]
    )

    XCTAssertFalse(edn.contains("leaderkey_active"))
    XCTAssertFalse(edn.contains("leaderkey_global"))
    XCTAssertFalse(edn.contains("leaderkey_appspecific"))
    XCTAssertFalse(edn.contains("leaderkey_mode"))
    XCTAssertEqual(edn.components(separatedBy: "Leader Key - Catch All").count - 1, 1)
    XCTAssertEqual(edn.components(separatedBy: ":any \"key_code\"").count - 1, 1)
    XCTAssertFalse(stateMappings.isEmpty)
  }

  func testGenerateKarabinerTSExportAppliesAlternativeMappingsToManagedRules() throws {
    Karabiner2Exporter.alternativeMappingsOverride = [
      AlternativeMapping(originalKey: "h", alternativeKey: "left_arrow", conditions: ["caps_lock-mode"])
    ]

    let config = UserConfig()
    let stickyAction = Action(
      key: "h",
      type: .keystroke,
      label: "Alt",
      value: "escape",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )
    config.root.actions = [.action(stickyAction)]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" }))
    let manipulators = flattenManipulators(from: [globalRule])

    XCTAssertTrue(manipulators.contains(where: {
      fromKeyCode(in: $0) == "left_arrow"
        && hasVariableCondition($0, name: "caps_lock-mode", value: 1, type: "variable_if")
    }))
  }

  func testManualRealConfigExportSmoke() throws {
    let environment = ProcessInfo.processInfo.environment
    let artifactsDirectory = manualExportArtifactsDirectory()
    let triggerFilePath =
      environment["LEADERKEY_REAL_CONFIG_TRIGGER_PATH"]
      ?? artifactsDirectory.appendingPathComponent("leaderkey-real-config-export.trigger").path
    let triggerFileExists = FileManager.default.fileExists(atPath: triggerFilePath)
    guard environment["LEADERKEY_REAL_CONFIG_EXPORT"] == "1" || triggerFileExists else {
      throw XCTSkip("Manual smoke test. Set LEADERKEY_REAL_CONFIG_EXPORT=1 to run.")
    }

    let testAlertManager = TestAlertManager()
    let userConfig = UserConfig(alertHandler: testAlertManager)
    userConfig.discoverConfigFiles()
    userConfig.loadConfig(suppressAlerts: true)

    let appConfigs = try loadRealAppConfigs(using: userConfig)
    let export = try Karabiner2Exporter.generateKarabinerTSExport(
      globalConfig: userConfig,
      appConfigs: appConfigs
    )

    let outputPath =
      environment["LEADERKEY_REAL_CONFIG_OUTPUT_PATH"]
      ?? artifactsDirectory.appendingPathComponent("leaderkey-real-managed-rules.json").path
    let outputURL = URL(fileURLWithPath: outputPath)
    let outputDirectory = outputURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

    let outputData = try JSONSerialization.data(withJSONObject: export.managedRules, options: [.sortedKeys])
    try outputData.write(to: outputURL, options: .atomic)

    let activationRule = try XCTUnwrap(
      export.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/ActivationShortcuts" }))
    let activationManipulators = flattenManipulators(from: [activationRule])
    let totalManipulators = flattenManipulators(from: export.managedRules).count
    let summary: [String: Any] = [
      "app_config_count": appConfigs.count,
      "managed_rule_count": export.managedRules.count,
      "managed_manipulator_count": totalManipulators,
      "activation_manipulator_count": activationManipulators.count,
      "output_path": outputPath,
    ]
    let summaryPath =
      environment["LEADERKEY_REAL_CONFIG_SUMMARY_PATH"]
      ?? artifactsDirectory.appendingPathComponent("leaderkey-real-managed-rules-summary.json").path
    let summaryData = try JSONSerialization.data(withJSONObject: summary, options: [.prettyPrinted, .sortedKeys])
    try summaryData.write(to: URL(fileURLWithPath: summaryPath), options: .atomic)

    XCTAssertGreaterThan(appConfigs.count, 0)
    XCTAssertGreaterThan(export.managedRules.count, 0)
    XCTAssertTrue(activationManipulators.contains(where: { fromKeyCode(in: $0) == "semicolon" }))
    XCTAssertTrue(activationManipulators.contains(where: { fromKeyCode(in: $0) == "right_command" }))
    XCTAssertTrue(activationManipulators.contains(where: {
      fromKeyCode(in: $0) == "keypad_4"
        && mandatoryModifiers(in: $0) == ["left_command", "left_option", "left_control", "left_shift"]
    }))
    XCTAssertTrue(activationManipulators.contains(where: {
      fromKeyCode(in: $0) == "keypad_7"
        && mandatoryModifiers(in: $0) == ["left_command", "left_option", "left_control", "left_shift"]
    }))

    print("[ManualRealConfigExport] wrote managed rules to \(outputPath)")
    print("[ManualRealConfigExport] summary: \(summary)")
  }

  private func makeSampleConfig() -> UserConfig {
    let config = UserConfig()

    let stickyURLAction = Action(
      key: "u",
      type: .url,
      label: "Open URL",
      value: "https://example.com",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )

    let stickyGroup = Group(
      key: "g",
      label: "Sticky Group",
      iconPath: nil,
      stickyMode: true,
      actions: [.action(stickyURLAction)]
    )

    let commandAction = Action(
      key: "x",
      type: .command,
      label: "Run Cmd",
      value: "echo hi",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )

    config.root.actions = [.group(stickyGroup), .action(commandAction)]
    return config
  }

  private func makeCommandAction(key: String, label: String, value: String) -> Action {
    Action(
      key: key,
      type: .command,
      label: label,
      value: value,
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )
  }

  private func makeShortcutAction(key: String, label: String, value: String) -> Action {
    Action(
      key: key,
      type: .shortcut,
      label: label,
      value: value,
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil
    )
  }

  private func withTemporaryConfigDirectory(
    fallbackRoot: Group? = nil,
    body: () throws -> Void
  ) throws {
    let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
      UUID().uuidString,
      isDirectory: true
    )
    let originalConfigDir = Defaults[.configDir]
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

    if let fallbackRoot {
      let fallbackPath = tempDirectory.appendingPathComponent("app-fallback-config.json")
      let data = try JSONEncoder().encode(fallbackRoot)
      try data.write(to: fallbackPath, options: .atomic)
    }

    Defaults[.configDir] = tempDirectory.path
    defer {
      Defaults[.configDir] = originalConfigDir
      try? FileManager.default.removeItem(at: tempDirectory)
    }

    try body()
  }

  private func serializeJSON(_ object: Any) throws -> Data {
    try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
  }

  private func manualExportArtifactsDirectory() -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("tmp", isDirectory: true)
  }

  private func loadRealAppConfigs(using globalConfig: UserConfig) throws -> [(bundleId: String, config: UserConfig, customName: String?)] {
    let configDir = Defaults[.configDir]
    let files = try FileManager.default.contentsOfDirectory(atPath: configDir)
    var appConfigs: [(bundleId: String, config: UserConfig, customName: String?)] = []

    for file in files.sorted() {
      guard file.hasPrefix("app."),
        file.hasSuffix(".json"),
        !file.hasSuffix(".meta.json"),
        file != "app-fallback-config.json"
      else {
        continue
      }

      let bundleId = String(file.dropFirst(4).dropLast(5))
      guard bundleId != "default",
        !bundleId.contains("Leader-Key"),
        !bundleId.contains("leaderkey"),
        !bundleId.contains(".meta")
      else {
        continue
      }

      let appConfig = UserConfig(alertHandler: TestAlertManager())
      appConfig.root = globalConfig.getConfig(for: bundleId)

      let metaFilePath = (configDir as NSString).appendingPathComponent("app.\(bundleId).meta.json")
      let customName: String?
      if FileManager.default.fileExists(atPath: metaFilePath) {
        let metaData = try Data(contentsOf: URL(fileURLWithPath: metaFilePath))
        customName = try JSONDecoder().decode(Karabiner2Exporter.AppMetadata.self, from: metaData).customName
      } else {
        customName = nil
      }

      appConfigs.append((bundleId: bundleId, config: appConfig, customName: customName))
    }

    return appConfigs
  }

  private func flattenManipulators(from rules: [[String: Any]]) -> [[String: Any]] {
    rules.flatMap { ($0["manipulators"] as? [[String: Any]]) ?? [] }
  }

  private func extractSendUserCommandPayloads(from rules: [[String: Any]]) -> [String] {
    var payloads: [String] = []

    for manipulator in flattenManipulators(from: rules) {
      for event in (manipulator["to"] as? [Any]) ?? [] {
          guard
            let eventObject = event as? [String: Any],
            let commandObject = eventObject["send_user_command"] as? [String: Any],
            let payload = commandObject["payload"] as? String
          else {
            continue
          }
        payloads.append(payload)
      }
    }

    return payloads
  }

  private func structuredPayloads(manipulator: [String: Any]) -> [[String: Any]] {
    let events = (manipulator["to"] as? [Any]) ?? []
    return events.compactMap { event in
      guard
        let eventObject = event as? [String: Any],
        let commandObject = eventObject["send_user_command"] as? [String: Any],
        let payload = commandObject["payload"] as? [String: Any]
      else {
        return nil
      }

      return payload
    }
  }

  private func fromKeyCode(in manipulator: [String: Any]) -> String? {
    let from = manipulator["from"] as? [String: Any]
    return from?["key_code"] as? String
  }

  private func mandatoryModifiers(in manipulator: [String: Any]) -> [String]? {
    let from = manipulator["from"] as? [String: Any]
    let modifiers = from?["modifiers"] as? [String: Any]
    return modifiers?["mandatory"] as? [String]
  }

  private func hasVariableCondition(
    _ manipulator: [String: Any],
    name: String,
    value: Int,
    type: String
  ) -> Bool {
    let conditions = (manipulator["conditions"] as? [[String: Any]]) ?? []
    return conditions.contains(where: {
      ($0["name"] as? String) == name
        && ($0["value"] as? NSNumber)?.intValue == value
        && ($0["type"] as? String) == type
    })
  }

  private func hasSendUserCommand(manipulator: [String: Any], prefix: String) -> Bool {
    let events = (manipulator["to"] as? [Any]) ?? []
    return events.contains { event in
      guard
        let eventObject = event as? [String: Any],
        let commandObject = eventObject["send_user_command"] as? [String: Any],
        let payload = commandObject["payload"] as? String
      else {
        return false
      }
      return payload.hasPrefix(prefix)
    }
  }

  private func hasSetVariable(manipulator: [String: Any], name: String, value: Int) -> Bool {
    let events = (manipulator["to"] as? [Any]) ?? []
    return events.contains { event in
      guard
        let eventObject = event as? [String: Any],
        let variableObject = eventObject["set_variable"] as? [String: Any],
        let variableName = variableObject["name"] as? String,
        let variableValue = variableObject["value"] as? NSNumber
      else {
        return false
      }

    return variableName == name && variableValue.intValue == value
    }
  }

  private func hasCondition(_ manipulator: [String: Any], name: String, type: String) -> Bool {
    let conditions = (manipulator["conditions"] as? [[String: Any]]) ?? []
    return conditions.contains(where: {
      ($0["name"] as? String) == name && ($0["type"] as? String) == type
    })
  }

  private func hasConditionType(_ manipulator: [String: Any], type: String) -> Bool {
    let conditions = (manipulator["conditions"] as? [[String: Any]]) ?? []
    return conditions.contains(where: { ($0["type"] as? String) == type })
  }

  private func hasKeyCodeEvent(_ manipulator: [String: Any], keyCode: String) -> Bool {
    let events = (manipulator["to"] as? [Any]) ?? []
    return events.contains { event in
      guard let eventObject = event as? [String: Any] else {
        return false
      }
      return eventObject["key_code"] as? String == keyCode
    }
  }
}

final class Karabiner2ExporterEDNInjectionTests: XCTestCase {
  private var originalDefaultShortcut: KeyboardShortcuts.Shortcut?
  private var originalAppSpecificShortcut: KeyboardShortcuts.Shortcut?

  override func setUp() {
    super.setUp()
    originalDefaultShortcut = KeyboardShortcuts.getShortcut(for: .activateDefaultOnly)
    originalAppSpecificShortcut = KeyboardShortcuts.getShortcut(for: .activateAppSpecific)
  }

  override func tearDown() {
    KeyboardShortcuts.setShortcut(originalDefaultShortcut, for: .activateDefaultOnly)
    KeyboardShortcuts.setShortcut(originalAppSpecificShortcut, for: .activateAppSpecific)
    super.tearDown()
  }

  func testGenerateCanonicalSpecificConfigRulesUsesCanonicalActivationKeysRegardlessOfKeyboardShortcuts() throws {
    KeyboardShortcuts.setShortcut(
      KeyboardShortcuts.Shortcut(.f10, modifiers: [.command, .shift, .control]),
      for: .activateDefaultOnly
    )
    KeyboardShortcuts.setShortcut(
      KeyboardShortcuts.Shortcut(.f11, modifiers: [.command, .shift, .control]),
      for: .activateAppSpecific
    )

    let specificRules = Karabiner2Exporter.generateCanonicalSpecificConfigRules(
      appConfigs: [
        (bundleId: "com.raycast.macos", config: UserConfig(), customName: "Raycast"),
        (bundleId: "com.apple.MobileSMS", config: UserConfig(), customName: "iMessages"),
      ]
    )

    XCTAssertTrue(specificRules.contains(":key_code \"semicolon\""))
    XCTAssertTrue(specificRules.contains(":key_code \"right_command\""))
    XCTAssertTrue(specificRules.contains(":payload \"activate com.raycast.macos\""))
    XCTAssertTrue(specificRules.contains(":payload \"activate\""))
    XCTAssertTrue(specificRules.contains(":payload \"activate __FALLBACK__\""))
    XCTAssertTrue(specificRules.contains(":key_code \"escape\""))
    XCTAssertTrue(specificRules.contains(":payload \"deactivate\""))
    XCTAssertTrue(specificRules.contains(":key_code \"comma\""))
    XCTAssertTrue(specificRules.contains(":payload \"settings\""))
    XCTAssertFalse(specificRules.contains("leaderkey_active"))
    XCTAssertFalse(specificRules.contains("leaderkey_global"))
    XCTAssertFalse(specificRules.contains("leaderkey_appspecific"))
    XCTAssertFalse(specificRules.contains("leaderkey_mode"))
    XCTAssertFalse(specificRules.contains(":key_code \"f10\""))
    XCTAssertFalse(specificRules.contains(":key_code \"f11\""))
  }

  func testGenerateCanonicalSpecificConfigRulesOrdersLongerBundleIDsBeforeShorterAndThenAlphabetically() throws {
    let specificRules = Karabiner2Exporter.generateCanonicalSpecificConfigRules(
      appConfigs: [
        (
          bundleId: "com.google.Chrome",
          config: UserConfig(),
          customName: "Google Chrome"
        ),
        (
          bundleId: "com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm",
          config: UserConfig(),
          customName: "Email Randstad"
        ),
        (
          bundleId: "com.test.aaa",
          config: UserConfig(),
          customName: "AAA"
        ),
        (
          bundleId: "com.test.bbb",
          config: UserConfig(),
          customName: "BBB"
        ),
      ]
    )

    let longChromeRange = try XCTUnwrap(
      specificRules.range(of: ":payload \"activate com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm\"")
    )
    let shortChromeRange = try XCTUnwrap(
      specificRules.range(of: ":payload \"activate com.google.Chrome\"")
    )
    let aaaRange = try XCTUnwrap(
      specificRules.range(of: ":payload \"activate com.test.aaa\"")
    )
    let bbbRange = try XCTUnwrap(
      specificRules.range(of: ":payload \"activate com.test.bbb\"")
    )

    XCTAssertLessThan(longChromeRange.lowerBound, shortChromeRange.lowerBound)
    XCTAssertLessThan(aaaRange.lowerBound, bbbRange.lowerBound)
  }

  func testGenerateCanonicalSpecificConfigRulesAppendsTerminalRulesInFixedOrder() throws {
    let specificRules = Karabiner2Exporter.generateCanonicalSpecificConfigRules(
      appConfigs: [(bundleId: "com.raycast.macos", config: UserConfig(), customName: "Raycast")]
    )

    let raycastRange = try XCTUnwrap(
      specificRules.range(of: ":payload \"activate com.raycast.macos\"")
    )
    let globalRange = try XCTUnwrap(
      specificRules.range(of: ":key_code \"right_command\"")
    )
    let fallbackRange = try XCTUnwrap(
      specificRules.range(of: ":payload \"activate __FALLBACK__\"")
    )
    let escapeRange = try XCTUnwrap(
      specificRules.range(of: ":from {:key_code \"escape\"}")
    )
    let settingsRange = try XCTUnwrap(
      specificRules.range(of: ":from {:key_code \"comma\" :modifiers {:mandatory [\"command\"]}}")
    )

    XCTAssertLessThan(raycastRange.lowerBound, globalRange.lowerBound)
    XCTAssertLessThan(globalRange.lowerBound, fallbackRange.lowerBound)
    XCTAssertLessThan(fallbackRange.lowerBound, escapeRange.lowerBound)
    XCTAssertLessThan(escapeRange.lowerBound, settingsRange.lowerBound)
  }

  func testInjectIntoKarabinerEDNContentReplacesOnlySpecificConfigBlockInsideActivationSection() throws {
    let content = """
      {:main [
         ;;; LEADERKEY_MAIN_START
         {:des "Leader Key - Activation Shortcuts"
          :rules [
          ;; Manual before
          ;;; LEADERKEY_SPECIFIC_CONFIGS_START
          [:old_rule]
          ;;; LEADERKEY_SPECIFIC_CONFIGS_END
          ;; Manual after
          ]}
         {:des "Custom old rule"
          :rules [[:c :d]]}
         ;;; LEADERKEY_MAIN_END
       ]}
      """

    let generatedSpecificRules = """
         {:type :basic :from {:key_code "semicolon"} :to [{:send_user_command {:payload "activate com.raycast.macos"}}]}
         {:type :basic :from {:key_code "right_command"} :to [{:send_user_command {:payload "activate"}}]}
      """

    let generatedMainRules = [
      """
        {:des "Leader Key - Global Mode"
         :rules [
         [:a :b]
         ]}
      """
    ]

    let injection = Karabiner2Exporter.injectIntoKarabinerEDNContent(
      content: content,
      applications: "",
      mainRules: generatedMainRules,
      specificConfigRules: generatedSpecificRules,
      preserveActivationShortcuts: true
    )

    guard case .success = injection.result else {
      return XCTFail("Expected injection to succeed, got \(injection.result)")
    }

    let updatedContent = try XCTUnwrap(injection.updatedContent)
    XCTAssertTrue(updatedContent.contains(";; Manual before"))
    XCTAssertTrue(updatedContent.contains(";; Manual after"))
    XCTAssertTrue(updatedContent.contains(generatedSpecificRules))
    XCTAssertFalse(updatedContent.contains("[:old_rule]"))
    XCTAssertTrue(updatedContent.contains("Leader Key - Global Mode"))
    XCTAssertFalse(updatedContent.contains("Custom old rule"))
  }

  func testInjectIntoKarabinerEDNContentDoesNotPreserveLegacyActivationShortcuts() throws {
    let content = """
      {:main [
         ;;; LEADERKEY_MAIN_START
         {:des "Leader Key - Activation Shortcuts"
          :rules [
          [:escape [["leaderkey_active" 0] ["leaderkey_global" 0] ["leaderkey_appspecific" 0]] :leaderkey_active]
          ]}
         {:des "Custom old rule"
          :rules [[:c :d]]}
         ;;; LEADERKEY_MAIN_END
       ]}
      """

    let generatedActivation = """
        {:des "Leader Key - Activation Shortcuts"
         :rules [
         {:type :basic :from {:key_code "escape"} :to [{:set_variable {:name "leader_state" :value 0}}] :conditions [{:type :variable_unless :name "leader_state" :value 0}]}
         ]}
      """

    let generatedMainRules = [
      generatedActivation,
      """
        {:des "Leader Key - Global Mode"
         :rules [
         {:type :basic :from {:key_code "a"} :to [{:key_code "b"}]}
         ]}
      """
    ]

    let injection = Karabiner2Exporter.injectIntoKarabinerEDNContent(
      content: content,
      applications: "",
      mainRules: generatedMainRules,
      specificConfigRules: "",
      preserveActivationShortcuts: true
    )

    guard case .success = injection.result else {
      return XCTFail("Expected injection to succeed, got \(injection.result)")
    }

    let updatedContent = try XCTUnwrap(injection.updatedContent)
    XCTAssertFalse(updatedContent.contains("leaderkey_active"))
    XCTAssertFalse(updatedContent.contains("leaderkey_global"))
    XCTAssertFalse(updatedContent.contains("leaderkey_appspecific"))
    XCTAssertTrue(updatedContent.contains(":variable_unless :name \"leader_state\""))
    XCTAssertTrue(updatedContent.contains("Leader Key - Global Mode"))
    XCTAssertFalse(updatedContent.contains("Custom old rule"))
  }

  func testInjectIntoKarabinerEDNContentSupportsSpecificMarkersWithoutAppOrMainMarkers() throws {
    let content = """
      {:main [
         {:des "Leader Key - Activation Shortcuts"
          :rules [
          ;;; LEADERKEY_SPECIFIC_CONFIGS_START
          [:old_rule]
          ;;; LEADERKEY_SPECIFIC_CONFIGS_END
          ]}
       ]}
      """

    let injection = Karabiner2Exporter.injectIntoKarabinerEDNContent(
      content: content,
      applications: "",
      mainRules: [],
      specificConfigRules: "   {:type :basic :from {:key_code \"escape\"} :to [{:send_user_command {:payload \"deactivate\"}}]}"
    )

    guard case .success = injection.result else {
      return XCTFail("Expected injection to succeed, got \(injection.result)")
    }

    let updatedContent = try XCTUnwrap(injection.updatedContent)
    XCTAssertTrue(updatedContent.contains(":key_code \"escape\""))
    XCTAssertFalse(updatedContent.contains("[:old_rule]"))
  }

  func testInjectIntoKarabinerEDNContentReturnsPartialMarkersForSpecificConfigBlock() {
    let content = """
      {:main [
         {:des "Leader Key - Activation Shortcuts"
          :rules [
          ;;; LEADERKEY_SPECIFIC_CONFIGS_START
          [:old_rule]
          ]}
       ]}
      """

    let injection = Karabiner2Exporter.injectIntoKarabinerEDNContent(
      content: content,
      applications: "",
      mainRules: [],
      specificConfigRules: "   {:type :basic :from {:key_code \"escape\"} :to [{:send_user_command {:payload \"deactivate\"}}]}"
    )

    switch injection.result {
    case .partialMarkersFound(let missing):
      XCTAssertEqual(missing, [";;; LEADERKEY_SPECIFIC_CONFIGS_END"])
    default:
      XCTFail("Expected partial marker failure, got \(injection.result)")
    }
  }

  func testInjectIntoKarabinerEDNContentStillUpdatesApplicationsAndMainWithoutSpecificMarkers() throws {
    let content = """
      {:applications {
         ;;; LEADERKEY_APPLICATIONS_START
         ;; placeholder
         ;;; LEADERKEY_APPLICATIONS_END
       }
       :main [
         ;;; LEADERKEY_MAIN_START
         ;; placeholder
         ;;; LEADERKEY_MAIN_END
       ]}
      """

    let injection = Karabiner2Exporter.injectIntoKarabinerEDNContent(
      content: content,
      applications: "   :raycast [\"com.raycast.macos\"]",
      mainRules: [
        """
          {:des "Leader Key - Global Mode"
           :rules [
           [:a :b]
           ]}
        """
      ]
    )

    guard case .success = injection.result else {
      return XCTFail("Expected injection to succeed, got \(injection.result)")
    }

    let updatedContent = try XCTUnwrap(injection.updatedContent)
    XCTAssertTrue(updatedContent.contains(":raycast [\"com.raycast.macos\"]"))
    XCTAssertTrue(updatedContent.contains("Leader Key - Global Mode"))
    XCTAssertFalse(updatedContent.contains("LEADERKEY_SPECIFIC_CONFIGS"))
  }
}
