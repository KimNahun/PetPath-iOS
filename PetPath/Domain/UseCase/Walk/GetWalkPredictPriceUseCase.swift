//
//  GetWalkPredictPriceUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/26/25.
//

import Foundation

protocol GetWalkPredictPriceUseCase {
    func execute(request: GetWalkPredictPriceRequest) async throws -> Int
}

final class GetWalkPredictPriceUseCaseImpl: GetWalkPredictPriceUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkPredictPriceRequest) async throws -> Int {
        return try await repository.getWalkPredictPrice(request: request)
    }
}
