//
//  UserDefaultManager.swift
//  PetPath
//
//  Created by 김나훈 on 7/17/25.
//

import Foundation

final class UserDefaultManager {
    
    static let shared = UserDefaultManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // 환경 식별자
    private var environmentSuffix: String {
        return UrlManager.isDev ? "_dev" : "_prod"
    }
    
    // 키 정의 (논리적 이름만!)
    enum Key: String {
        case walkPushModal
    }
    
    // 실제 저장 키 만들기
    private func namespacedKey(for key: Key) -> String {
        return key.rawValue + environmentSuffix
    }
    
    // CREATE: 해당 키가 존재함을 마킹 (Bool true 저장)
    func create(_ key: Key) {
        defaults.set(true, forKey: namespacedKey(for: key))
    }
    
    // READ: 해당 키가 존재하는지 여부 반환
    func read(_ key: Key) -> Bool {
        return defaults.object(forKey: namespacedKey(for: key)) != nil
    }
    
    // DELETE: 해당 키 제거
    func delete(_ key: Key) {
        defaults.removeObject(forKey: namespacedKey(for: key))
    }
}
