//
//  GetWalkerTrainContentUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

protocol GetWalkerTrainContentUseCase {
    func execute(request: GetWalkerTrainContentRequest) async throws -> GetWalkerTrainContentDTO
}

final class GetWalkerTrainContentUseCaseImpl: GetWalkerTrainContentUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: GetWalkerTrainContentRequest) async throws -> GetWalkerTrainContentDTO {
        return try await repository.getWalkerTrainContent(request: request)
    }
   
}
