//
//  GetApplyWalkerListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Foundation

protocol GetApplyWalkerListUseCase {
    func execute(request: GetApplyWalkerListRequest) async throws -> [GetApplyWalkerListDTO]
}

final class GetApplyWalkerListUseCaseImpl: GetApplyWalkerListUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetApplyWalkerListRequest) async throws -> [GetApplyWalkerListDTO] {
        return try await repository.getApplyWalkerList(request: request)
    }
}
