//
//  GetMatchedWalkInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Foundation

protocol GetMatchedWalkerInfoUseCase {
    func execute(request: GetMatchedWalkerInfoRequest) async throws -> GetMatchedWalkerInfoDTO
}

final class GetMatchedWalkerInfoUseCaseImpl: GetMatchedWalkerInfoUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetMatchedWalkerInfoRequest) async throws -> GetMatchedWalkerInfoDTO {
        return try await repository.getMatchedWalkerInfo(request: request)
    }
}
