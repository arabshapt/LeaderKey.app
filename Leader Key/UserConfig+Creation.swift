import Cocoa
import Defaults
import Foundation

// MARK: - Creating new configuration files
extension UserConfig {
    /// Creates a new configuration file for a given bundle identifier.
    /// - Parameters:
    ///   - bundleId: The application bundle identifier.
    ///   - templateKey: Optional display key whose JSON will be duplicated. When `nil` the global default config is used.
    ///   - customName: Optional custom sidebar name that will override the default "App: <bundleId>" display name.
    ///   - isOverlay: Whether this is an overlay configuration (adds .overlay suffix to filename).
    /// - Returns: The sidebar display name that was ultimately inserted, or `nil` if the creation failed.
    @discardableResult
    func createConfigForApp(
        bundleId: String,
        templateKey: String? = nil,
        customName: String? = nil,
        isOverlay: Bool = false
    ) -> String? {
        let trimmedId = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty else {
            alertHandler.showAlert(style: .warning, message: "Bundle identifier cannot be empty.")
            return nil
        }

        // Destination path  e.g.  app.<bundleId>.json or app.<bundleId>.overlay.json
        let destFileName: String
        if isOverlay {
            destFileName = "\(appConfigPrefix)\(trimmedId).overlay.json"
        } else {
            destFileName = "\(appConfigPrefix)\(trimmedId).json"
        }
        let destPath = (Defaults[.configDir] as NSString).appendingPathComponent(destFileName)

        if fileManager.fileExists(atPath: destPath) {
            let configType = isOverlay ? "overlay configuration" : "configuration"
            alertHandler.showAlert(style: .warning, message: "An \(configType) for '\(trimmedId)' already exists.")
            return nil
        }

        // Determine the source Group to duplicate
        var sourceGroup: Group = self.root // Default template
        if let key = templateKey {
            if key == "EMPTY_TEMPLATE" {
                // Create an empty group with no actions
                sourceGroup = Group(actions: [])
            } else if let srcPath = discoveredConfigFiles[key] {
                if let dupGroup = decodeConfig(from: srcPath, suppressAlerts: true, isDefaultConfig: false) {
                    sourceGroup = dupGroup
                }
            }
        }

        // Encode the group as pretty-printed JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            let data = try encoder.encode(sourceGroup)
            try data.write(to: URL(fileURLWithPath: destPath))
        } catch {
            handleError(error, critical: true)
            return nil
        }

        // Persist custom sidebar name if provided
        if let name = customName, !name.isEmpty {
            var names = Defaults[.configFileCustomNames]
            names[destPath] = name
            Defaults[.configFileCustomNames] = names
        }

        // Refresh discovery & select the new config
        self.reloadConfig()

        // Calculate the final display key (may include custom name)
        let defaultDisplay: String
        if isOverlay {
            defaultDisplay = "App: \(trimmedId) (Overlay)"
        } else {
            defaultDisplay = "App: \(trimmedId)"
        }

        let finalDisplayName: String
        if let custom = customName, !custom.isEmpty {
            finalDisplayName = custom
        } else {
            finalDisplayName = defaultDisplay
        }

        DispatchQueue.main.async {
            self.selectedConfigKeyForEditing = finalDisplayName
        }

        return finalDisplayName
    }
}
