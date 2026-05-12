//
//  GetWalkHistoryListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Foundation

protocol GetWalkHistoryListUseCase {
    func execute(request: GetWalkHistoryListRequest) async throws -> [GetWalkHistoryListDTO]
}

final class GetWalkHistoryListUseCaseImpl: GetWalkHistoryListUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkHistoryListRequest) async throws -> [GetWalkHistoryListDTO] {
        return try await repository.getWalkHistoryList(request: request)
    }
}
