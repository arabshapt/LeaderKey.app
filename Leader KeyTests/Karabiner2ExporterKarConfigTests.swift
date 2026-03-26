import XCTest
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
