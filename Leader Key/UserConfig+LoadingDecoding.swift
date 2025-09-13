import Defaults
import Foundation

// MARK: - Config Loading & Decoding
extension UserConfig {

    internal func loadConfig(for profileName: String, suppressAlerts: Bool = false) {
        let configPath = self.path(for: profileName)
        if let loadedRoot = decodeConfig(from: configPath, for: profileName, suppressAlerts: suppressAlerts, isDefaultConfig: true) {
            self.root = loadedRoot
            self.validationErrors = ConfigValidator.validate(group: self.root)
            if !validationErrors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
                showValidationAlert(for: profileName)
            }
        } else {
            self.root = emptyRoot
            self.validationErrors = []
        }
    }

    func getFallbackConfig(for profileName: String) -> Group {
        let fallbackKey = "fallback_\(profileName)"

        if let cached = appConfigs[fallbackKey] {
            return cached ?? root
        }

        let fallbackPath = (profilesDirectory as NSString).appendingPathComponent("\(profileName)/\(defaultAppConfigFileName)")
        if fileManager.fileExists(atPath: fallbackPath) {
            if let fallbackRoot = decodeConfig(from: fallbackPath, for: profileName, suppressAlerts: true, isDefaultConfig: false) {
                appConfigs[fallbackKey] = fallbackRoot
                return fallbackRoot
            } else {
                appConfigs[fallbackKey] = nil
            }
        } else {
            appConfigs[fallbackKey] = nil
        }
        return root
    }

    func getMarkedFallbackConfig(for profileName: String) -> Group {
        let fallbackConfig = getFallbackConfig(for: profileName)
        let fallbackKey = "fallback_\(profileName)"
        let hasFallbackConfig = appConfigs[fallbackKey] != nil

        if !hasFallbackConfig {
            return root
        }

        var markedGroup = fallbackConfig
        markedGroup.actions = fallbackConfig.actions.map { item in
            markAsFromFallback(item, fallbackSource: "Fallback")
        }
        return markedGroup
    }

    func getConfig(for bundleId: String?, in profileName: String) -> Group {
        if let bundleId = bundleId, !bundleId.isEmpty {
            let appKey = "\(profileName)_\(bundleId)"
            if let cachedConfig = appConfigs[appKey] {
                return cachedConfig ?? root
            }

            let appFileName = "\(appConfigPrefix)\(bundleId).json"
            let appConfigPath = (profilesDirectory as NSString).appendingPathComponent("\(profileName)/\(appFileName)")

            if fileManager.fileExists(atPath: appConfigPath) {
                if let appRoot = decodeConfig(from: appConfigPath, for: profileName, suppressAlerts: true, isDefaultConfig: false) {
                    let rawMergedConfig = mergeConfigWithFallback(appSpecificConfig: appRoot, bundleId: bundleId, profileName: profileName)
                    let mergedConfig = sortGroupRecursively(group: rawMergedConfig)
                    appConfigs[appKey] = mergedConfig
                    return mergedConfig
                } else {
                    appConfigs[appKey] = nil
                }
            } else {
                appConfigs[appKey] = nil
            }
        }

        return getFallbackConfig(for: profileName)
    }

    internal func decodeConfig(from filePath: String, for profileName: String, suppressAlerts: Bool, isDefaultConfig: Bool) -> Group? {
        let configName = (filePath as NSString).lastPathComponent

        let fileURL = URL(fileURLWithPath: filePath)
        let fileModDate = try? fileManager.attributesOfItem(atPath: filePath)[.modificationDate] as? Date

        if let cachedGroup = configCache.getConfig(for: filePath, fileModificationDate: fileModDate) {
            return cachedGroup
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if isDefaultConfig && !suppressAlerts {
                alertHandler.showAlert(
                    style: .critical,
                    message: "Failed to read config file (\(configName)) for profile '\(profileName)':\n\(error.localizedDescription)\n\nUsing empty configuration."
                )
            }
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let decodedRoot = try decoder.decode(Group.self, from: data)

            let errors = ConfigValidator.validate(group: decodedRoot)
            if !errors.isEmpty && !suppressAlerts && !suppressValidationAlerts {
                if isDefaultConfig {
                    showValidationAlert(for: profileName)
                }
            }

            configCache.setConfig(decodedRoot, for: filePath, fileModificationDate: fileModDate)
            return decodedRoot
        } catch let decodingError as DecodingError {
            let errorDesc = formatDecodingError(decodingError, in: configName)
            if isDefaultConfig && !suppressAlerts {
                alertHandler.showAlert(
                    style: .critical,
                    message: "Error decoding config file (\(configName)) for profile '\(profileName)':\n\(errorDesc)\n\nUsing empty configuration."
                )
            } else if !isDefaultConfig && !suppressAlerts {
                alertHandler.showAlert(
                    style: .warning,
                    message: "Error decoding app-specific config file \(configName) for profile '\(profileName)':\n\(errorDesc)\n\nThis config will be ignored."
                )
            }
            return nil
        } catch {
            if isDefaultConfig && !suppressAlerts {
                alertHandler.showAlert(
                    style: .critical,
                    message: "Unexpected error processing config \(configName) for profile '\(profileName)':\n\(error.localizedDescription)\n\nUsing empty configuration."
                )
            }
            return nil
        }
    }

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

    internal func showValidationAlert(for profileName: String) {
        let errorCount = validationErrors.count
        alertHandler.showAlert(
            style: .warning,
            message: "Found \(errorCount) validation issue\(errorCount > 1 ? "s" : "") in your '\(profileName)' profile configuration. Some keys may not work as expected."
        )
    }

    private func markAsFromFallback(_ item: ActionOrGroup, fallbackSource: String) -> ActionOrGroup {
        switch item {
        case .action(var action):
            action.isFromFallback = true
            action.fallbackSource = fallbackSource
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
            group.actions = group.actions.map { markAsFromFallback($0, fallbackSource: fallbackSource) }
            return .group(group)
        }
    }

    private func mergeWithFallback(appSpecificGroup: Group, fallbackGroup: Group, fallbackSource: String) -> Group {
        var mergedActions: [ActionOrGroup] = []
        for appItem in appSpecificGroup.actions {
            mergedActions.append(appItem)
        }
        for fallbackItem in fallbackGroup.actions {
            let fallbackKey = fallbackItem.item.key
            let hasConflict = appSpecificGroup.actions.contains { appItem in
                appItem.item.key == fallbackKey && fallbackKey != nil
            }
            if !hasConflict {
                let fallbackCopy = markAsFromFallback(fallbackItem, fallbackSource: fallbackSource)
                mergedActions.append(fallbackCopy)
            } else if let fallbackKey = fallbackKey,
                      case .group(let fallbackNestedGroup) = fallbackItem,
                      let appItemIndex = mergedActions.firstIndex(where: {
                          if case .group(let g) = $0, g.key == fallbackKey { return true }
                          return false
                      }) {
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
        var mergedGroup = Group(
            key: appSpecificGroup.key,
            label: appSpecificGroup.label,
            iconPath: appSpecificGroup.iconPath,
            stickyMode: appSpecificGroup.stickyMode,
            actions: mergedActions
        )
        mergedGroup.isFromFallback = appSpecificGroup.isFromFallback
        mergedGroup.fallbackSource = appSpecificGroup.fallbackSource
        return mergedGroup
    }

    internal func mergeConfigWithFallback(appSpecificConfig: Group, bundleId: String, profileName: String) -> Group {
        let fallbackConfig = getFallbackConfig(for: profileName)
        return mergeWithFallback(
            appSpecificGroup: appSpecificConfig,
            fallbackGroup: fallbackConfig,
            fallbackSource: "Fallback"
        )
    }
}
