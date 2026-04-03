import XCTest
import KeyboardShortcuts
@testable import Leader_Key

final class Karabiner2ExporterKarConfigTests: XCTestCase {
  func testGenerateKarConfigContainsSendUserCommandRoutes() throws {
    let config = makeSampleConfig()

    let result = Karabiner2Exporter.generateKarConfig(globalConfig: config, appConfigs: [])
    let parsed = try parseConfigTS(result.configTS)

    let payloads = extractSendUserCommandPayloads(from: parsed)

    XCTAssertTrue(payloads.contains("activate"))
    XCTAssertTrue(payloads.contains("deactivate"))
    XCTAssertTrue(payloads.contains("settings"))
    XCTAssertTrue(payloads.contains(where: { $0.hasPrefix("stateid ") }))
    XCTAssertTrue(payloads.contains("shake"))
  }

  func testGenerateKarConfigPreservesStickyAndResetBehavior() throws {
    let config = makeSampleConfig()
    let result = Karabiner2Exporter.generateKarConfig(globalConfig: config, appConfigs: [])
    let parsed = try parseConfigTS(result.configTS)

    let rules = try XCTUnwrap(parsed["rules"] as? [[String: Any]])
    let allMappings = rules.flatMap { ($0["mappings"] as? [[String: Any]]) ?? [] }

    let stickyTransition = allMappings.first(where: { mapping in
      fromKeyCode(in: mapping) == "g"
        && hasSendUserCommand(mapping: mapping, prefix: "stateid ")
        && hasSetVariable(mapping: mapping, name: "leaderkey_sticky", value: 1)
    })
    XCTAssertNotNil(stickyTransition)

    let nonStickyTerminal = allMappings.first(where: { mapping in
      fromKeyCode(in: mapping) == "x"
        && hasSendUserCommand(mapping: mapping, prefix: "deactivate")
        && hasSetVariable(mapping: mapping, name: "leader_state", value: 0)
    })
    XCTAssertNotNil(nonStickyTerminal)
  }

  func testStateMappingsAreDeterministic() throws {
    let config = makeSampleConfig()

    let first = Karabiner2Exporter.generateKarConfig(globalConfig: config, appConfigs: [])
    let second = Karabiner2Exporter.generateKarConfig(globalConfig: config, appConfigs: [])

    let encoder = JSONEncoder()
    XCTAssertEqual(try encoder.encode(first.stateMappings), try encoder.encode(second.stateMappings))
  }

  func testGenerateKarConfigEncodesKeystrokePayloadsAndStickyBehavior() throws {
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

    let result = Karabiner2Exporter.generateKarConfig(globalConfig: config, appConfigs: [])
    let parsed = try parseConfigTS(result.configTS)

    let rules = try XCTUnwrap(parsed["rules"] as? [[String: Any]])
    let allMappings = rules.flatMap { ($0["mappings"] as? [[String: Any]]) ?? [] }

    let targetedMapping = try XCTUnwrap(allMappings.first(where: { mapping in
      fromKeyCode(in: mapping) == "k"
        && structuredPayloads(mapping: mapping).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "Ct"
        })
    }))
    let targetedPayload = try XCTUnwrap(
      structuredPayloads(mapping: targetedMapping).first(where: {
        ($0["type"] as? String) == "keystroke"
      }))
    XCTAssertEqual(targetedPayload["v"] as? Int, 1)
    XCTAssertEqual(targetedPayload["app"] as? String, "Google Chrome")
    XCTAssertEqual(targetedPayload["spec"] as? String, "Ct")
    XCTAssertNil(targetedPayload["focus"])
    XCTAssertTrue(hasSendUserCommand(mapping: targetedMapping, prefix: "deactivate"))
    XCTAssertTrue(hasSetVariable(mapping: targetedMapping, name: "leader_state", value: 0))

    let focusedMapping = try XCTUnwrap(allMappings.first(where: { mapping in
      fromKeyCode(in: mapping) == "f"
        && structuredPayloads(mapping: mapping).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "CSf"
        })
    }))
    let focusedPayload = try XCTUnwrap(
      structuredPayloads(mapping: focusedMapping).first(where: {
        ($0["type"] as? String) == "keystroke"
      }))
    XCTAssertEqual(focusedPayload["v"] as? Int, 1)
    XCTAssertEqual(focusedPayload["app"] as? String, "Safari")
    XCTAssertEqual(focusedPayload["spec"] as? String, "CSf")
    XCTAssertEqual(focusedPayload["focus"] as? Bool, true)

    let stickyMapping = try XCTUnwrap(allMappings.first(where: { mapping in
      fromKeyCode(in: mapping) == "s"
        && structuredPayloads(mapping: mapping).contains(where: {
          ($0["type"] as? String) == "keystroke" && ($0["spec"] as? String) == "escape"
        })
    }))
    let stickyPayload = try XCTUnwrap(
      structuredPayloads(mapping: stickyMapping).first(where: {
        ($0["type"] as? String) == "keystroke"
      }))
    XCTAssertEqual(stickyPayload["v"] as? Int, 1)
    XCTAssertNil(stickyPayload["app"])
    XCTAssertEqual(stickyPayload["spec"] as? String, "escape")
    XCTAssertTrue(hasSetVariable(mapping: stickyMapping, name: "leaderkey_sticky", value: 1))
    XCTAssertFalse(hasSendUserCommand(mapping: stickyMapping, prefix: "deactivate"))
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

  private func parseConfigTS(_ configTS: String) throws -> [String: Any] {
    let prefix = "export default "
    XCTAssertTrue(configTS.hasPrefix(prefix))

    let jsonPart = String(configTS.dropFirst(prefix.count))
    let data = Data(jsonPart.utf8)

    return try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
  }

  private func extractSendUserCommandPayloads(from parsedConfig: [String: Any]) -> [String] {
    let rules = (parsedConfig["rules"] as? [[String: Any]]) ?? []
    var payloads: [String] = []

    for rule in rules {
      for mapping in (rule["mappings"] as? [[String: Any]]) ?? [] {
        for event in (mapping["to"] as? [Any]) ?? [] {
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
    }

    return payloads
  }

  private func structuredPayloads(mapping: [String: Any]) -> [[String: Any]] {
    let events = (mapping["to"] as? [Any]) ?? []
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

  private func fromKeyCode(in mapping: [String: Any]) -> String? {
    if let from = mapping["from"] as? String {
      return from
    }
    if let from = mapping["from"] as? [String: Any] {
      return from["key"] as? String
    }
    return nil
  }

  private func hasSendUserCommand(mapping: [String: Any], prefix: String) -> Bool {
    let events = (mapping["to"] as? [Any]) ?? []
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

  private func hasSetVariable(mapping: [String: Any], name: String, value: Int) -> Bool {
    let events = (mapping["to"] as? [Any]) ?? []
    return events.contains { event in
      guard
        let eventObject = event as? [String: Any],
        let variableObject = eventObject["set_variable"] as? [String: Any],
        let variableName = variableObject["name"] as? String,
        let variableValue = variableObject["value"] as? Int
      else {
        return false
      }

      return variableName == name && variableValue == value
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

    XCTAssertTrue(specificRules.contains("[:semicolon"))
    XCTAssertTrue(specificRules.contains("[:right_command"))
    XCTAssertTrue(specificRules.contains("{:send_user_command \"activate com.raycast.macos\"}"))
    XCTAssertTrue(specificRules.contains(":raycast"))
    XCTAssertTrue(specificRules.contains("{:send_user_command \"activate\"}"))
    XCTAssertTrue(specificRules.contains("{:send_user_command \"activate __FALLBACK__\"}"))
    XCTAssertTrue(specificRules.contains("[:escape"))
    XCTAssertTrue(specificRules.contains("{:send_user_command \"deactivate\"}"))
    XCTAssertTrue(specificRules.contains("{:key :comma :modi :command}"))
    XCTAssertTrue(specificRules.contains("{:send_user_command \"settings\"}"))
    XCTAssertFalse(specificRules.contains(":f10"))
    XCTAssertFalse(specificRules.contains(":f11"))
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
      specificRules.range(of: "{:send_user_command \"activate com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm\"}")
    )
    let shortChromeRange = try XCTUnwrap(
      specificRules.range(of: "{:send_user_command \"activate com.google.Chrome\"}")
    )
    let aaaRange = try XCTUnwrap(
      specificRules.range(of: "{:send_user_command \"activate com.test.aaa\"}")
    )
    let bbbRange = try XCTUnwrap(
      specificRules.range(of: "{:send_user_command \"activate com.test.bbb\"}")
    )

    XCTAssertLessThan(longChromeRange.lowerBound, shortChromeRange.lowerBound)
    XCTAssertLessThan(aaaRange.lowerBound, bbbRange.lowerBound)
  }

  func testGenerateCanonicalSpecificConfigRulesAppendsTerminalRulesInFixedOrder() throws {
    let specificRules = Karabiner2Exporter.generateCanonicalSpecificConfigRules(
      appConfigs: [(bundleId: "com.raycast.macos", config: UserConfig(), customName: "Raycast")]
    )

    let raycastRange = try XCTUnwrap(
      specificRules.range(of: "{:send_user_command \"activate com.raycast.macos\"}")
    )
    let globalRange = try XCTUnwrap(
      specificRules.range(of: "[:right_command [[\"leaderkey_active\" 1]")
    )
    let fallbackRange = try XCTUnwrap(
      specificRules.range(of: "{:send_user_command \"activate __FALLBACK__\"}")
    )
    let escapeRange = try XCTUnwrap(
      specificRules.range(of: "[:escape [[\"leaderkey_active\" 0]")
    )
    let settingsRange = try XCTUnwrap(
      specificRules.range(of: "[{:key :comma :modi :command} [[\"leaderkey_active\" 0]")
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
         [:semicolon [{:send_user_command "activate com.raycast.macos"}] :raycast]
         [:right_command [{:send_user_command "activate"}]]
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
      specificConfigRules: "   [:escape [{:send_user_command \"deactivate\"}] :leaderkey_active]"
    )

    guard case .success = injection.result else {
      return XCTFail("Expected injection to succeed, got \(injection.result)")
    }

    let updatedContent = try XCTUnwrap(injection.updatedContent)
    XCTAssertTrue(updatedContent.contains("[:escape"))
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
      specificConfigRules: "   [:escape [{:send_user_command \"deactivate\"}] :leaderkey_active]"
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
