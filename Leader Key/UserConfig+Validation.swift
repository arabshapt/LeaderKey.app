import Foundation

// MARK: - Validation Methods
extension UserConfig {

    func validateWithoutAlerts() {
        validationErrors = ConfigValidator.validate(group: root)
    }

    func finishEditingKey() {
        validateWithoutAlerts()
    }
}
