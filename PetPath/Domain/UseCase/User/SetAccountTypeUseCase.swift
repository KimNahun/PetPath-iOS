//
//  SetAccountTypeUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

protocol SetAccountTypeUseCase {
    func execute(type: UserType) async throws -> SetAccountTypeDTO
}

final class SetAccountTypeUseCaseImpl: SetAccountTypeUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute(type: UserType) async throws -> SetAccountTypeDTO {
        return try await repository.setAccountType(type: type)
    }
}
