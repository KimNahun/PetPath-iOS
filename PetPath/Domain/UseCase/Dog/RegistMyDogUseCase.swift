//
//  RegistMyDogUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

protocol RegistMyDogUseCase {
    func execute(request: RegistMyDogRequest) async throws -> RegistMyDogDTO
}

final class RegistMyDogUseCaseImpl: RegistMyDogUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute(request: RegistMyDogRequest) async throws -> RegistMyDogDTO {
        return try await repository.registMyDog(request: request)
    }
}
