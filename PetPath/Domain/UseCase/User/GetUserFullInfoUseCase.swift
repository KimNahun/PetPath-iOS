//
//  GetUserFullInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/25/25.
//

import Foundation

protocol GetUserFullInfoUseCase {
    func execute() async throws -> GetUserFullInfoDTO
}

final class GetUserFullInfoUseCaseImpl: GetUserFullInfoUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute() async throws -> GetUserFullInfoDTO {
        return try await repository.getUserFullInfo()
    }
}
