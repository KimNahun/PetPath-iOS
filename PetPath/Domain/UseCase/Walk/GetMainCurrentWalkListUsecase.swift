//
//  GetMainCurrentWalkListUsecase.swift
//  PetPath
//
//  Created by 김나훈 on 5/18/25.
//

protocol GetMainCurrentWalkListUsecase {
    func execute() async throws -> [GetMainCurrentWalkListDTO]
}

final class GetMainCurrentWalkListUsecaseImpl: GetMainCurrentWalkListUsecase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute() async throws -> [GetMainCurrentWalkListDTO] {
        return try await repository.getMainCurrentWalkList()
    }
   
}
