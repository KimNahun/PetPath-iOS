//
//  RequestWalkUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import Foundation

protocol RequestWalkUseCase {
    func execute(request: RequestWalkRequest) async throws -> EmptyResponse
}

final class RequestWalkUseCaseImpl: RequestWalkUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: RequestWalkRequest) async throws -> EmptyResponse {
        return try await repository.requstWalk(request: request)
    }
}
