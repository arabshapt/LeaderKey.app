import Cocoa

// MARK: - Error Handling
extension UserConfig {

    internal func handleError(_ error: Error, critical: Bool) {
        alertHandler.showAlert(
            style: critical ? .critical : .warning, message: "\(error)")
        // Resetting root/currentlyEditingGroup on critical errors needs care
        if critical {
            root = emptyRoot
            currentlyEditingGroup = emptyRoot
            validationErrors = []
            // Maybe reset selection?
            selectedConfigKeyForEditing = globalDefaultDisplayName
            // Re-discover files? Might be problematic if dir access is the issue.
            discoverConfigFiles()
        }
    }
}
