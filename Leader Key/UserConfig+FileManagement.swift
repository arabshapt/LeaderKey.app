import Cocoa
import Defaults
import Foundation

// MARK: - Directory Management & File Operations
extension UserConfig {

    static func defaultDirectory() -> String {
        let appSupportDir = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let path = (appSupportDir.path as NSString).appendingPathComponent(
            "Leader Key")
        do {
            try FileManager.default.createDirectory(
                atPath: path, withIntermediateDirectories: true)
        } catch {
            fatalError("Failed to create config directory: \(error)") // Include error
        }
        return path
    }

    internal func ensureValidConfigDirectory() {
        let dir = Defaults[.configDir]
        let defaultDir = Self.defaultDirectory()

        if !fileManager.fileExists(atPath: dir) {
            alertHandler.showAlert(
                style: .warning,
                message:
                    "Config directory does not exist: \(dir)\nResetting to default location."
            )
            Defaults[.configDir] = defaultDir
        }
    }

    var path: String {
        (Defaults[.configDir] as NSString).appendingPathComponent(fileName)
    }

    var url: URL {
        URL(fileURLWithPath: path)
    }

    var exists: Bool {
        fileManager.fileExists(atPath: path)
    }

    internal func ensureConfigFileExists() {
        guard !exists else { return }

        do {
            try bootstrapConfig()
        } catch {
            handleError(error, critical: true)
        }
    }

    private func bootstrapConfig() throws {
        guard let data = defaultConfig.data(using: .utf8) else {
            throw NSError(
                domain: "UserConfig",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode default config"]
            )
        }
        try writeFile(data: data)
    }

    private func writeFile(data: Data) throws {
        try data.write(to: url)
    }

    private func readFile() throws -> String {
        try String(contentsOfFile: path, encoding: .utf8)
    }
} 