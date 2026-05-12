//
//  SignInUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/4/25.
//

import Foundation

protocol SignInUseCase {
    func execute(email: String, pw: String) async throws -> SignInDTO
}

final class SignInUseCaseImpl: SignInUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(email: String, pw: String) async throws -> SignInDTO {
        return try await repository.signIn(email: email, pw: pw)
    }
}
