//
//  GetUserInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

protocol GetUserInfoUseCase {
    func execute() async throws -> GetUserInfoDTO
}

final class GetUserInfoUseCaseImpl: GetUserInfoUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> GetUserInfoDTO {
        return try await repository.getUserInfo()
    }
}
