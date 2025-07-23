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
                    // Try to merge with fallback if available
                    let mergedConfig = mergeConfigWithFallback(appSpecificConfig: appRoot, bundleId: bundleId)
                    appConfigs[bundleId] = mergedConfig // Cache merged result
                    return mergedConfig
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

        // 2. Try fallback app config (app.default.json)
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
        let configName = (filePath as NSString).lastPathComponent
        print("[UserConfig] Attempting to decode config: \(configName)")

        let data: Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            print("[UserConfig] Successfully read data from: \(configName)")
        } catch {
            // Handle file reading errors (permissions, not found etc.)
            print("[UserConfig] Error reading file \(configName): \(error.localizedDescription)")
            // Show critical alert only if it's the essential default config and not suppressed
            if isDefaultConfig && !suppressAlerts {
                alertHandler.showAlert(
                    style: .critical,
                    message: "Failed to read default config file (config.json):\n\(error.localizedDescription)\n\nUsing empty configuration."
                )
            }
            // Don't show alerts for non-critical app-specific files that fail to read
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let decodedRoot = try decoder.decode(Group.self, from: data)
            print("[UserConfig] Successfully decoded JSON for: \(configName)")

            // Perform validation regardless, but only show alerts/update main state for default config
            let errors = ConfigValidator.validate(group: decodedRoot)
            if !errors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
                if isDefaultConfig {
                    // Store errors only if it's the default config being decoded in a context
                    // where we should update the main validationErrors state (e.g., initial load)
                    // self.validationErrors = errors // Caller should set this based on context
                    print("[UserConfig] Validation issues found in default config (config.json).")
                    showValidationAlert() // Show general validation alert for default config
                } else {
                    // Log validation issues for app-specific configs, but don't trigger primary alert/state
                    print("[UserConfig] Validation issues found in app-specific config: \(configName)")
                }
            }
            return decodedRoot
        } catch let decodingError as DecodingError {
            // Handle JSON Decoding errors specifically
            let errorDesc = formatDecodingError(decodingError, in: configName)
            print("[UserConfig] Error decoding JSON for \(configName): \(errorDesc)")
            if isDefaultConfig && !suppressAlerts {
                 alertHandler.showAlert(
                    style: .critical,
                    message: "Error decoding default config file (config.json):\n\(errorDesc)\n\nUsing empty configuration."
                 )
            } else if !isDefaultConfig && !suppressAlerts {
                // Optionally show a less critical alert for app-specific file errors
                alertHandler.showAlert(
                    style: .warning,
                    message: "Error decoding app-specific config file \(configName):\n\(errorDesc)\n\nThis config will be ignored."
                 )
            }
            return nil
        } catch {
            // Handle other potential errors during the process
            print("[UserConfig] Unexpected error processing config \(configName): \(error.localizedDescription)")
             if isDefaultConfig && !suppressAlerts {
                 alertHandler.showAlert(
                    style: .critical,
                    message: "Unexpected error processing default config file (config.json):\n\(error.localizedDescription)\n\nUsing empty configuration."
                 )
             } // Ignore other errors for non-default configs unless alerts enabled
            return nil
        }
    }

    // Helper to format DecodingError for user-friendly display
    private func formatDecodingError(_ error: DecodingError, in fileName: String) -> String {
        var message = "Invalid JSON structure in \(fileName)."
        switch error {
        case .typeMismatch(let type, let context),
             .valueNotFound(let type, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
            message += "\nExpected type '\(String(describing: type))' at path: \(path). \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
            message += "\nMissing key '\(key.stringValue)' at path: \(path). \(context.debugDescription)"
        case .dataCorrupted(let context):
            message += "\nData is corrupted. \(context.debugDescription)"
        @unknown default:
            message += "\nAn unknown decoding error occurred."
        }
        return message
    }

    internal func showValidationAlert() {
        let errorCount = validationErrors.count
        alertHandler.showAlert(
            style: .warning,
            message:
                "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in your default configuration (config.json). Some keys may not work as expected."
        )
    }

    // Recursively marks all nested actions and groups as fallback items
    private func markAsFromFallback(_ item: ActionOrGroup, fallbackSource: String) -> ActionOrGroup {
        switch item {
        case .action(var action):
            action.isFromFallback = true
            action.fallbackSource = fallbackSource
            // Mark any macro steps as fallback too
            if let macroSteps = action.macroSteps {
                action.macroSteps = macroSteps.map { step in
                    var newStep = step
                    newStep.action = markAsFromFallback(.action(newStep.action), fallbackSource: fallbackSource).item as! Action
                    return newStep
                }
            }
            return .action(action)
        case .group(var group):
            group.isFromFallback = true
            group.fallbackSource = fallbackSource
            // Recursively mark all nested items
            group.actions = group.actions.map { markAsFromFallback($0, fallbackSource: fallbackSource) }
            return .group(group)
        }
    }

    // Merges fallback config into app-specific config, marking fallback items with metadata
    private func mergeWithFallback(appSpecificGroup: Group, fallbackGroup: Group, fallbackSource: String) -> Group {
        print("[UserConfig] mergeWithFallback: Merging app-specific '\(appSpecificGroup.displayName)' with fallback '\(fallbackGroup.displayName)'")

        var mergedActions: [ActionOrGroup] = []

        // First, add all app-specific items (they take priority)
        for appItem in appSpecificGroup.actions {
            mergedActions.append(appItem)
        }

        // Then, add fallback items that don't conflict with app-specific items
        for fallbackItem in fallbackGroup.actions {
            let fallbackKey = fallbackItem.item.key

            // Check if an app-specific item with the same key already exists
            let hasConflict = appSpecificGroup.actions.contains { appItem in
                appItem.item.key == fallbackKey && fallbackKey != nil
            }

            if !hasConflict {
                // No conflict, add the fallback item with metadata, marking all nested items too
                let fallbackCopy = markAsFromFallback(fallbackItem, fallbackSource: fallbackSource)
                mergedActions.append(fallbackCopy)
            } else if let fallbackKey = fallbackKey,
                      case .group(let fallbackNestedGroup) = fallbackItem,
                      let appItemIndex = mergedActions.firstIndex(where: {
                          if case .group(let g) = $0, g.key == fallbackKey { return true }
                          return false
                      }) {
                // Both have groups with the same key - merge them recursively
                if case .group(let appNestedGroup) = mergedActions[appItemIndex] {
                    let mergedNestedGroup = mergeWithFallback(
                        appSpecificGroup: appNestedGroup,
                        fallbackGroup: fallbackNestedGroup,
                        fallbackSource: fallbackSource
                    )
                    mergedActions[appItemIndex] = .group(mergedNestedGroup)
                }
            }
        }

        // Create merged group with the same properties as app-specific group
        var mergedGroup = Group(
            key: appSpecificGroup.key,
            label: appSpecificGroup.label,
            iconPath: appSpecificGroup.iconPath,
            stickyMode: appSpecificGroup.stickyMode,
            actions: mergedActions
        )

        // Preserve app-specific group metadata
        mergedGroup.isFromFallback = appSpecificGroup.isFromFallback
        mergedGroup.fallbackSource = appSpecificGroup.fallbackSource

        print("[UserConfig] mergeWithFallback: Merged group has \(mergedActions.count) items")
        return mergedGroup
    }

    // Merges app-specific config with Fallback App Config if available
    internal func mergeConfigWithFallback(appSpecificConfig: Group, bundleId: String) -> Group {
        // Get the fallback app config
        let defaultAppConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(defaultAppConfigFileName)

        guard fileManager.fileExists(atPath: defaultAppConfigPath),
              let defaultAppConfig = decodeConfig(from: defaultAppConfigPath, suppressAlerts: true, isDefaultConfig: false) else {
            print("[UserConfig] mergeConfigWithFallback: No fallback app config available, returning app-specific config as-is")
            return appSpecificConfig
        }

        print("[UserConfig] mergeConfigWithFallback: Merging app-specific config for '\(bundleId)' with fallback app config")
        return mergeWithFallback(
            appSpecificGroup: appSpecificConfig,
            fallbackGroup: defaultAppConfig,
            fallbackSource: defaultAppConfigDisplayName
        )
    }
}
