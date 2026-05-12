//
//  GetWalkerTrainQuizUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

protocol GetWalkerTrainQuizUseCase {
    func execute() async throws -> [GetWalkerTrainQuizDTO]
}

final class GetWalkerTrainQuizUseCaseImpl: GetWalkerTrainQuizUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute() async throws -> [GetWalkerTrainQuizDTO] {
        return try await repository.getWalkerTrainQuiz()
    }
   
}
