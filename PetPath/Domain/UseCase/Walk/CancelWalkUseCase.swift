//
//  CancelWalkUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Foundation

protocol CancelWalkUseCase {
    func execute(request: CancelWalkRequest) async throws -> EmptyResponse
}

final class CancelWalkUseCaseImpl: CancelWalkUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: CancelWalkRequest) async throws -> EmptyResponse {
        return try await repository.cancelWalk(request: request)
    }
   
}
