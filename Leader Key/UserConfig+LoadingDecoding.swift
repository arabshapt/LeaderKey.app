import Defaults
import Foundation

// MARK: - Config Loading & Decoding
extension UserConfig {

    internal func loadConfig(suppressAlerts: Bool = false) {
        let defaultPath = (Defaults[.configDir] as NSString).appendingPathComponent(fileName)
        // Use decodeConfig, indicating it's the default config
        if let loadedRoot = decodeConfig(from: defaultPath, suppressAlerts: suppressAlerts, isDefaultConfig: true) {
            self.root = loadedRoot
            // Update validationErrors state specifically for the default root
            self.validationErrors = ConfigValidator.validate(group: self.root)
            if !validationErrors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
                showValidationAlert()
            }
        } else {
            // If default config fails to load, reset root to emptyRoot
            self.root = emptyRoot
            self.validationErrors = []
            // Critical error shown by decodeConfig/handleError
        }
    }

    // Gets the config for a specific app bundle ID, falling back to app.default.json, then default config.json
    func getConfig(for bundleId: String?) -> Group {
        // 1. Try specific app config
        if let bundleId = bundleId, !bundleId.isEmpty {
            // Check cache first
            if let cachedConfig = appConfigs[bundleId] {
                return cachedConfig ?? root // Return cached config or default if cache entry is nil (load failed previously)
            }

            // Construct app-specific config path
            let appFileName = "\(appConfigPrefix)\(bundleId).json"
            let appConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(appFileName)

            if fileManager.fileExists(atPath: appConfigPath) {
                // Attempt to load and decode app-specific config
                if let appRoot = decodeConfig(from: appConfigPath, suppressAlerts: true, isDefaultConfig: false) {
                    appConfigs[bundleId] = appRoot // Cache successful load
                    return appRoot
                } else {
                    appConfigs[bundleId] = nil // Cache failed load explicitly as nil
                    // Fall through to try app.default.json
                }
            } else {
                // File doesn't exist, cache this fact by storing nil
                appConfigs[bundleId] = nil
                // Fall through to try app.default.json
            }
        }

        // 2. Try default app config (app.default.json)
        let defaultAppKey = "app.default"
        // Check cache first
        if let cachedDefaultAppConfig = appConfigs[defaultAppKey] {
            return cachedDefaultAppConfig ?? root // Return cached or default if nil
        }

        let defaultAppConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(defaultAppConfigFileName)
        if fileManager.fileExists(atPath: defaultAppConfigPath) {
            // Attempt to load and decode app.default.json
            if let defaultAppRoot = decodeConfig(from: defaultAppConfigPath, suppressAlerts: true, isDefaultConfig: false) {
                appConfigs[defaultAppKey] = defaultAppRoot // Cache successful load
                return defaultAppRoot
            } else {
                appConfigs[defaultAppKey] = nil // Cache failed load as nil
                // Fall through to default config.json
            }
        } else {
            // File doesn't exist, cache this fact
            appConfigs[defaultAppKey] = nil
        }

        // 3. Fallback to default config.json (already loaded into self.root)
        return root
    }

    // Helper to decode a config file from a given path
    // isDefaultConfig flag helps manage validation errors and critical error handling
    internal func decodeConfig(from filePath: String, suppressAlerts: Bool = false, isDefaultConfig: Bool) -> Group? {
        guard fileManager.fileExists(atPath: filePath) else {
            // Only treat missing default config as potentially critical (handled by caller)
            if isDefaultConfig {
                print("Warning: Default config file not found at: \(filePath)")
            } // Don't show error for missing app-specific file here
            return nil
        }

        do {
            let configString = try String(contentsOfFile: filePath, encoding: .utf8)

            guard let jsonData = configString.data(using: .utf8) else {
                throw NSError(
                    domain: "UserConfig",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to encode config file as UTF-8: \(filePath)"
                    ]
                )
            }

            let decoder = JSONDecoder()
            let decodedRoot = try decoder.decode(Group.self, from: jsonData)

            // Perform validation regardless, but only show alerts/update main state for default config
            let errors = ConfigValidator.validate(group: decodedRoot)
            if !errors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
                if isDefaultConfig {
                    // Store errors only if it's the default config being decoded in a context
                    // where we should update the main validationErrors state (e.g., initial load)
                    // This assignment might be redundant if caller updates validationErrors anyway.
                    // validationErrors = errors
                    showValidationAlert() // Show alert only for default config
                } else {
                    // Log validation issues for app-specific configs, but don't trigger primary alert/state
                    print("Validation issues found in app-specific config: \(filePath)")
                }
            }
            return decodedRoot
        } catch {
            // Handle critical errors only for the default config.json
            handleError(error, critical: isDefaultConfig)
            return nil // Return nil on any decoding error
        }
    }

    internal func showValidationAlert() {
        let errorCount = validationErrors.count
        alertHandler.showAlert(
            style: .warning,
            message:
                "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in your default configuration (config.json). Some keys may not work as expected."
        )
    }
} 