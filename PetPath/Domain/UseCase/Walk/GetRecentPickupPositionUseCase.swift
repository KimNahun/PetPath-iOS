//
//  GetRecentPickupPositionUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Foundation

protocol GetRecentPickupPositionUseCase {
    func execute() async throws -> [GetRecentPickupPositionDTO]
}

final class GetRecentPickupPositionUseCaseImpl: GetRecentPickupPositionUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [GetRecentPickupPositionDTO] {
        return try await repository.getRecentPickupPosition()
    }
}
