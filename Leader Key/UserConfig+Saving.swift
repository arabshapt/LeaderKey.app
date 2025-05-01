import Cocoa
import Defaults
import Foundation

// MARK: - Saving Configuration
extension UserConfig {

    // Saves the configuration currently being edited in the Settings window
    func saveCurrentlyEditingConfig() {
        guard let filePath = discoveredConfigFiles[selectedConfigKeyForEditing] else {
            let errorDesc = "Could not find file path for selected config key: \(selectedConfigKeyForEditing)"
            handleError(NSError(domain: "UserConfig", code: 3, userInfo: [NSLocalizedDescriptionKey: errorDesc]), critical: true)
            return
        }

        // Validate the group being saved
        let errors = ConfigValidator.validate(group: currentlyEditingGroup)
        if !errors.isEmpty {
            // We might want a specific alert here, distinct from the default config validation alert
            let errorCount = errors.count
            let errorMsg = "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") "
                         + "in the '\(selectedConfigKeyForEditing)' configuration. "
                         + "It will still be saved, but some keys may not work as expected."
            alertHandler.showAlert(
                style: .warning,
                message: errorMsg
            )
            // Update main validationErrors state only if we are saving the default config
            if selectedConfigKeyForEditing == globalDefaultDisplayName {
                self.validationErrors = errors
            } else {
                // Maybe store app-specific errors separately if needed?
                print("Validation issues found in \(selectedConfigKeyForEditing) config, but not setting main validationErrors.")
            }
        } else if selectedConfigKeyForEditing == globalDefaultDisplayName {
            // Clear errors if default config is now valid
            self.validationErrors = []
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [
                .prettyPrinted, .withoutEscapingSlashes, .sortedKeys,
            ]
            let jsonData = try encoder.encode(currentlyEditingGroup)
            try jsonData.write(to: URL(fileURLWithPath: filePath)) // Write to the specific file path

            // If the saved config was the default one, update the main 'root' property as well
            if selectedConfigKeyForEditing == globalDefaultDisplayName {
                self.root = currentlyEditingGroup
            }
            // If the saved config was an app-specific one, clear its cache entry
            // so it gets reloaded fresh next time getConfig(for:) is called.
            if selectedConfigKeyForEditing != globalDefaultDisplayName {
                appConfigs[selectedConfigKeyForEditing] = nil
            }

        } catch {
            handleError(error, critical: true)
        }

        // No full reloadConfig() here to avoid resetting the UI state unnecessarily,
        // but we might need to signal that a save happened.
        Events.send(.didSaveConfig) // Send a specific event if needed elsewhere
    }
} 