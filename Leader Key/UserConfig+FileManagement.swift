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
            fatalError("Failed to create config directory: \(error)")  // Include error
        }
        return path
    }

    var profilesDirectory: String {
        (Self.defaultDirectory() as NSString).appendingPathComponent("profiles")
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

        // Migrate to profiles structure if needed
        migrateToProfiles()
    }

    private func migrateToProfiles() {
        let configDir = Defaults[.configDir]
        let profilesDir = self.profilesDirectory
        let defaultProfileDir = (profilesDir as NSString).appendingPathComponent("default")

        // If profiles directory already exists, we assume migration is done.
        if fileManager.fileExists(atPath: profilesDir) {
            return
        }

        do {
            // 1. Create profiles and default profile directories
            try fileManager.createDirectory(atPath: defaultProfileDir, withIntermediateDirectories: true)

            // 2. Move all .json files to the default profile directory
            let files = try fileManager.contentsOfDirectory(atPath: configDir)
            for file in files {
                if file.hasSuffix(".json") {
                    let oldPath = (configDir as NSString).appendingPathComponent(file)
                    let newPath = (defaultProfileDir as NSString).appendingPathComponent(file)
                    try fileManager.moveItem(atPath: oldPath, toPath: newPath)
                }
            }

            // 3. Rename global-config.json to config.json
            let oldGlobalConfigPath = (defaultProfileDir as NSString).appendingPathComponent("global-config.json")
            let newGlobalConfigPath = (defaultProfileDir as NSString).appendingPathComponent("config.json")
            if fileManager.fileExists(atPath: oldGlobalConfigPath) {
                try fileManager.moveItem(atPath: oldGlobalConfigPath, toPath: newGlobalConfigPath)
            }

            // 4. Create profiles.json
            let profilesURL = (configDir as NSString).appendingPathComponent("profiles.json")
            let defaultProfile = Profile(name: "default")
            let profiles = [defaultProfile]
            let data = try JSONEncoder().encode(profiles)
            try data.write(to: URL(fileURLWithPath: profilesURL))

        } catch {
            print("Failed to migrate to profiles: \(error)")
        }
    }


    func path(for profileName: String) -> String {
        (profilesDirectory as NSString).appendingPathComponent("\(profileName)/\(fileName)")
    }

    func url(for profileName: String) -> URL {
        URL(fileURLWithPath: path(for: profileName))
    }

    func exists(for profileName: String) -> Bool {
        fileManager.fileExists(atPath: path(for: profileName))
    }

    internal func ensureConfigFileExists(for profileName: String) {
        guard !exists(for: profileName) else { return }

        do {
            try bootstrapConfig(for: profileName)
        } catch {
            handleError(error, critical: true)
        }
    }

    internal func ensureDefaultAppConfigExists(for profileName: String) {
        let defaultAppConfigPath = (profilesDirectory as NSString).appendingPathComponent("\(profileName)/\(defaultAppConfigFileName)")
        guard !fileManager.fileExists(atPath: defaultAppConfigPath) else { return }

        do {
            try bootstrapDefaultAppConfig(for: profileName)
        } catch {
            handleError(error, critical: false)  // Non-critical since it's a fallback config
        }
    }

    private func bootstrapConfig(for profileName: String) throws {
        guard let data = defaultConfig.data(using: .utf8) else {
            throw NSError(
                domain: "UserConfig",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode default config"]
            )
        }
        try writeFile(data: data, for: profileName)
    }

    private func bootstrapDefaultAppConfig(for profileName: String) throws {
        guard let data = defaultConfig.data(using: .utf8) else {
            throw NSError(
                domain: "UserConfig",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode fallback app config"]
            )
        }
        let defaultAppConfigPath = (profilesDirectory as NSString).appendingPathComponent("\(profileName)/\(defaultAppConfigFileName)")
        try data.write(to: URL(fileURLWithPath: defaultAppConfigPath))
    }

    private func writeFile(data: Data, for profileName: String) throws {
        try data.write(to: url(for: profileName))
    }

    private func readFile(for profileName: String) throws -> String {
        try String(contentsOfFile: path(for: profileName), encoding: .utf8)
    }
}
