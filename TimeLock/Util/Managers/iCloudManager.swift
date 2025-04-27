//
//  iCloudManager.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 18.04.2025.
//

import Foundation

final class iCloudStorage {
    private let store = NSUbiquitousKeyValueStore.default

    static let shared = iCloudStorage()

    private init() {}

    func saveEntitiesMetadata(_ metadata: [[String: String]]) {
        store.set(metadata, forKey: "totp_entities")
        store.synchronize()
    }

    func loadEntitiesMetadata() -> [[String: String]] {
        store.synchronize()
        return store.array(forKey: "totp_entities") as? [[String: String]] ?? []
    }
}
