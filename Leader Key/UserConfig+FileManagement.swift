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

            // 3. Handle global-config.json migration
            let oldGlobalConfigPath = (defaultProfileDir as NSString).appendingPathComponent("global-config.json")
            let newFallbackConfigPath = (defaultProfileDir as NSString).appendingPathComponent(defaultAppConfigFileName)
            if fileManager.fileExists(atPath: oldGlobalConfigPath) {
                if fileManager.fileExists(atPath: newFallbackConfigPath) {
                    // If app-fallback-config.json already exists, back up global-config.json and then remove it
                    let backupPath = (defaultProfileDir as NSString).appendingPathComponent("global-config.json.backup")
                    try fileManager.moveItem(atPath: oldGlobalConfigPath, toPath: backupPath)
                } else {
                    // Otherwise, rename global-config.json to app-fallback-config.json
                    try fileManager.moveItem(atPath: oldGlobalConfigPath, toPath: newFallbackConfigPath)
                }
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

    internal func ensureDefaultAppConfigExists(for profileName: String) {
        let defaultAppConfigPath = (profilesDirectory as NSString).appendingPathComponent("\(profileName)/\(defaultAppConfigFileName)")
        guard !fileManager.fileExists(atPath: defaultAppConfigPath) else { return }

        do {
            try bootstrapDefaultAppConfig(for: profileName)
        } catch {
            handleError(error, critical: false)  // Non-critical since it's a fallback config
        }
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

    func createAppConfig(for bundleId: String, in profileName: String, customName: String?, isOverlay: Bool) {
        let profileDir = (profilesDirectory as NSString).appendingPathComponent(profileName)
        let suffix = isOverlay ? ".overlay.json" : ".json"
        let fileName = "app.\(bundleId)\(suffix)"
        let filePath = (profileDir as NSString).appendingPathComponent(fileName)

        if fileManager.fileExists(atPath: filePath) {
            alertHandler.showAlert(
                style: .warning,
                message: "A configuration file for this application already exists in this profile."
            )
            return
        }

        do {
            let emptyConfig = Group(key: nil, label: nil, actions: [])
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(emptyConfig)
            try data.write(to: URL(fileURLWithPath: filePath))

            if let customName = customName, !customName.isEmpty {
                // We would need a way to store custom names per profile.
                // This is not implemented yet.
            }

            reload(for: profileName)
        } catch {
            alertHandler.showAlert(
                style: .critical,
                message: "Failed to create application-specific configuration file: \(error.localizedDescription)"
            )
        }
    }
}
