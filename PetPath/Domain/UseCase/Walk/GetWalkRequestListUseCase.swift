//
//  GetWalkRequestListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/28/25.
//

import Foundation

protocol GetWalkRequestListUseCase {
    func execute(request: GetWalkRequestListRequest) async throws -> [GetWalkRequestListDTO]
}

final class GetWalkRequestListUseCaseImpl: GetWalkRequestListUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkRequestListRequest) async throws -> [GetWalkRequestListDTO] {
        return try await repository.getWalkRequestList(request: request)
    }
}
