//
//  GetUnreadChatIndex.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetUnreadChatIndexRequest: Encodable {
    let chatId: Int
}

struct GetUnreadChatIndexDTO: Decodable {
    let untilReadIndex: Int
    let otherSideReadIndex: Int
    let lastChatIndex: Int
}
