import Cocoa
import Defaults
import Foundation

// MARK: - Saving Configuration
extension UserConfig {

    /// Saves with final sorting - for when user explicitly wants to finalize their config
    func saveAndFinalize() {
        isActivelyEditing = false
        saveCurrentlyEditingConfig()
    }

    // Saves the configuration currently being edited in the Settings window
    func saveCurrentlyEditingConfig() {
        print("[SAVE LOG] saveCurrentlyEditingConfig: CALLED for config key: \(selectedConfigKeyForEditing)")
        print("[SAVE LOG] saveCurrentlyEditingConfig: State of currentlyEditingGroup BEFORE sort: \(currentlyEditingGroup)")

        guard let filePath = discoveredConfigFiles[selectedConfigKeyForEditing] else {
            let errorDesc = "Could not find file path for selected config key: \(selectedConfigKeyForEditing)"
            print("[SAVE LOG] saveCurrentlyEditingConfig: ERROR - \(errorDesc)")
            handleError(NSError(domain: "UserConfig", code: 3, userInfo: [NSLocalizedDescriptionKey: errorDesc]), critical: true)
            return
        }
        print("[SAVE LOG] saveCurrentlyEditingConfig: File path to save to: \(filePath)")

        // --- FALLBACK STRIPPING (for app-specific configs only) ---
        var groupToProcess = currentlyEditingGroup
        let isAppSpecificConfig = selectedConfigKeyForEditing != globalDefaultDisplayName

        if isAppSpecificConfig {
            print("[SAVE LOG] saveCurrentlyEditingConfig: Stripping fallback items from app-specific config.")
            groupToProcess = stripFallbackItems(from: currentlyEditingGroup)
            print("[SAVE LOG] saveCurrentlyEditingConfig: State after stripping fallbacks: \(groupToProcess)")
        } else {
            print("[SAVE LOG] saveCurrentlyEditingConfig: Saving global default config, keeping all items.")
        }
        // -----------------

        // --- CONDITIONAL SORTING --- 
        let finalGroup: Group
        if isActivelyEditing {
            print("[SAVE LOG] saveCurrentlyEditingConfig: Skipping sort - user is actively editing.")
            finalGroup = groupToProcess
        } else {
            print("[SAVE LOG] saveCurrentlyEditingConfig: About to sort group.")
            finalGroup = sortGroupRecursively(group: groupToProcess)
            print("[SAVE LOG] saveCurrentlyEditingConfig: State of group AFTER sort (finalGroup): \(finalGroup)")
        }
        // -----------------

        // Validate the group being saved
        print("[SAVE LOG] saveCurrentlyEditingConfig: About to validate finalGroup.")
        let errors = ConfigValidator.validate(group: finalGroup)
        print("[SAVE LOG] saveCurrentlyEditingConfig: Validation completed. Number of errors: \(errors.count)")
        if !errors.isEmpty {
            errors.forEach { print("[SAVE LOG] saveCurrentlyEditingConfig: Validation Error - Path: \($0.path), Msg: \($0.message), Type: \($0.type)") }
            // --- MODIFIED: Show error and RETURN if validation fails ---
            let errorCount = errors.count
            let errorMsg = "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in the '\(selectedConfigKeyForEditing)' configuration. \nPlease fix the issues before saving."
            // TODO: Consider showing the specific errors in the alert message or linking to them.
            alertHandler.showAlert(
                style: .warning,
                message: errorMsg
            )
            // Update validationErrors state (as before)
            if selectedConfigKeyForEditing == globalDefaultDisplayName {
                self.validationErrors = errors
            } else {
                print("Validation issues found in \(selectedConfigKeyForEditing) config, but not saving.")
            }
            return // PREVENT SAVING if errors exist
            // --- END MODIFICATION ---
        } else if selectedConfigKeyForEditing == globalDefaultDisplayName {
            // Clear errors if default config is now valid
            self.validationErrors = []
            print("[SAVE LOG] saveCurrentlyEditingConfig: No validation errors. Proceeding to encode and write.")
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [
                .prettyPrinted,
                .withoutEscapingSlashes,
                .sortedKeys // ensure deterministic key order in saved JSON
            ]
            // Encode the final group (sorted or unsorted based on editing state)
            let jsonData = try encoder.encode(finalGroup)
            try jsonData.write(to: URL(fileURLWithPath: filePath)) // Write to the specific file path
            print("[UserConfig] Successfully saved sorted config to: \(filePath)")

            // Trigger a reload to update the entire app state with the saved & sorted config
            print("[UserConfig] Triggering reloadConfig() after saving.")
            self.reloadConfig() // <<< RELOAD AFTER SAVE

        } catch {
            handleError(error, critical: true)
        }
    }

    // Recursively removes all fallback items from a group, keeping only app-specific items
    private func stripFallbackItems(from group: Group) -> Group {
        var appSpecificActions: [ActionOrGroup] = []

        for item in group.actions {
            switch item {
            case .action(let action):
                // Only keep actions that are NOT from fallback
                if !action.isFromFallback {
                    var cleanAction = action
                    // Clean macro steps too - only keep non-fallback macro steps
                    if let macroSteps = cleanAction.macroSteps {
                        cleanAction.macroSteps = macroSteps.filter { !$0.action.isFromFallback }
                    }
                    appSpecificActions.append(.action(cleanAction))
                }
            case .group(let subgroup):
                // Only keep groups that are NOT from fallback
                if !subgroup.isFromFallback {
                    // Recursively clean nested groups
                    let cleanedSubgroup = stripFallbackItems(from: subgroup)
                    appSpecificActions.append(.group(cleanedSubgroup))
                } else {
                    // If the group itself is from fallback, but it might contain app-specific items
                    // we need to extract any app-specific children and promote them to the parent level
                    let cleanedSubgroup = stripFallbackItems(from: subgroup)
                    // Only add if there are any app-specific items inside
                    if !cleanedSubgroup.actions.isEmpty {
                        // Create a new non-fallback group with the same structure but only app-specific content
                        var promotedGroup = Group(
                            key: cleanedSubgroup.key,
                            label: cleanedSubgroup.label,
                            iconPath: cleanedSubgroup.iconPath,
                            stickyMode: cleanedSubgroup.stickyMode,
                            actions: cleanedSubgroup.actions
                        )
                        // Ensure the promoted group is not marked as fallback
                        promotedGroup.isFromFallback = false
                        promotedGroup.fallbackSource = nil
                        appSpecificActions.append(.group(promotedGroup))
                    }
                }
            }
        }

        // Return a new group with only app-specific items
        var cleanGroup = Group(
            key: group.key,
            label: group.label,
            iconPath: group.iconPath,
            stickyMode: group.stickyMode,
            actions: appSpecificActions
        )

        // Preserve the group's metadata if it's not from fallback
        cleanGroup.isFromFallback = group.isFromFallback
        cleanGroup.fallbackSource = group.fallbackSource

        return cleanGroup
    }

    // Recursively sorts actions and groups within a group alphabetically by key
    internal func sortGroupRecursively(group: Group) -> Group {
        // Add a log at the beginning of this recursive sort function if deeper insight is needed
        // print("[SAVE LOG] sortGroupRecursively: Sorting group with key '\(group.key ?? "nil")', label '\(group.label ?? "no_label")'. \(group.actions.count) actions.")
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
            stickyMode: group.stickyMode,
            actions: sortedActions
        )
    }
}
