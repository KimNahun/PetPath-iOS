//
//  ApplyWalkerUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/30/25.
//

import Foundation

protocol ApplyWalkerUseCase {
    func execute(request: ApplyWalkerRequest) async throws -> EmptyResponse
}

final class ApplyWalkerUseCaseImpl: ApplyWalkerUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: ApplyWalkerRequest) async throws -> EmptyResponse {
        return try await repository.applyWalker(request: request)
    }
}
