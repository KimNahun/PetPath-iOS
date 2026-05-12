//
//  StartWalkUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol StartWalkUseCase {
    func execute(request: StartOrEndWalkRequest) async throws -> EmptyResponse
}

final class StartWalkUseCaseImpl: StartWalkUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: StartOrEndWalkRequest) async throws -> EmptyResponse {
        return try await repository.startWalk(request: request)
    }
   
}
