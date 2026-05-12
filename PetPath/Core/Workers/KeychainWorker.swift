//
//  KeychainWorker.swift
//  PetPath
//
//  Created by 김나훈 on 3/4/25.
//

import Foundation
import CryptoKit

final class KeychainWorker {

    enum TokenType: String {
        case access, fcm, impUid
    }

    static let shared = KeychainWorker()

    private let encryptionKey: SymmetricKey

    private init() {
        if let savedKeyData = UserDefaults.standard.data(forKey: "encryptionKey"),
           let key = try? SymmetricKey(data: savedKeyData) {
            self.encryptionKey = key
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            UserDefaults.standard.set(keyData, forKey: "encryptionKey")
            self.encryptionKey = newKey
        }
    }

    func create(key: TokenType, token: String) {
        guard let data = token.data(using: .utf8) else { return }
        do {
            let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
            guard let combined = sealedBox.combined else { return }
            UserDefaults.standard.set(combined, forKey: key.rawValue)
        } catch {
            print("Encryption failed: \(error)")
        }
    }

    func read(key keyType: TokenType) -> String? {
        guard let data = UserDefaults.standard.data(forKey: keyType.rawValue) else { return nil }
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }

    func delete(key keyType: TokenType) {
        UserDefaults.standard.removeObject(forKey: keyType.rawValue)
    }
}
