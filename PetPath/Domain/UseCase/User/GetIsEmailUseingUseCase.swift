//
//  GetIsEmailUseingUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

protocol GetIsEmailUsingUseCase {
    func execute(email: String) async throws -> EmptyResponse
}

final class GetIsEmailUsingUseCaseImpl: GetIsEmailUsingUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(email: String) async throws -> EmptyResponse {
        return try await repository.getIsEmailUsing(email: email)
    }
}
