//
//  GetMyDogListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

protocol GetMyDogListUseCase {
    func execute() async throws -> [DogData]
}

final class GetMyDogListUseCaseImpl: GetMyDogListUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [DogData] {
        return try await repository.getMyDogList()
    }
}
