import Foundation

// MARK: - Validation Methods
extension UserConfig {

    func validateWithoutAlerts() {
        // Validate the currently editing group for real-time feedback
        validationErrors = ConfigValidator.validate(group: currentlyEditingGroup)
    }

    func finishEditingKey() {
        validateWithoutAlerts()
    }
}
