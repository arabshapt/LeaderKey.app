import Foundation
import Security

enum KeychainHelper {

    private static let service = "com.leaderkey.command-scout"

    static func save(account: String, key: String) -> Bool {
        delete(account: account)

        guard let data = key.data(using: .utf8) else {
            debugLog("[Keychain] save: failed to encode key for account=\(account)")
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            debugLog("[Keychain] save failed: account=\(account) status=\(status) (\(SecCopyErrorMessageString(status, nil) as String? ?? "unknown"))")
        }
        return status == errSecSuccess
    }

    static func load(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8)
        else {
            if status != errSecItemNotFound {
                debugLog("[Keychain] load failed: account=\(account) status=\(status) (\(SecCopyErrorMessageString(status, nil) as String? ?? "unknown"))")
            }
            return nil
        }

        return key
    }

    @discardableResult
    static func delete(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    static func hasKey(account: String) -> Bool {
        load(account: account) != nil
    }
}
