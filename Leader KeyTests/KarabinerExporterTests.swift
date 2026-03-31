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
        
        // Verify URL action (Foreground)
        XCTAssertTrue(edn.contains("open 'https://example.com'"), "EDN should contain foreground open command for HTTP URL")
        XCTAssertFalse(edn.contains("open -g 'https://example.com'"), "EDN should NOT contain background flag for HTTP URL")
        
        // Verify Custom URL action (Background)
        XCTAssertTrue(edn.contains("open -g 'raycast://confetti'"), "EDN should contain background open command for custom URL")
        
        // Verify Explicit Background URL action
        XCTAssertTrue(edn.contains("open -g 'https://example.com/bg'"), "EDN should contain background open command for URL with activates=false")
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

        XCTAssertTrue(edn.contains(":type \"keystroke\" :app \"Google Chrome\" :spec \"Ct\""))
        XCTAssertTrue(edn.contains(":type \"keystroke\" :spec \"escape\""))
        XCTAssertTrue(edn.contains(":type \"keystroke\" :app \"Safari\" :focus true :spec \"CSf\""))
    }
}
