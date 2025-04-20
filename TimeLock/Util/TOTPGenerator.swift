//
//  TOTPGenerator.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 17.04.2025.
//

import Foundation
import CryptoKit

final class TOTPGenerator {
    static let shared = TOTPGenerator()
    private init() {
        loadSecretsFromKeychain()
    }

    private var secretsByID: [UUID: Data] = [:]

    func register(secret: Data, for id: UUID) {
        secretsByID[id] = secret
        KeychainStorage.shared.save(data: secret, for: id.uuidString)
        
        let hex = secret.map { String(format: "%02hhx", $0) }.joined()
        let base64 = secret.base64EncodedString()
        print("""
        🔐 [TOTP] Registered Secret:
        - UUID: \(id)
        - HEX: \(hex)
        - BASE64: \(base64)
        - SIZE: \(secret.count) bytes
        """)
    }

    func generate(for id: UUID, digits: Int = 6, interval: TimeInterval = 30) -> String {
        guard let secret = secretsByID[id] else { return "------" }

        let timestamp = Date().timeIntervalSince1970
        let counter = UInt64(floor(timestamp / interval))

        var counterBigEndian = counter.bigEndian
        let counterData = Data(bytes: &counterBigEndian, count: MemoryLayout<UInt64>.size)

        let key = SymmetricKey(data: secret)
        let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key)
        let dataHash = Data(hash)

        let offset = Int(dataHash.last! & 0x0f)
        let slice = dataHash.subdata(in: offset..<offset + 4)

        let number = slice.reduce(0) { (result, byte) in
            (result << 8) | UInt32(byte)
        } & 0x7fffffff

        let otp = number % UInt32(pow(10, Float(digits)))
        
        print("🔍 Secret for UUID \(id):")
        print("- HEX:", secret.map { String(format: "%02x", $0) }.joined())
        print("- SIZE: \(secret.count) bytes")
        
        return String(format: "%0*u", digits, otp)
    }

    private func loadSecretsFromKeychain() {
        let keys = KeychainStorage.shared.loadAllKeys()
        for key in keys {
            if let data = KeychainStorage.shared.load(for: key),
               let uuid = UUID(uuidString: key) {
                secretsByID[uuid] = data
            }
        }
    }
    
    func contains(secret: Data) -> Bool {
        return secretsByID.contains { $0.value == secret }
    }
}

// MARK: - Base32 Decoder (RFC 4648)
extension Data {
    init?(base32Encoded input: String) {
        let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let sanitized = input.uppercased().filter { base32Alphabet.contains($0) }
        guard !sanitized.isEmpty else { return nil }

        var buffer: UInt64 = 0
        var bitsLeft: Int = 0
        var data = Data()

        for char in sanitized {
            guard let index = base32Alphabet.firstIndex(of: char)?.utf16Offset(in: base32Alphabet) else {
                return nil
            }
            buffer <<= 5
            buffer |= UInt64(index)
            bitsLeft += 5

            if bitsLeft >= 8 {
                let byte = UInt8((buffer >> UInt(bitsLeft - 8)) & 0xFF)
                data.append(byte)
                bitsLeft -= 8
            }
        }

        self = data
    }
}

// MARK: - Hex Decoder Helper
extension Data {
    init?(hexString: String) {
        let trimmed = hexString.replacingOccurrences(of: " ", with: "")
        let len = trimmed.count / 2
        var data = Data(capacity: len)
        var index = trimmed.startIndex
        for _ in 0..<len {
            let nextIndex = trimmed.index(index, offsetBy: 2)
            guard nextIndex <= trimmed.endIndex else { return nil }
            let bytes = trimmed[index..<nextIndex]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            index = nextIndex
        }
        self = data
    }
}
