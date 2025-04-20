//
//  HomeEntity.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import Foundation
import RealmSwift
import CryptoKit

final class RealmHomeEntity: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var source: String

    convenience init(from entity: HomeEntity) {
        self.init()
        self.id = entity.id.uuidString
        self.source = entity.source
    }

    func toHomeEntity() -> HomeEntity? {
        guard let uuid = UUID(uuidString: id),
              let secret = KeychainStorage.shared.load(for: id) else {
            return nil
        }
        return HomeEntity(id: uuid, source: source, secret: secret)
    }
}

struct HomeEntity: Identifiable {
    let id: UUID
    let source: String
    let secret: Data

    var code: String {
        TOTPGenerator.shared.generate(for: self.id)
    }

    var timeRemaining: Int {
        let interval = 30.0
        let now = Date().timeIntervalSince1970
        let nextSlot = ceil(now / interval) * interval
        return Int(nextSlot - now)
    }

    init(source: String, secret: Data) {
        self.source = source
        self.secret = secret
        self.id = secret.deterministicUUID
        TOTPGenerator.shared.register(secret: self.secret, for: self.id)
        KeychainStorage.shared.save(data: secret, for: id.uuidString)
    }

    init(id: UUID, source: String, secret: Data) {
        self.id = id
        self.source = source
        self.secret = secret
        TOTPGenerator.shared.register(secret: self.secret, for: self.id)
    }
}

extension Data {
    var deterministicUUID: UUID {
        let hash = SHA256.hash(data: self)
        return Data(hash.prefix(16)).withUnsafeBytes {
            UUID(uuid: $0.load(as: uuid_t.self))
        }
    }
}
