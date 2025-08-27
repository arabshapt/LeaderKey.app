import Foundation

/// Utility for interacting with Karabiner Elements CLI
struct KarabinerCLI {
    private static let cliPath = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
    
    /// Set the leaderkey_active variable in Karabiner Elements
    /// - Parameter active: true to activate LeaderKey mode, false to deactivate
    static func setLeaderKeyActive(_ active: Bool) {
        guard isKarabinerInstalled() else {
            debugLog("[KarabinerCLI] Karabiner CLI not found, skipping variable set")
            return
        }
        
        let value = active ? 1 : 0
        let jsonString = "{\"leaderkey_active\": \(value)}"
        
        // Use async execution to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: cliPath)
            task.arguments = ["--set-variables", jsonString]
            
            // Capture output for debugging
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            do {
                try task.run()
                task.waitUntilExit()
                
                if task.terminationStatus == 0 {
                    debugLog("[KarabinerCLI] Successfully set leaderkey_active to \(value)")
                } else {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? "Unknown error"
                    debugLog("[KarabinerCLI] Failed to set variable, exit code: \(task.terminationStatus), output: \(output)")
                }
            } catch {
                debugLog("[KarabinerCLI] Error executing karabiner_cli: \(error.localizedDescription)")
            }
        }
    }
    
    /// Check if Karabiner Elements CLI is installed
    /// - Returns: true if the CLI exists and is executable
    static func isKarabinerInstalled() -> Bool {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        guard fileManager.fileExists(atPath: cliPath, isDirectory: &isDirectory) else {
            return false
        }
        
        // Check if it's not a directory and is executable
        return !isDirectory.boolValue && fileManager.isExecutableFile(atPath: cliPath)
    }
    
    /// Get the current status of the leaderkey_active variable (for debugging/testing)
    /// Note: This is mainly for debugging purposes as Karabiner doesn't provide a direct way to read variables
    static func getInstallationInfo() -> String {
        if isKarabinerInstalled() {
            return "Karabiner Elements CLI is installed and accessible at: \(cliPath)"
        } else {
            return "Karabiner Elements CLI not found at: \(cliPath)"
        }
    }
    
    /// Immediately deactivate LeaderKey mode in Karabiner (convenience method)
    static func deactivateLeaderKey() {
        setLeaderKeyActive(false)
    }
    
    /// Activate LeaderKey mode in Karabiner (convenience method)
    /// Note: In normal flow, activation is handled by Karabiner rules, not directly by LeaderKey
    static func activateLeaderKey() {
        setLeaderKeyActive(true)
    }
}