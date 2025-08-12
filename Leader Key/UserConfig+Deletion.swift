import Cocoa
import Defaults
import Foundation

// MARK: - Deleting configuration files
extension UserConfig {
    /// Deletes the configuration represented by the given sidebar display key.
    /// - Returns: true on success, false otherwise.
    @discardableResult
    func deleteConfig(displayKey: String) -> Bool {
        guard let path = discoveredConfigFiles[displayKey] else {
            alertHandler.showAlert(style: .warning, message: "Could not locate file for ‘\(displayKey)’.")
            return false
        }
        // Prevent deleting the main default config
        if displayKey == globalDefaultDisplayName {
            alertHandler.showAlert(style: .warning, message: "The Global Default configuration cannot be deleted.")
            return false
        }
        // Additional protection for fallback app config
        if displayKey == defaultAppConfigDisplayName {
            alertHandler.showAlert(style: .warning, message: "The Fallback App configuration cannot be deleted.")
            return false
        }

        do {
            try fileManager.removeItem(atPath: path)
            
            // Delete metadata file if it exists
            deleteMetadata(for: path)
            
            // Remove custom name entry from Defaults if present (for backward compatibility)
            var names = Defaults[.configFileCustomNames]
            names.removeValue(forKey: path)
            Defaults[.configFileCustomNames] = names
        } catch {
            handleError(error, critical: false)
            return false
        }

        // Reload list and fallback selection
        self.reloadConfig()
        return true
    }
}
