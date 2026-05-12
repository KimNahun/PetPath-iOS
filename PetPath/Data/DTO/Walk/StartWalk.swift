//
//  StartWalk.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct StartOrEndWalkRequest: Codable {
    let key: String
    let type: QRType
    let walkId: Int
}

enum QRType: String, Codable {
    case start
    case end
    case unknown
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = QRType(rawValue: rawValue) ?? .unknown
    }
}
