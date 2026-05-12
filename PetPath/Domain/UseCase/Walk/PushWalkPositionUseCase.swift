//
//  PushWalkPositionUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

protocol PushWalkPositionUseCase {
    func execute(request: PushWalkPositionRequest) async throws -> EmptyResponse
}

final class PushWalkPositionUseCaseImpl: PushWalkPositionUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: PushWalkPositionRequest) async throws -> EmptyResponse {
        return try await repository.pushWalkPosition(request: request)
    }
   
}
