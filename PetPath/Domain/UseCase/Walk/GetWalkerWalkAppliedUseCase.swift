//
//  GetWalkerWalkAppliedUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Foundation

protocol GetWalkerWalkAppliedUseCase {
    func execute(request: GetWalkerWalkAppliedRequest) async throws -> GetWalkerWalkAppliedDTO
}

final class GetWalkerWalkAppliedUseCaseImpl: GetWalkerWalkAppliedUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkerWalkAppliedRequest) async throws -> GetWalkerWalkAppliedDTO {
        return try await repository.getWalkerWalkApplied(request: request)
    }
    
}
