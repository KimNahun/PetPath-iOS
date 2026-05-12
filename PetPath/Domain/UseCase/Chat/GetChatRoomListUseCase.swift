//
//  GetChatRoomListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Foundation

protocol GetChatRoomListUseCase {
    func execute(request: GetChatRoomListRequest) async throws -> [GetChatRoomListDTO]
}

final class GetChatRoomListUseCaseImpl: GetChatRoomListUseCase {
    
    private let repository: ChatRepository
    
    init(repository: ChatRepository) {
        self.repository = repository
    }
    
    func execute(request: GetChatRoomListRequest) async throws -> [GetChatRoomListDTO] {
        return try await repository.getChatRoomList(request: request)
    }
}
