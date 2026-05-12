//
//  FindUserIdUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

protocol FindUserIdUseCase {
    func execute(impUid: String) async throws -> FindUserIdDTO
}

final class FindUserIdUseCaseImpl: FindUserIdUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(impUid: String) async throws -> FindUserIdDTO {
        return try await repository.findUserId(impUid: impUid)
    }
}


