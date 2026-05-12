//
//  ChatRepository.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol ChatRepository {
    func getChatRoomList(request: GetChatRoomListRequest) async throws -> [GetChatRoomListDTO]
    func getUnReadChatIndex(request: GetUnreadChatIndexRequest) async throws -> GetUnreadChatIndexDTO
    func getChatHistory(request: GetChatHistoryRequest) async throws -> GetChatHistoryDTO
}
