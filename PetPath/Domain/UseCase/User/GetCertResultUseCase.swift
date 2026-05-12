//
//  GetCertResultUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//
//

protocol GetCertResultUseCase {
    func execute(impUid: String) async throws -> EmptyResponse
}

final class GetCertResultUseCaseImpl: GetCertResultUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(impUid: String) async throws -> EmptyResponse {
        return try await repository.getCertResult(impUid: impUid)
    }
}

