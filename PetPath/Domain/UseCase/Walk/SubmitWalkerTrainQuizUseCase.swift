//
//  SubmitWalkerTrainQuizUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

protocol SubmitWalkerTrainQuizUseCase {
    func execute(request: [SubmitWalkerTrainQuizRequest]) async throws -> SubmitWalkerTrainQuizDTO
}

final class SubmitWalkerTrainQuizUseCaseImpl: SubmitWalkerTrainQuizUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: [SubmitWalkerTrainQuizRequest]) async throws -> SubmitWalkerTrainQuizDTO {
        return try await repository.submitWalkerTrainQuiz(request: request)
    }
   
}
