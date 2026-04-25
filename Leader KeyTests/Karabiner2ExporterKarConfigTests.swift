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

    let targetedMappings = allManipulators.filter { manipulator in
      fromKeyCode(in: manipulator) == "k"
        && structuredPayloads(manipulator: manipulator).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "Ct"
        })
    }
    let targetedMapping = try XCTUnwrap(targetedMappings.first(where: { manipulator in
      hasVariableCondition(manipulator, name: "leaderkey_sticky", value: 1, type: "variable_unless")
    }))
    let targetedStickyMapping = try XCTUnwrap(targetedMappings.first(where: { manipulator in
      hasVariableCondition(manipulator, name: "leaderkey_sticky", value: 1, type: "variable_if")
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
    XCTAssertFalse(hasSendUserCommand(manipulator: targetedStickyMapping, prefix: "deactivate"))
    XCTAssertFalse(hasSetVariable(manipulator: targetedStickyMapping, name: "leader_state", value: 0))
    XCTAssertTrue(hasSetVariable(manipulator: targetedStickyMapping, name: "leaderkey_sticky", value: 1))

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

  func testStickyShortcutExportsKeyEventLastForRepeat() throws {
    let config = UserConfig()
    let stickyShortcut = Action(
      key: "m",
      type: .shortcut,
      label: "Sticky Shortcut",
      value: "Ct",
      iconPath: nil,
      activates: nil,
      stickyMode: true,
      macroSteps: nil
    )
    config.root.actions = [.action(stickyShortcut)]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" })
    )
    let allManipulators = flattenManipulators(from: [globalRule])
    let mapping = try XCTUnwrap(allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "m" && hasKeyCodeEvent(manipulator, keyCode: "t")
    }))
    let events = toEvents(in: mapping)

    XCTAssertFalse(hasSendUserCommand(manipulator: mapping, prefix: "stateid "))
    XCTAssertLessThan(
      try XCTUnwrap(indexOfSetVariableEvent(events, name: "leaderkey_sticky", value: 1)),
      try XCTUnwrap(indexOfKeyCodeEvent(events, keyCode: "t"))
    )
    XCTAssertEqual(lastKeyCodeEvent(in: mapping)?["key_code"] as? String, "t")
    XCTAssertEqual(lastKeyCodeEvent(in: mapping)?["modifiers"] as? [String], ["command"])
  }

  func testRuntimeStickyShortcutBranchExportsKeyEventLastAndNonStickyBranchResets() throws {
    let config = UserConfig()
    config.root.actions = [
      .action(makeShortcutAction(key: "m", label: "Runtime Sticky Shortcut", value: "Ct"))
    ]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" })
    )
    let allManipulators = flattenManipulators(from: [globalRule])
    let mappings = allManipulators.filter { fromKeyCode(in: $0) == "m" }
    let stickyMapping = try XCTUnwrap(mappings.first(where: { manipulator in
      hasVariableCondition(manipulator, name: "leaderkey_sticky", value: 1, type: "variable_if")
    }))
    let nonStickyMapping = try XCTUnwrap(mappings.first(where: { manipulator in
      hasVariableCondition(manipulator, name: "leaderkey_sticky", value: 1, type: "variable_unless")
    }))
    let stickyEvents = toEvents(in: stickyMapping)

    XCTAssertFalse(hasSendUserCommand(manipulator: stickyMapping, prefix: "stateid "))
    XCTAssertLessThan(
      try XCTUnwrap(indexOfSetVariableEvent(stickyEvents, name: "leaderkey_sticky", value: 1)),
      try XCTUnwrap(indexOfKeyCodeEvent(stickyEvents, keyCode: "t"))
    )
    XCTAssertEqual(lastKeyCodeEvent(in: stickyMapping)?["key_code"] as? String, "t")
    XCTAssertEqual(lastKeyCodeEvent(in: stickyMapping)?["modifiers"] as? [String], ["command"])
    XCTAssertTrue(hasSendUserCommand(manipulator: nonStickyMapping, prefix: "stateid "))
    XCTAssertTrue(hasSetVariable(manipulator: nonStickyMapping, name: "leader_state", value: 0))
  }

  func testComplexStickyShortcutFallsBackToStateIdCommand() throws {
    let config = UserConfig()
    let complexShortcut = Action(
      key: "m",
      type: .shortcut,
      label: "Complex Sticky Shortcut",
      value: "Ct delay:500 Ot",
      iconPath: nil,
      activates: nil,
      stickyMode: true,
      macroSteps: nil
    )
    config.root.actions = [.action(complexShortcut)]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" })
    )
    let allManipulators = flattenManipulators(from: [globalRule])
    let mapping = try XCTUnwrap(allManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "m"
        && sendUserCommandPayloads(manipulator: manipulator).contains(where: {
          $0.hasPrefix("stateid ") && $0.hasSuffix(" sticky")
        })
    }))

    XCTAssertTrue(hasSetVariable(manipulator: mapping, name: "leaderkey_sticky", value: 1))
    XCTAssertFalse(hasKeyCodeEvent(mapping, keyCode: "t"))
    XCTAssertFalse(hasKeyCodeEvent(mapping, keyCode: "o"))
  }

  func testToggleStickyModeActionExportsAsStickyTerminalAction() throws {
    let config = UserConfig()
    config.root.actions = [
      .action(
        Action(
          key: "s",
          type: .toggleStickyMode,
          label: "Toggle Sticky Mode",
          value: "",
          iconPath: nil,
          activates: nil,
          stickyMode: nil,
          macroSteps: nil
        )
      )
    ]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" })
    )
    let globalManipulators = flattenManipulators(from: [globalRule])
    let toggleMapping = try XCTUnwrap(globalManipulators.first(where: { manipulator in
      fromKeyCode(in: manipulator) == "s"
        && hasSendUserCommand(manipulator: manipulator, prefix: "stateid ")
    }))
    let payloads = sendUserCommandPayloads(manipulator: toggleMapping)

    XCTAssertTrue(payloads.contains(where: { $0.hasPrefix("stateid ") && $0.hasSuffix(" sticky") }))
    XCTAssertTrue(hasSetVariable(manipulator: toggleMapping, name: "leaderkey_sticky", value: 1))
    XCTAssertFalse(hasSetVariable(manipulator: toggleMapping, name: "leader_state", value: 0))
    XCTAssertFalse(hasSendUserCommand(manipulator: toggleMapping, prefix: "deactivate"))
  }

  func testRuntimeStickyModeKeepsNonStickyTerminalActionsActive() throws {
    let config = UserConfig()
    config.root.actions = [
      .group(
        Group(
          key: "o",
          label: "Options",
          iconPath: nil,
          stickyMode: nil,
          actions: [
            .action(
              Action(
                key: " ",
                type: .toggleStickyMode,
                label: "Toggle Sticky Mode",
                value: "",
                iconPath: nil,
                activates: nil,
                stickyMode: nil,
                macroSteps: nil
              )
            ),
            .action(makeCommandAction(key: "x", label: "Run Command", value: "echo x")),
          ]
        )
      )
    ]

    let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: config, appConfigs: [])
    let globalRule = try XCTUnwrap(
      result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/GlobalMode" })
    )
    let globalManipulators = flattenManipulators(from: [globalRule])
    let actionMappings = globalManipulators.filter { manipulator in
      fromKeyCode(in: manipulator) == "x"
    }

    XCTAssertTrue(actionMappings.contains(where: { manipulator in
      hasVariableCondition(manipulator, name: "leaderkey_sticky", value: 1, type: "variable_if")
        && !hasSetVariable(manipulator: manipulator, name: "leader_state", value: 0)
        && !hasSendUserCommand(manipulator: manipulator, prefix: "deactivate")
    }))
    XCTAssertTrue(actionMappings.contains(where: { manipulator in
      hasVariableCondition(manipulator, name: "leaderkey_sticky", value: 1, type: "variable_unless")
        && hasSetVariable(manipulator: manipulator, name: "leader_state", value: 0)
        && hasSendUserCommand(manipulator: manipulator, prefix: "deactivate")
    }))
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

  func testGenerateKarabinerTSExportIncludesNormalModeRulesAndGuards() throws {
    let globalConfig = UserConfig()
    globalConfig.root.actions = [
      .action(makeCommandAction(key: "x", label: "Global X", value: "echo global"))
    ]

    let normalFallbackRoot = Group(
      key: nil,
      label: "Normal Fallback",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .action(makeCommandAction(key: "f", label: "Fallback", value: "echo fallback")),
        .group(
          Group(
            key: "g",
            label: "Go",
            iconPath: nil,
            stickyMode: nil,
            actions: [.action(makeCommandAction(key: "x", label: "Nested", value: "echo nested"))]
          )
        ),
      ]
    )
    let normalAppConfig = UserConfig()
    normalAppConfig.root = Group(
      key: nil,
      label: "Chrome Normal",
      iconPath: nil,
      stickyMode: nil,
      actions: [.action(makeCommandAction(key: "b", label: "Browser", value: "echo browser"))]
    )

    try withTemporaryConfigDirectory(normalFallbackRoot: normalFallbackRoot) {
      let result = try Karabiner2Exporter.generateKarabinerTSExport(
        globalConfig: globalConfig,
        appConfigs: [],
        normalAppConfigs: [(bundleId: "com.google.Chrome", config: normalAppConfig, customName: "Chrome")]
      )

      let descriptions = result.managedRules.compactMap { $0["description"] as? String }
      let normalAppIndex = try XCTUnwrap(descriptions.firstIndex(of: "LeaderKeyManaged/NormalAppMode/chrome"))
      let normalFallbackIndex = try XCTUnwrap(descriptions.firstIndex(of: "LeaderKeyManaged/NormalFallbackMode"))
      XCTAssertLessThan(normalAppIndex, normalFallbackIndex)
      XCTAssertTrue(descriptions.contains("LeaderKeyManaged/NormalControls"))
      XCTAssertTrue(descriptions.contains("LeaderKeyManaged/NormalCatchAll"))

      let normalAppRule = try XCTUnwrap(
        result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/NormalAppMode/chrome" })
      )
      let normalAppManipulator = try XCTUnwrap(flattenManipulators(from: [normalAppRule]).first(where: {
        fromKeyCode(in: $0) == "b"
      }))
      XCTAssertTrue(hasVariableCondition(normalAppManipulator, name: "leader_state", value: 0, type: "variable_if"))
      XCTAssertTrue(hasVariableCondition(normalAppManipulator, name: "leaderkey_normal_enabled", value: 1, type: "variable_if"))
      XCTAssertTrue(hasVariableCondition(normalAppManipulator, name: "leaderkey_normal_input", value: 1, type: "variable_unless"))
      XCTAssertTrue(hasVariableCondition(normalAppManipulator, name: "leaderkey_normal_state", value: 0, type: "variable_if"))
      XCTAssertTrue(hasConditionType(normalAppManipulator, type: "frontmost_application_if"))
      XCTAssertTrue(hasSendUserCommand(manipulator: normalAppManipulator, prefix: "stateid "))

      let normalFallbackRule = try XCTUnwrap(
        result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/NormalFallbackMode" })
      )
      let normalFallbackManipulators = flattenManipulators(from: [normalFallbackRule])
      XCTAssertTrue(normalFallbackManipulators.contains(where: { fromKeyCode(in: $0) == "f" }))
      XCTAssertTrue(normalFallbackManipulators.contains(where: {
        fromKeyCode(in: $0) == "g"
          && hasSetVariableNamed($0, name: "leaderkey_normal_state")
          && !hasSendUserCommand(manipulator: $0, prefix: "stateid ")
      }))

      XCTAssertTrue(result.stateMappings.contains(where: {
        $0.scope == .normalShared && $0.actionType == "action" && $0.path == ["f"]
      }))
      XCTAssertTrue(result.stateMappings.contains(where: {
        $0.scope == .normalOverride && $0.actionType == "action" && $0.path == ["b"]
      }))
      XCTAssertFalse(result.stateMappings.contains(where: {
        ($0.scope == .normalShared || $0.scope == .normalOverride) && $0.actionType == "group"
      }))

      let globalStateId = try XCTUnwrap(result.stateMappings.first(where: {
        $0.scope == .global && $0.path == ["x"]
      })?.stateId)
      let normalStateId = try XCTUnwrap(result.stateMappings.first(where: {
        $0.scope == .normalShared && $0.path == ["g", "x"]
      })?.stateId)
      XCTAssertNotEqual(globalStateId, normalStateId)
    }
  }

  func testNormalModeAfterAndEscapeCascadeExport() throws {
    let normalFallbackRoot = Group(
      key: nil,
      label: "Normal",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .action(makeCommandAction(key: "i", label: "After Input", value: "echo input", normalModeAfter: .input)),
        .action(makeCommandAction(key: "d", label: "After Disabled", value: "echo disabled", normalModeAfter: .disabled)),
        .action(makeCommandAction(key: "escape", label: "Reserved Escape", value: "echo should-not-export")),
      ]
    )

    try withTemporaryConfigDirectory(normalFallbackRoot: normalFallbackRoot) {
      let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: UserConfig(), appConfigs: [])
      let allManipulators = flattenManipulators(from: result.managedRules)

      let inputMapping = try XCTUnwrap(allManipulators.first(where: {
        fromKeyCode(in: $0) == "i" && hasSendUserCommand(manipulator: $0, prefix: "stateid ")
      }))
      XCTAssertTrue(hasSetVariable(manipulator: inputMapping, name: "leaderkey_normal_input", value: 1))
      XCTAssertTrue(hasSendUserCommand(manipulator: inputMapping, prefix: "normal_input"))

      let disabledMapping = try XCTUnwrap(allManipulators.first(where: {
        fromKeyCode(in: $0) == "d" && hasSendUserCommand(manipulator: $0, prefix: "stateid ")
      }))
      XCTAssertTrue(hasSetVariable(manipulator: disabledMapping, name: "leaderkey_normal_enabled", value: 0))
      XCTAssertTrue(hasSendUserCommand(manipulator: disabledMapping, prefix: "normal_off"))

      let escapeStateIdMappings = allManipulators.filter {
        fromKeyCode(in: $0) == "escape" && hasSendUserCommand(manipulator: $0, prefix: "stateid ")
      }
      XCTAssertTrue(escapeStateIdMappings.isEmpty)

      let escapeResetMapping = try XCTUnwrap(allManipulators.first(where: {
        fromKeyCode(in: $0) == "escape"
          && hasVariableCondition($0, name: "leaderkey_normal_state", value: 0, type: "variable_unless")
      }))
      XCTAssertTrue(hasSetVariable(manipulator: escapeResetMapping, name: "leaderkey_normal_state", value: 0))
      XCTAssertFalse(hasSetVariable(manipulator: escapeResetMapping, name: "leaderkey_normal_enabled", value: 0))

      let escapeDisableMapping = try XCTUnwrap(allManipulators.first(where: {
        fromKeyCode(in: $0) == "escape"
          && hasVariableCondition($0, name: "leaderkey_normal_state", value: 0, type: "variable_if")
          && hasSendUserCommand(manipulator: $0, prefix: "normal_off")
      }))
      XCTAssertTrue(hasSetVariable(manipulator: escapeDisableMapping, name: "leaderkey_normal_enabled", value: 0))
      XCTAssertTrue(hasVariableCondition(escapeDisableMapping, name: "leaderkey_normal_input", value: 1, type: "variable_unless"))
    }
  }

  func testNormalModeLayerExportsHoldVariablesTapActionChildrenAndEscapeReset() throws {
    let tapAction = Action(
      key: nil,
      type: .shortcut,
      label: "Tap Find",
      value: "Cf",
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil,
      normalModeAfter: .normal
    )
    let normalFallbackRoot = Group(
      key: nil,
      label: "Normal",
      iconPath: nil,
      stickyMode: nil,
      actions: [
        .layer(
          Layer(
            key: "f",
            label: "Find",
            iconPath: nil,
            tapAction: tapAction,
            actions: [
              .action(makeShortcutAction(key: "b", label: "Back", value: "Cb")),
              .group(
                Group(
                  key: "g",
                  label: "Group",
                  iconPath: nil,
                  stickyMode: nil,
                  actions: [.action(makeCommandAction(key: "x", label: "Nested", value: "echo nested"))]
                )
              ),
            ]
          )
        ),
        .layer(
          Layer(
            key: "h",
            label: "Plain",
            iconPath: nil,
            tapAction: nil,
            actions: [.action(makeShortcutAction(key: "j", label: "Jump", value: "Cj"))]
          )
        ),
      ]
    )

    try withTemporaryConfigDirectory(normalFallbackRoot: normalFallbackRoot) {
      let result = try Karabiner2Exporter.generateKarabinerTSExport(globalConfig: UserConfig(), appConfigs: [])
      let normalFallbackRule = try XCTUnwrap(
        result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/NormalFallbackMode" })
      )
      let normalFallbackManipulators = flattenManipulators(from: [normalFallbackRule])
      let trigger = try XCTUnwrap(normalFallbackManipulators.first(where: { fromKeyCode(in: $0) == "f" }))

      XCTAssertTrue(hasVariableCondition(trigger, name: "leaderkey_normal_layer_state", value: 0, type: "variable_if"))
      XCTAssertTrue(hasSetVariableNamed(trigger, name: "leaderkey_normal_layer_state"))
      XCTAssertTrue(hasSetVariable(manipulator: trigger, name: "leaderkey_normal_layer_sequence_state", value: 0))
      XCTAssertTrue(
        toAfterKeyUpEvents(in: trigger).contains(where: {
          eventHasSetVariable($0, name: "leaderkey_normal_layer_state", value: 0)
        })
      )
      XCTAssertTrue(
        toAfterKeyUpEvents(in: trigger).contains(where: {
          eventHasSetVariable($0, name: "leaderkey_normal_layer_sequence_state", value: 0)
        })
      )
      XCTAssertTrue(
        toIfAloneEvents(in: trigger).contains(where: {
          eventHasSendUserCommand($0, prefix: "stateid ")
        })
      )

      let noTapTrigger = try XCTUnwrap(normalFallbackManipulators.first(where: { fromKeyCode(in: $0) == "h" }))
      XCTAssertTrue(toIfAloneEvents(in: noTapTrigger).contains(where: { eventHasKeyCode($0, keyCode: "h") }))

      let childAction = try XCTUnwrap(normalFallbackManipulators.first(where: {
        fromKeyCode(in: $0) == "b"
          && hasCondition($0, name: "leaderkey_normal_layer_state", type: "variable_if")
      }))
      XCTAssertTrue(hasSendUserCommand(manipulator: childAction, prefix: "stateid "))
      XCTAssertTrue(hasSetVariable(manipulator: childAction, name: "leaderkey_normal_layer_sequence_state", value: 0))

      let childGroup = try XCTUnwrap(normalFallbackManipulators.first(where: {
        fromKeyCode(in: $0) == "g"
          && hasCondition($0, name: "leaderkey_normal_layer_state", type: "variable_if")
      }))
      XCTAssertTrue(hasSetVariableNamed(childGroup, name: "leaderkey_normal_layer_sequence_state"))
      XCTAssertFalse(hasSetVariableNamed(childGroup, name: "leaderkey_normal_state"))
      XCTAssertFalse(hasSendUserCommand(manipulator: childGroup, prefix: "stateid "))

      XCTAssertTrue(result.stateMappings.contains(where: {
        $0.scope == .normalShared && $0.path == ["f", "b"]
      }))
      XCTAssertTrue(result.stateMappings.contains(where: {
        $0.scope == .normalShared && $0.path == ["f", "g", "x"]
      }))

      let controlsRule = try XCTUnwrap(
        result.managedRules.first(where: { ($0["description"] as? String) == "LeaderKeyManaged/NormalControls" })
      )
      let layerEscape = try XCTUnwrap(flattenManipulators(from: [controlsRule]).first(where: {
        fromKeyCode(in: $0) == "escape"
          && hasCondition($0, name: "leaderkey_normal_layer_state", type: "variable_unless")
          && hasCondition($0, name: "leaderkey_normal_layer_sequence_state", type: "variable_unless")
      }))
      XCTAssertTrue(hasSetVariable(manipulator: layerEscape, name: "leaderkey_normal_layer_sequence_state", value: 0))
      XCTAssertFalse(hasSetVariable(manipulator: layerEscape, name: "leaderkey_normal_enabled", value: 0))
    }
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

  private func makeCommandAction(
    key: String,
    label: String,
    value: String,
    normalModeAfter: NormalModeAfter? = nil
  ) -> Action {
    Action(
      key: key,
      type: .command,
      label: label,
      value: value,
      iconPath: nil,
      activates: nil,
      stickyMode: nil,
      macroSteps: nil,
      normalModeAfter: normalModeAfter
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
    normalFallbackRoot: Group? = nil,
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

    if let normalFallbackRoot {
      let normalFallbackPath = tempDirectory.appendingPathComponent("normal-fallback-config.json")
      let data = try JSONEncoder().encode(normalFallbackRoot)
      try data.write(to: normalFallbackPath, options: .atomic)
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
      payloads.append(contentsOf: sendUserCommandPayloads(manipulator: manipulator))
    }

    return payloads
  }

  private func sendUserCommandPayloads(manipulator: [String: Any]) -> [String] {
    let events = (manipulator["to"] as? [Any]) ?? []
    return events.compactMap { event in
      guard
        let eventObject = event as? [String: Any],
        let commandObject = eventObject["send_user_command"] as? [String: Any],
        let payload = commandObject["payload"] as? String
      else {
        return nil
      }

      return payload
    }
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

  private func toEvents(in manipulator: [String: Any]) -> [Any] {
    (manipulator["to"] as? [Any]) ?? []
  }

  private func toIfAloneEvents(in manipulator: [String: Any]) -> [Any] {
    (manipulator["to_if_alone"] as? [Any]) ?? []
  }

  private func toAfterKeyUpEvents(in manipulator: [String: Any]) -> [Any] {
    (manipulator["to_after_key_up"] as? [Any]) ?? []
  }

  private func eventHasKeyCode(_ event: Any, keyCode: String) -> Bool {
    guard let eventObject = event as? [String: Any] else {
      return false
    }
    return eventObject["key_code"] as? String == keyCode
  }

  private func eventHasSendUserCommand(_ event: Any, prefix: String) -> Bool {
    guard
      let eventObject = event as? [String: Any],
      let commandObject = eventObject["send_user_command"] as? [String: Any],
      let payload = commandObject["payload"] as? String
    else {
      return false
    }

    return payload.hasPrefix(prefix)
  }

  private func eventHasSetVariable(_ event: Any, name: String, value: Int) -> Bool {
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

  private func indexOfSetVariableEvent(_ events: [Any], name: String, value: Int) -> Int? {
    events.firstIndex { event in
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

  private func indexOfKeyCodeEvent(_ events: [Any], keyCode: String) -> Int? {
    events.firstIndex { event in
      guard let eventObject = event as? [String: Any] else {
        return false
      }
      return eventObject["key_code"] as? String == keyCode
    }
  }

  private func lastKeyCodeEvent(in manipulator: [String: Any]) -> [String: Any]? {
    toEvents(in: manipulator).last as? [String: Any]
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

  private func hasSetVariableNamed(_ manipulator: [String: Any], name: String) -> Bool {
    let events = (manipulator["to"] as? [Any]) ?? []
    return events.contains { event in
      guard
        let eventObject = event as? [String: Any],
        let variableObject = eventObject["set_variable"] as? [String: Any],
        let variableName = variableObject["name"] as? String
      else {
        return false
      }

      return variableName == name
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
