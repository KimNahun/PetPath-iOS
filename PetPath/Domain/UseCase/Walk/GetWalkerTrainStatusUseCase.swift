//
//  GetWalkerTrainStatusUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

protocol GetWalkerTrainStatusUseCase {
    func execute() async throws -> GetWalkerTrainStatusDTO
}

final class GetWalkerTrainStatusUseCaseImpl: GetWalkerTrainStatusUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute() async throws -> GetWalkerTrainStatusDTO {
        return try await repository.getWalkerTrainStatus()
    }
   
}
