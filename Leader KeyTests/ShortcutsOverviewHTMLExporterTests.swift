import XCTest

@testable import Leader_Key

final class ShortcutsOverviewHTMLExporterTests: XCTestCase {
  private let generationDate = Date(timeIntervalSince1970: 0)

  func testExportJSONIsDeterministicSortedAndRecursive() throws {
    var inherited = Action(
      key: "n", type: .url, label: "Nested URL", value: "https://example.com/path?a=1&b=2")
    inherited.isFromFallback = true
    inherited.fallbackSource = "Fallback App Config"
    let actions: [ActionOrGroup] = [
      .group(
        Group(
          key: "g", label: "Group",
          actions: [
            .layer(
              Layer(
                key: "l", label: "Layer", tapAction: nil,
                actions: [
                  .action(inherited)
                ]))
          ]))
    ]

    let first = try ShortcutsOverview.exportJSON(
      configName: "Browser",
      actions: actions,
      generationDate: generationDate
    )
    let second = try ShortcutsOverview.exportJSON(
      configName: "Browser",
      actions: actions,
      generationDate: generationDate
    )

    XCTAssertEqual(first, second)
    XCTAssertTrue(String(decoding: first, as: UTF8.self).hasPrefix("{\"configName\""))

    let payload = try JSONDecoder().decode(ShortcutsOverview.ExportPayload.self, from: first)
    XCTAssertEqual(payload.configName, "Browser")
    XCTAssertEqual(payload.generatedAt, "1970-01-01T00:00:00Z")
    XCTAssertEqual(payload.keyboardRows, ShortcutsOverview.keyboardRows)
    XCTAssertEqual(payload.shiftedKeys["1"], "!")
    XCTAssertEqual(payload.nodes[0].key, "g")
    XCTAssertEqual(payload.nodes[0].children[0].key, "l")
    XCTAssertEqual(payload.nodes[0].children[0].children[0].key, "n")
    XCTAssertEqual(
      payload.nodes[0].children[0].children[0].value,
      "https://example.com/path?a=1&b=2"
    )
    XCTAssertTrue(payload.nodes[0].children[0].children[0].isFromFallback)
    XCTAssertEqual(
      payload.nodes[0].children[0].children[0].fallbackSource,
      "Fallback App Config"
    )
  }

  func testExportHTMLEscapesScriptTerminatorAndRoundTripsUserContent() throws {
    let injection = "</script><script>alert('owned')</script>"
    let action = Action(
      key: "x",
      type: .text,
      label: injection,
      value: "before \(injection) after"
    )

    let html = try ShortcutsOverview.exportHTML(
      configName: injection,
      actions: [.action(action)],
      generationDate: generationDate
    )

    XCTAssertFalse(html.contains(injection))
    XCTAssertTrue(html.contains("\\u003C/script\\u003E"))
    XCTAssertFalse(html.contains("innerHTML"))
    XCTAssertFalse(html.contains("insertAdjacentHTML"))
    XCTAssertFalse(html.contains("document.write"))

    let payload = try embeddedPayload(from: html)
    XCTAssertEqual(payload.configName, injection)
    XCTAssertEqual(payload.nodes[0].displayName, injection)
    XCTAssertEqual(payload.nodes[0].value, "before \(injection) after")
  }

  func testExportHTMLIsSelfContainedAndKeepsLegitimateURLValues() throws {
    let url = "https://example.com/a/path?next=https://other.example/path&safe=true"
    let html = try ShortcutsOverview.exportHTML(
      configName: "URLs",
      actions: [
        .action(Action(key: "u", type: .url, label: "Open URL", value: url))
      ],
      generationDate: generationDate
    )

    XCTAssertEqual(try embeddedPayload(from: html).nodes[0].value, url)
    XCTAssertTrue(html.contains("Content-Security-Policy"))
    XCTAssertTrue(html.contains("default-src 'none'"))
    XCTAssertTrue(html.contains("connect-src 'none'"))
    XCTAssertFalse(html.range(of: #"<script[^>]+src\s*="#, options: .regularExpression) != nil)
    XCTAssertFalse(html.range(of: #"<link\b"#, options: .regularExpression) != nil)
    XCTAssertFalse(html.contains("fetch("))
    XCTAssertFalse(html.contains("XMLHttpRequest"))
    XCTAssertFalse(html.contains("@import"))
  }

  func testExportHTMLIsDeterministicForInjectedDate() throws {
    let actions = [
      ActionOrGroup.action(Action(key: "a", type: .command, label: "Alpha", value: "echo a"))
    ]

    XCTAssertEqual(
      try ShortcutsOverview.exportHTML(
        configName: "Deterministic", actions: actions, generationDate: generationDate),
      try ShortcutsOverview.exportHTML(
        configName: "Deterministic", actions: actions, generationDate: generationDate)
    )
  }

  private func embeddedPayload(from html: String) throws -> ShortcutsOverview.ExportPayload {
    let openingMarker =
      #"<script id="shortcut-data" type="application/json" nonce="leaderkey-export">"#
    guard let openingRange = html.range(of: openingMarker),
      let closingRange = html.range(of: "</script>", range: openingRange.upperBound..<html.endIndex)
    else {
      return try XCTUnwrap(nil as ShortcutsOverview.ExportPayload?)
    }
    let json = html[openingRange.upperBound..<closingRange.lowerBound]
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return try JSONDecoder().decode(
      ShortcutsOverview.ExportPayload.self,
      from: try XCTUnwrap(json.data(using: .utf8))
    )
  }
}
