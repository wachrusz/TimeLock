//
//  RealmManager.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 18.04.2025.
//

import RealmSwift

final class RealmManager {
    static let shared = RealmManager()
    private let realm = try! Realm()

    private init() {}

    func save(_ entity: HomeEntity) {
        let realmEntity = RealmHomeEntity(from: entity)
        try? realm.write {
            realm.add(realmEntity, update: .modified)
        }
    }

    func loadAll() -> [HomeEntity] {
        let objects = realm.objects(RealmHomeEntity.self)
        return objects.compactMap { $0.toHomeEntity() }
    }

    func deleteAll() {
        try? realm.write {
            realm.deleteAll()
        }
    }
}
