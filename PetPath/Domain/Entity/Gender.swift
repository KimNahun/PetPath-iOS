//
//  Gender.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

enum Gender: String, Codable {
    case male
    case female
    case unknown
    
    var koreanDescription: String {
        switch self {
        case .male: return "남"
        case .female: return "여"
        case .unknown: return ""
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Gender(rawValue: rawValue) ?? .unknown
    }
}

