//
//  GetChatRoomList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetChatRoomListRequest: Encodable {
    let page: Int
}

struct GetChatRoomListDTO: Decodable, Hashable {
    let roomId: Int
    let title: String
    let lastChatContent: String?
    let lastChatAt: String?
    let unreadMessage: Int?
    let profileImage: [String]
    let active: Bool
    let status: WalkStatus
}
