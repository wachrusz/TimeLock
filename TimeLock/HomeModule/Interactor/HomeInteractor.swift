//
//  HomeInteractor.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import Foundation

protocol HomeInteractorOutput: AnyObject {
    func didFetchEntities(_ entities: [HomeEntity])
}

protocol HomeInteractorInput {
    func fetchEntities() -> [HomeEntity]
    func addEntity(source: String, secret: Data)
}

final class HomeInteractor: HomeInteractorInput {
    weak var output: HomeInteractorOutput?
    func fetchEntities() -> [HomeEntity] {
        RealmManager.shared.loadAll()
    }

    func addEntity(source: String, secret: Data) {
        let entity = HomeEntity(source: source, secret: secret)
        if RealmManager.shared.entityExists(entity.id) {
            Logger.shared.log("⚠️ Entity with id \(entity.id) already exists. Skipping save.", level: .info)
            return
        }

        RealmManager.shared.save(entity)
        
        let current = iCloudStorage.shared.loadEntitiesMetadata()
        let newEntry: [String: String] = [
            "id": entity.id.uuidString,
            "source": entity.source
        ]
        iCloudStorage.shared.saveEntitiesMetadata(current + [newEntry])
    }
    
    func restoreIfNeeded() -> [HomeEntity] {
        let existing = RealmManager.shared.loadAll()

        guard existing.isEmpty else {
            Logger.shared.log("📦 Realm не пуст, восстановление из iCloud не требуется.")
            return existing
        }

        Logger.shared.log("💥 Realm пуст. Попытка восстановления из iCloud...")

        let meta = iCloudStorage.shared.loadEntitiesMetadata()

        let restored: [HomeEntity] = meta.compactMap { (dict: [String: String]) in
            guard let idStr = dict["id"],
                  let id = UUID(uuidString: idStr),
                  let source = dict["source"],
                  let secret = KeychainStorage.shared.load(for: idStr)
            else {
                Logger.shared.log("⚠️ Пропущен повреждённый элемент: \(dict)")
                return nil
            }

            let entity = HomeEntity(id: id, source: source, secret: secret)
            RealmManager.shared.save(entity)
            return entity
        }

        Logger.shared.log("✅ Восстановлено из iCloud: \(restored.count) объектов")
        return restored
    }

}


