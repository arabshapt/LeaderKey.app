import Foundation

/// Generates Karabiner Elements configuration for Unix socket integration
struct KarabinerConfig {
    
    /// Configuration for LeaderKey activation
    struct Configuration {
        let activationKey: String
        let activationModifiers: [String]
        let socketPath: String
        let escapeKey: String
        
        static let `default` = Configuration(
            activationKey: "k",
            activationModifiers: ["left_command", "left_shift"],
            socketPath: "/tmp/leaderkey.sock",
            escapeKey: "escape"
        )
    }
    
    /// Generate complete Karabiner configuration JSON
    static func generateConfig(configuration: Configuration = .default) -> String {
        let config = KarabinerComplexModification(
            title: "LeaderKey Integration",
            configuration: configuration
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(config)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            debugLog("[KarabinerConfig] Failed to encode configuration: \(error)")
            return ""
        }
    }
    
    /// Export configuration to file
    static func exportToFile(configuration: Configuration = .default, to url: URL) throws {
        let configString = generateConfig(configuration: configuration)
        try configString.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// Get sample shell script for sending messages to Unix socket
    static func generateSampleScript(socketPath: String = "/tmp/leaderkey.sock") -> String {
        return """
        #!/bin/bash
        
        # LeaderKey Unix Socket Test Script
        # This script demonstrates how to send messages to LeaderKey via Unix socket
        
        SOCKET_PATH="\(socketPath)"
        
        # Function to send JSON message to socket
        send_message() {
            local message="$1"
            local length=$(echo -n "$message" | wc -c)
            
            # Create length prefix (4 bytes, big-endian)
            printf "\\\\%03o\\\\%03o\\\\%03o\\\\%03o" \\
                $(( (length >> 24) & 0xFF )) \\
                $(( (length >> 16) & 0xFF )) \\
                $(( (length >> 8) & 0xFF )) \\
                $(( length & 0xFF )) | nc -U "$SOCKET_PATH"
            
            # Send the message
            echo -n "$message" | nc -U "$SOCKET_PATH"
        }
        
        # Example usage:
        # Activate LeaderKey
        send_message '{"type": "activate"}'
        
        # Send a key press
        send_message '{"type": "keydown", "key": "a", "keyCode": 0, "modifiers": []}'
        
        # Send escape to deactivate
        send_message '{"type": "escape"}'
        """
    }
}

// MARK: - Karabiner Data Structures

private struct KarabinerComplexModification: Codable {
    let title: String
    let rules: [KarabinerRule]
    
    init(title: String, configuration: KarabinerConfig.Configuration) {
        self.title = title
        self.rules = [
            KarabinerRule.createActivationRule(configuration: configuration),
            KarabinerRule.createDeactivationRule(configuration: configuration),
            KarabinerRule.createKeyForwardingRule(configuration: configuration)
        ]
    }
}

private struct KarabinerRule: Codable {
    let description: String
    let manipulators: [KarabinerManipulator]
    
    static func createActivationRule(configuration: KarabinerConfig.Configuration) -> KarabinerRule {
        let shellCommand = "perl -e 'my \\$msg = q[{\"type\":\"activate\"}]; print pack(\"N\", length(\\$msg)), \\$msg' | socat - UNIX-CONNECT:\(configuration.socketPath)"
        return KarabinerRule(
            description: "LeaderKey Activation",
            manipulators: [
                KarabinerManipulator(
                    type: "basic",
                    from: KarabinerFromKey(
                        keyCode: configuration.activationKey,
                        modifiers: KarabinerModifiers(mandatory: configuration.activationModifiers)
                    ),
                    to: [
                        KarabinerToKey(shell: shellCommand),
                        KarabinerToKey(setVariable: KarabinerVariable(name: "leaderkey_active", value: 1))
                    ]
                )
            ]
        )
    }
    
    static func createDeactivationRule(configuration: KarabinerConfig.Configuration) -> KarabinerRule {
        let shellCommand = "perl -e 'my \\$msg = q[{\"type\":\"escape\"}]; print pack(\"N\", length(\\$msg)), \\$msg' | socat - UNIX-CONNECT:\(configuration.socketPath)"
        return KarabinerRule(
            description: "LeaderKey Deactivation",
            manipulators: [
                KarabinerManipulator(
                    type: "basic",
                    from: KarabinerFromKey(keyCode: configuration.escapeKey),
                    to: [
                        KarabinerToKey(shell: shellCommand),
                        KarabinerToKey(setVariable: KarabinerVariable(name: "leaderkey_active", value: 0))
                    ],
                    conditions: [
                        KarabinerCondition(type: "variable_if", name: "leaderkey_active", value: 1)
                    ]
                )
            ]
        )
    }
    
    static func createKeyForwardingRule(configuration: KarabinerConfig.Configuration) -> KarabinerRule {
        // Create rules for all printable keys
        let keys = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                   "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                   "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
                   "space", "tab", "return_or_enter", "delete_or_backspace"]
        
        let manipulators = keys.map { key in
            let json = "{\\\"type\\\":\\\"keydown\\\",\\\"key\\\":\\\"\(key)\\\",\\\"keyCode\\\":0,\\\"modifiers\\\":[]}"
            let shellCommand = "perl -e 'my \\$msg = q[\(json)]; print pack(\"N\", length(\\$msg)), \\$msg' | socat - UNIX-CONNECT:\(configuration.socketPath)"

            return KarabinerManipulator(
                type: "basic",
                from: KarabinerFromKey(keyCode: key),
                to: [
                    KarabinerToKey(shell: shellCommand)
                ],
                conditions: [
                    KarabinerCondition(type: "variable_if", name: "leaderkey_active", value: 1)
                ]
            )
        }
        
        return KarabinerRule(
            description: "LeaderKey Key Forwarding",
            manipulators: manipulators
        )
    }
}

private struct KarabinerManipulator: Codable {
    let type: String
    let from: KarabinerFromKey
    let to: [KarabinerToKey]
    let conditions: [KarabinerCondition]?
    
    init(type: String, from: KarabinerFromKey, to: [KarabinerToKey], conditions: [KarabinerCondition]? = nil) {
        self.type = type
        self.from = from
        self.to = to
        self.conditions = conditions
    }
}

private struct KarabinerFromKey: Codable {
    let keyCode: String
    let modifiers: KarabinerModifiers?
    
    init(keyCode: String, modifiers: KarabinerModifiers? = nil) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case modifiers
    }
}

private struct KarabinerModifiers: Codable {
    let mandatory: [String]?
    let optional: [String]?
    
    init(mandatory: [String]? = nil, optional: [String]? = nil) {
        self.mandatory = mandatory
        self.optional = optional
    }
}

private struct KarabinerToKey: Codable {
    let keyCode: String?
    let modifiers: [String]?
    let shell: String?
    let setVariable: KarabinerVariable?
    
    init(keyCode: String? = nil, modifiers: [String]? = nil, shell: String? = nil, setVariable: KarabinerVariable? = nil) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.shell = shell
        self.setVariable = setVariable
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case modifiers
        case shell = "shell_command"
        case setVariable = "set_variable"
    }
}

private struct KarabinerVariable: Codable {
    let name: String
    let value: Int
}

private struct KarabinerCondition: Codable {
    let type: String
    let name: String
    let value: Int
}