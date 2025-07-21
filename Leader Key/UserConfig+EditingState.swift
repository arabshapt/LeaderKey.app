import Foundation
import Dispatch

// MARK: - Editing State Management
extension UserConfig {

    // Loads the config identified by the key ("Default" or bundle ID) into currentlyEditingGroup
    func loadConfigForEditing(key: String) {
        // Handle Global Default separately first
        if key == globalDefaultDisplayName {
            print("[UserConfig loadConfigForEditing] Loading Global Default (from root). Key: \(key)")
            currentlyEditingGroup = root
            selectedConfigKeyForEditing = key
            return // <- Exit after handling Global Default
        }

        // If not Global Default, proceed with file path lookup
        guard let filePath = discoveredConfigFiles[key] else {
            print("Error: Config file path not found for key: \(key)")
            // If lookup fails, fall back to showing the Global Default
            currentlyEditingGroup = root
            selectedConfigKeyForEditing = globalDefaultDisplayName // Revert selection
            return
        }

        print("[UserConfig loadConfigForEditing] Loading app config. Key: \(key), Path: \(filePath)")
        // For non-default configs, set an empty root first to clear any state
        // then load from disk with error handling
        currentlyEditingGroup = emptyRoot

        // Load and decode. Suppress validation alerts for non-default configs during this specific load.
        let isDefault = false // We already handled the default case
        if let loadedGroup = decodeConfig(from: filePath, suppressAlerts: true, isDefaultConfig: isDefault) {
            // Only update the state after successfully loading the config
            currentlyEditingGroup = loadedGroup
            selectedConfigKeyForEditing = key
        } else {
            let errorDesc = "Failed to load config '\(key)' for editing from path: \(filePath)"
            handleError(NSError(domain: "UserConfig", code: 4, userInfo: [NSLocalizedDescriptionKey: errorDesc]), critical: false)
            // Keep using emptyRoot which was set above
            // Revert selection to Global Default if app config fails to load
            print("[UserConfig loadConfigForEditing] Failed to load app config '\(key)', reverting selection to Global Default.")
            currentlyEditingGroup = root
            selectedConfigKeyForEditing = globalDefaultDisplayName
        }
    }
} 