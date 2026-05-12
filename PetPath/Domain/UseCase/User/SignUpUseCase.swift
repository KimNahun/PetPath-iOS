//
//  SignUpUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

protocol SignUpUseCase {
    func execute(request: SignUpRequest) async throws -> SignUpDTO
}

final class SignUpUseCaseImpl: SignUpUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(request: SignUpRequest) async throws -> SignUpDTO {
        return try await repository.signUp(request: request)
    }
}
