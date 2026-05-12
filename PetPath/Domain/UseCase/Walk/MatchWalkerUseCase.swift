//
//  MatchWalkerUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Foundation

protocol MatchWalkerUseCase {
    func execute(request: MatchWalkerRequest) async throws -> EmptyResponse
}

final class MatchWalkerUseCaseImpl: MatchWalkerUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: MatchWalkerRequest) async throws -> EmptyResponse {
        return try await repository.matchWalker(request: request)
    }
}
