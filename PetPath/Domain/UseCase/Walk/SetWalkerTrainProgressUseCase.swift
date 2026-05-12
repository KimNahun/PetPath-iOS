//
//  SetWalkerTrainProgressUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

protocol SetWalkerTrainProgressUseCase {
    func execute(request: SetWalkerTrainProgressRequest) async throws -> EmptyResponse
}

final class SetWalkerTrainProgressUseCaseImpl: SetWalkerTrainProgressUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: SetWalkerTrainProgressRequest) async throws -> EmptyResponse {
        return try await repository.setWalkerTrainProgress(request: request)
    }
   
}
