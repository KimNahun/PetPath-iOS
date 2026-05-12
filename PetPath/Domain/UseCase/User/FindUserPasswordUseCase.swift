//
//  FindUserPasswordUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//
//

protocol FindUserPasswordUseCase {
    func execute(impUid: String, pw: String) async throws -> EmptyResponse
}

final class FindUserPasswordUseCaseImpl: FindUserPasswordUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(impUid: String, pw: String) async throws -> EmptyResponse {
        return try await repository.findUserPassword(impUid: impUid, pw: pw)
    }
}

