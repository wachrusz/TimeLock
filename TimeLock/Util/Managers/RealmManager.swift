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
        Logger.shared.log("RealmManager loaded \(objects.count) entities", level: .debug)
        return objects.compactMap { $0.toHomeEntity() }
    }

    func deleteAll() {
        try? realm.write {
            realm.deleteAll()
        }
    }
    
    func deleteEntity(_ entity: HomeEntity) {
        if let obj = realm.object(ofType: RealmHomeEntity.self, forPrimaryKey: entity.id.uuidString) {
            try? realm.write {
                realm.delete(obj)
            }
        }
    }
    
    func entityExists(_ id: UUID) -> Bool {
        return realm.object(ofType: RealmHomeEntity.self, forPrimaryKey: id.uuidString) != nil
    }
}
