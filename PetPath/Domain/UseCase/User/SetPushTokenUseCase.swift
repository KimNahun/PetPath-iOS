//
//  SetPushTokenUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Foundation

protocol SetPushTokenUseCase {
    func execute(request: SetPushTokenRequest) async throws -> EmptyResponse
}

final class SetPushTokenUseCaseImpl: SetPushTokenUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute(request: SetPushTokenRequest) async throws -> EmptyResponse {
        return try await repository.setPushToken(request: request)
    }
}
