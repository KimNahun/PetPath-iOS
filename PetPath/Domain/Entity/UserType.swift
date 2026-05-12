//
//  UserType.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

enum UserType: String, Codable {
    case owner
    case walker
    case unknown
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = UserType(rawValue: rawValue) ?? .unknown
    }
}
