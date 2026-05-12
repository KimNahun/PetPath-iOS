//
//  GetDogCertInfoValidUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Foundation

protocol GetDogCertInfoValidUseCase {
    func execute(request: GetDogCertInfoValidRequest) async throws -> GetDogCertInfoValidDTO
}

final class GetDogCertInfoValidUseCaseImpl: GetDogCertInfoValidUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute(request: GetDogCertInfoValidRequest) async throws -> GetDogCertInfoValidDTO {
        return try await repository.getDogCertInfoValid(request: request)
    }
}
