//
//  GetMyDogDetailUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol GetMyDogDetailUseCase {
    func execute(id: Int) async throws -> GetMyDogDetailDTO
}

final class GetMyDogDetailUseCaseImpl: GetMyDogDetailUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> GetMyDogDetailDTO {
        return try await repository.getMyDogDetail(id: id)
    }
}
