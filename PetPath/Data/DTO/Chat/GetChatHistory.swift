//
//  GetChatHistory.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetChatHistoryRequest: Encodable {
    let chatId: Int
    let cursor: Int
}

struct GetChatHistoryDTO: Decodable {
    let chatIndex: Int
    let sender: Int
    let type: String
    let content: String
    let createAt: String
}
