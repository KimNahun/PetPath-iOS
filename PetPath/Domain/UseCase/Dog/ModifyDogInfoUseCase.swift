//
//  ModifyDogInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol ModifyDogInfoUseCase {
    func execute(request: ModifyDogInfoRequest) async throws -> EmptyResponse
}

final class ModifyDogInfoUseCaseImpl: ModifyDogInfoUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute(request: ModifyDogInfoRequest) async throws -> EmptyResponse {
        return try await repository.modifyDogInfo(request: request)
    }
}
