import Cocoa
import Defaults
import Foundation

// MARK: - File Discovery
extension UserConfig {

    internal func discoverConfigFiles() {
        var discovered: [String: String] = [:]
        let configDir = Defaults[.configDir]
        let configDirUrl = URL(fileURLWithPath: configDir)
        let customNames = Defaults[.configFileCustomNames] // Get custom names

        // Helper function to get display name
        func getDisplayName(for path: String, defaultName: String) -> String {
            return customNames[path] ?? defaultName
        }

        // Add global default config first
        let defaultPath = (configDir as NSString).appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: defaultPath) {
            let displayName = getDisplayName(for: defaultPath, defaultName: globalDefaultDisplayName)
            discovered[displayName] = defaultPath
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: configDirUrl, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                let currentFileName = fileURL.lastPathComponent
                let filePath = fileURL.path

                // Skip the main global-config.json as it's handled above
                if filePath == defaultPath {
                    continue
                }

                // Check for fallback app config
                if currentFileName == defaultAppConfigFileName {
                    let displayName = getDisplayName(for: filePath, defaultName: defaultAppConfigDisplayName)
                    discovered[displayName] = filePath
                }
                // Check for other app-specific configs
                else if currentFileName.hasPrefix(appConfigPrefix) && currentFileName.hasSuffix(".json") {
                    // Extract bundle ID
                    let bundleId = String(currentFileName.dropFirst(appConfigPrefix.count).dropLast(".json".count))
                    if !bundleId.isEmpty && bundleId != "default" { // Exclude app-fallback-config.json here
                        let defaultAppDisplayName = "App: \(bundleId)" // Corrected interpolation
                        let displayName = getDisplayName(for: filePath, defaultName: defaultAppDisplayName)
                        discovered[displayName] = filePath
                    }
                }
                // Future: Handle other types of config files if needed
            }
        } catch {
            let errorMessage = "Failed to list contents of config directory: \(configDir)"
            handleError(NSError(domain: "UserConfig", code: 5, userInfo: [NSLocalizedDescriptionKey: errorMessage]), critical: false)
        }

        // Sort the discovered files by display name for consistent UI presentation
        // Keep Global Default first, then Fallback App Config, then others alphabetically
        let sortedDiscovered = discovered.sorted { (pair1, pair2) -> Bool in
            let (name1, _) = pair1
            let (name2, _) = pair2

            if name1 == globalDefaultDisplayName { return true }
            if name2 == globalDefaultDisplayName { return false }
            if name1 == defaultAppConfigDisplayName { return true }
            if name2 == defaultAppConfigDisplayName { return false }
            return name1.localizedCompare(name2) == .orderedAscending
        }.reduce(into: [String: String]()) { (dict, pair) in
            dict[pair.key] = pair.value
        }

        // Update the published property
        self.discoveredConfigFiles = sortedDiscovered // Use the sorted dictionary

        // Ensure selectedConfigKeyForEditing is valid, reset if not
        // Important: Use the *new* display name logic when checking
        var currentSelectionIsValid = false
        if let currentPath = discovered.first(where: { $0.key == selectedConfigKeyForEditing })?.value {
            // We found the path for the currently selected key, check if the key is still correct
            let expectedKey = getDisplayName(for: currentPath, defaultName: selectedConfigKeyForEditing) // Calculate expected key
            if expectedKey == selectedConfigKeyForEditing {
                currentSelectionIsValid = true
            }
        }

        if !currentSelectionIsValid {
            // Break the long print statement
            print("Warning: Previously selected config key '\(selectedConfigKeyForEditing)' no longer exists or its name changed.")
            print("Resetting selection to Global Default or its custom name.")
            // Attempt to find the key for the default path
            if let defaultKey = sortedDiscovered.first(where: { $0.value == defaultPath })?.key {
                selectedConfigKeyForEditing = defaultKey
            } else {
                // If even the default config is missing/renamed weirdly, fallback to the literal default name
                selectedConfigKeyForEditing = globalDefaultDisplayName
            }

            // Force load the editing group based on the (potentially new) selected key
            if let newDefaultPath = sortedDiscovered[selectedConfigKeyForEditing] {
                // Need a safe way to load here, might need a refactor or use existing loadConfigForEditing carefully
                // For now, just print a message, loading will happen elsewhere or needs adjustment
                print("Need to load config for: \(selectedConfigKeyForEditing)") // Corrected interpolation
                // Let's try calling loadConfigForEditing, but be mindful of potential infinite loops if called within init
                DispatchQueue.main.async { // Avoid direct call within discovery
                    self.loadConfigForEditing(key: self.selectedConfigKeyForEditing)
                }

            } else {
                currentlyEditingGroup = emptyRoot // Handle case where default is gone
            }
        }
    }
}
