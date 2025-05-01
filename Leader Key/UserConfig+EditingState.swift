import Foundation
import Dispatch

// MARK: - Editing State Management
extension UserConfig {

    // Loads the config identified by the key ("Default" or bundle ID) into currentlyEditingGroup
    func loadConfigForEditing(key: String) {
        guard let filePath = discoveredConfigFiles[key] else {
            print("Error: Config file path not found for key: \(key)")
            currentlyEditingGroup = emptyRoot
            selectedConfigKeyForEditing = globalDefaultDisplayName // Revert selection
            return
        }

        // Safely clear any cached data first to avoid stale references
        if key == globalDefaultDisplayName {
            // If switching to default config, set editing group from existing root
            // This is safer than reloading from disk
            currentlyEditingGroup = root
            selectedConfigKeyForEditing = key
        } else {
            // For other configs, set an empty root first to clear any state
            // then load from disk with error handling
            currentlyEditingGroup = emptyRoot

            // Load and decode. Suppress validation alerts for non-default configs during this specific load.
            let isDefault = (key == globalDefaultDisplayName)
            if let loadedGroup = decodeConfig(from: filePath, suppressAlerts: !isDefault, isDefaultConfig: isDefault) {
                // Only update the state after successfully loading the config
                currentlyEditingGroup = loadedGroup
                selectedConfigKeyForEditing = key
            } else {
                let errorDesc = "Failed to load config '\(key)' for editing from path: \(filePath)"
                handleError(NSError(domain: "UserConfig", code: 4, userInfo: [NSLocalizedDescriptionKey: errorDesc]), critical: false)
                // Keep using emptyRoot which was set above
                // Keep selection on the failed key so user can see it failed
            }
        }
    }
} 