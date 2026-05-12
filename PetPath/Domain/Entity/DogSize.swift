//
//  DogSize.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

enum DogSize: String, Codable {
    case small
    case middle
    case big
    case unknown
    
    var koreanDescription: String {
        switch self {
        case .small: return "소형견"
        case .middle: return "중형견"
        case .big: return "대형견"
        case .unknown: return ""
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = DogSize(rawValue: rawValue) ?? .unknown
    }
}
