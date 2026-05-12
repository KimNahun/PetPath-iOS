//
//  GetMainNotice.swift
//  PetPath
//
//  Created by 김나훈 on 4/22/25.
//

import Foundation

struct GetMainNoticeRequest: Encodable {
    let type: UserType
}

struct GetMainNoticeDTO: Decodable, Hashable {
    let image: String
    let url: String?
    let linkType: LinkType?
    let appSchema: AppSchema?
}

struct AppSchema: Decodable, Hashable {
    let screen: String
    let id: String
    let accountType: UserType
}

enum LinkType: String, Decodable {
    case web
    case app
    case unknown
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = LinkType(rawValue: rawValue) ?? .unknown
    }
}
