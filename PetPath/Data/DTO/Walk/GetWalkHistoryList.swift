//
//  GetWalkHistoryList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkHistoryListRequest: Encodable {
    let page: Int
}

struct GetWalkHistoryListDTO: Decodable, Hashable {
    let pk: Int
    let title, pickup, walkerName: String
    let startAt, endAt: String
    let profileImage: [String]
    let active: Bool
    let status: WalkStatus
}
