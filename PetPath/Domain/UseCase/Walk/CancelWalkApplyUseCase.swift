//
//  CancelWalkApplyUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Foundation

protocol CancelWalkApplyUseCase {
    func execute(request: CancelWalkApplyRequest) async throws -> EmptyResponse
}

final class CancelWalkApplyUseCaseImpl: CancelWalkApplyUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: CancelWalkApplyRequest) async throws -> EmptyResponse {
        return try await repository.cancelWalkApply(request: request)
    }
    
}
