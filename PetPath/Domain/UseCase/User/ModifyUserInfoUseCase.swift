//
//  ModifyUserInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/25/25.
//

import Foundation

protocol ModifyUserInfoUseCase {
    func execute(request: ModifyUserInfoRequest) async throws -> ModifyUserInfoDTO
}

final class ModifyUserInfoUseCaseImpl: ModifyUserInfoUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute(request: ModifyUserInfoRequest) async throws -> ModifyUserInfoDTO {
        return try await repository.modifyUserInfo(request: request)
    }
}
