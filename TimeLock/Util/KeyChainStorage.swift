//
//  KeyChainStorage.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 17.04.2025.
//

import Foundation
import Security

final class KeychainStorage {
    static let shared = KeychainStorage()
    private init() {}

    func save(data: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]

        SecItemDelete(query as CFDictionary) // Это на всякий, вдруг какая-то залупа осталась
        SecItemAdd(query as CFDictionary, nil)
    }

    func load(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess ? result as? Data : nil
    }

    func loadAllKeys() -> [String] {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecReturnAttributes as String : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitAll
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let items = result as? [[String: Any]]
        else {
            return []
        }

        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
    
    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        SecItemDelete(query as CFDictionary)
    }
}
