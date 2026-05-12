//
//  DeleteAccountUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/26/25.
//

import Foundation

protocol DeleteAccountUseCase {
    func execute(request: DeleteAccountRequest) async throws -> EmptyResponse
}

final class DeleteAccountUseCaseImpl: DeleteAccountUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute(request: DeleteAccountRequest) async throws -> EmptyResponse {
        return try await repository.deleteAccount(request: request)
    }
}
