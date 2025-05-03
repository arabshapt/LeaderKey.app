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

        // --- SORTING --- 
        // Create a sorted version of the group before saving
        let sortedGroup = sortGroupRecursively(group: currentlyEditingGroup)
        // -----------------

        // Validate the group being saved
        let errors = ConfigValidator.validate(group: sortedGroup)
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
                .prettyPrinted, .withoutEscapingSlashes, // .sortedKeys not needed as we sort manually
            ]
            // Encode the SORTED group
            let jsonData = try encoder.encode(sortedGroup)
            try jsonData.write(to: URL(fileURLWithPath: filePath)) // Write to the specific file path
            print("[UserConfig] Successfully saved sorted config to: \(filePath)")

            // Trigger a reload to update the entire app state with the saved & sorted config
            print("[UserConfig] Triggering reloadConfig() after saving.")
            self.reloadConfig() // <<< RELOAD AFTER SAVE

        } catch {
            handleError(error, critical: true)
        }
    }

    // Recursively sorts actions and groups within a group alphabetically by key
    private func sortGroupRecursively(group: Group) -> Group {
        var sortedActions: [ActionOrGroup] = []

        // Sort actions within the current group
        let currentLevelSorted = group.actions.sorted { item1, item2 in
            let key1 = item1.item.key?.lowercased() ?? "zzz" // Treat nil/empty keys as last
            let key2 = item2.item.key?.lowercased() ?? "zzz"
            // Ensure empty/nil keys are always after non-empty keys
            if key1 == "zzz" && key2 != "zzz" { return false }
            if key1 != "zzz" && key2 == "zzz" { return true }
            return key1 < key2
        }

        // Recursively sort subgroups
        for item in currentLevelSorted {
            switch item {
            case .action(let action):
                sortedActions.append(.action(action)) // Actions remain as they are
            case .group(let subgroup):
                // Recursively sort the subgroup and append the result
                sortedActions.append(.group(sortGroupRecursively(group: subgroup)))
            }
        }

        // Return a new Group instance with the sorted actions
        return Group(
            key: group.key,
            label: group.label,
            iconPath: group.iconPath,
            actions: sortedActions
        )
    }
} 