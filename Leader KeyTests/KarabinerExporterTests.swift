import XCTest
@testable import Leader_Key

class KarabinerExporterTests: XCTestCase {
    
    func testGenerateGokuEDNWithDirectExecution() {
        // Setup
        let config = UserConfig()
        
        // Create a URL action (http -> foreground)
        let urlAction = Action(
            key: "u",
            type: .url,
            label: "Open URL",
            value: "https://example.com",
            iconPath: nil,
            activates: nil, // Default for http/s is foreground
            stickyMode: false,
            macroSteps: nil
        )
        
        // Create a URL action (custom scheme -> background)
        let customUrlAction = Action(
            key: "c",
            type: .url,
            label: "Open Custom URL",
            value: "raycast://confetti",
            iconPath: nil,
            activates: nil, // Default for custom scheme is background
            stickyMode: false,
            macroSteps: nil
        )
        
        // Create a URL action with explicit background
        let explicitBackgroundUrlAction = Action(
            key: "b",
            type: .url,
            label: "Open Background URL",
            value: "https://example.com/bg",
            iconPath: nil,
            activates: false, // Explicit background
            stickyMode: false,
            macroSteps: nil
        )
        
        // Add actions to root
        config.root.actions = [
            .action(urlAction),
            .action(customUrlAction),
            .action(explicitBackgroundUrlAction)
        ]
        
        // Generate EDN
        let edn = Karabiner2Exporter.generateGokuEDN(from: config)
        
        // Verify URL action payloads
        XCTAssertTrue(edn.contains(":type :open"))
        XCTAssertTrue(edn.contains(":target \"https://example.com\""))
        XCTAssertTrue(edn.contains(":background false"))

        XCTAssertTrue(edn.contains(":target \"raycast://confetti\""))
        XCTAssertTrue(edn.contains(":background true"))

        XCTAssertTrue(edn.contains(":target \"https://example.com/bg\""))
    }

    func testGenerateGokuEDNIncludesKeystrokePayloads() {
        let config = UserConfig()

        let targetedKeystroke = Action(
            key: "k",
            type: .keystroke,
            label: "Targeted Keystroke",
            value: "Google Chrome > Ct",
            iconPath: nil,
            activates: nil,
            stickyMode: false,
            macroSteps: nil
        )

        let systemWideKeystroke = Action(
            key: "s",
            type: .keystroke,
            label: "System Keystroke",
            value: "escape",
            iconPath: nil,
            activates: nil,
            stickyMode: true,
            macroSteps: nil
        )

        let focusedKeystroke = Action(
            key: "f",
            type: .keystroke,
            label: "Focused Keystroke",
            value: "Safari > [focus] > CSf",
            iconPath: nil,
            activates: nil,
            stickyMode: false,
            macroSteps: nil
        )

        config.root.actions = [
            .action(targetedKeystroke),
            .action(systemWideKeystroke),
            .action(focusedKeystroke)
        ]

        let edn = Karabiner2Exporter.generateGokuEDN(from: config)

        XCTAssertTrue(edn.contains(":type :keystroke"))
        XCTAssertTrue(edn.contains(":app \"Google Chrome\""))
        XCTAssertTrue(edn.contains(":spec \"Ct\""))
        XCTAssertTrue(edn.contains(":spec \"escape\""))
        XCTAssertTrue(edn.contains(":app \"Safari\""))
        XCTAssertTrue(edn.contains(":focus true"))
        XCTAssertTrue(edn.contains(":spec \"CSf\""))
    }
}
