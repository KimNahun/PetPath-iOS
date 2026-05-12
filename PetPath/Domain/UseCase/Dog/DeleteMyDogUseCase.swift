//
//  DeleteMyDogUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol DeleteMyDogUseCase {
    func execute(id: Int) async throws -> EmptyResponse
}

final class DeleteMyDogUseCaseImpl: DeleteMyDogUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> EmptyResponse {
        return try await repository.deleteMyDog(id: id)
    }
}

