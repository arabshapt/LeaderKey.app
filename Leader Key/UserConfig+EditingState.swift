import Dispatch
import Foundation

// MARK: - Editing State Management
extension UserConfig {

  // Helper to extract bundle ID from a display key for merging purposes
  private func extractBundleIdFromKey(key: String) -> String {
    // If the key matches discovered config patterns, extract bundle ID from the file path
    if let filePath = discoveredConfigFiles[key] {
      switch configFileKind(forPath: filePath) {
      case .app(let bundleId), .normalApp(let bundleId):
        return bundleId
      case .global, .appFallback, .normalFallback, .unknown:
        break
      }
    }
    // Fallback: assume the key is the bundle ID if it contains dots
    if key.contains(".") {
      return key
    }
    // Last resort: return key as-is
    return key
  }

  // Loads the config identified by the key ("Default" or bundle ID) into currentlyEditingGroup
  func loadConfigForEditing(key: String) {
    // Handle Global Default separately first
    if key == globalDefaultDisplayName {
      print("[UserConfig loadConfigForEditing] Loading Global Default (from root). Key: \(key)")
      currentlyEditingGroup = root
      selectedConfigKeyForEditing = key
      isActivelyEditing = false  // Start with sorted view when loading
      return  // <- Exit after handling Global Default
    }

    // If not Global Default, proceed with file path lookup
    guard let filePath = discoveredConfigFiles[key] else {
      print("Error: Config file path not found for key: \(key)")
      // If lookup fails, fall back to showing the Global Default
      currentlyEditingGroup = root
      selectedConfigKeyForEditing = globalDefaultDisplayName  // Revert selection
      isActivelyEditing = false  // Start with sorted view when loading
      return
    }

    print("[UserConfig loadConfigForEditing] Loading config. Key: \(key), Path: \(filePath)")
    // For non-default configs, set an empty root first to clear any state
    // then load from disk with error handling
    currentlyEditingGroup = emptyRoot

    // Load and decode. Suppress validation alerts for non-default configs during this specific load.
    let isDefault = false  // We already handled the default case
    if let loadedGroup = decodeConfig(
      from: filePath, suppressAlerts: true, isDefaultConfig: isDefault)
    {
      // Apply fallback merging for app-specific configs, just like getConfig(for:) does
      let mergedGroup: Group
      switch configFileKind(forPath: filePath) {
      case .app(let bundleId):
        let rawMergedGroup = mergeConfigWithFallback(
          appSpecificConfig: loadedGroup, bundleId: bundleId)
        mergedGroup = sortGroupRecursively(group: rawMergedGroup)
        print(
          "[UserConfig loadConfigForEditing] Applied fallback merging and sorting for app config '\(key)'"
        )

      case .normalApp(let bundleId):
        let rawMergedGroup = mergeNormalConfigWithFallback(
          appSpecificConfig: loadedGroup, bundleId: bundleId)
        mergedGroup = sortGroupRecursively(group: rawMergedGroup)
        print(
          "[UserConfig loadConfigForEditing] Applied fallback merging and sorting for normal app config '\(key)'"
        )

      case .global, .appFallback, .normalFallback, .unknown:
        mergedGroup = loadedGroup
      }

      // Only update the state after successfully loading and merging the config
      currentlyEditingGroup = mergedGroup
      selectedConfigKeyForEditing = key
      isActivelyEditing = false  // Start with sorted view when loading
    } else {
      let errorDesc = "Failed to load config '\(key)' for editing from path: \(filePath)"
      handleError(
        NSError(domain: "UserConfig", code: 4, userInfo: [NSLocalizedDescriptionKey: errorDesc]),
        critical: false)
      // Keep using emptyRoot which was set above
      // Revert selection to Global Default if app config fails to load
      print(
        "[UserConfig loadConfigForEditing] Failed to load app config '\(key)', reverting selection to Global Default."
      )
      currentlyEditingGroup = root
      selectedConfigKeyForEditing = globalDefaultDisplayName
      isActivelyEditing = false  // Start with sorted view when loading
    }
  }
}
