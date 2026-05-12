//
//  GetWalkerTrainListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

protocol GetWalkerTrainListUseCase {
    func execute() async throws -> [GetWalkerTrainListDTO]
}

final class GetWalkerTrainListUseCaseImpl: GetWalkerTrainListUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute() async throws -> [GetWalkerTrainListDTO] {
        return try await repository.getWalkerTrainList()
    }
   
}
