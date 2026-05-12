//
//  GetWalkDetailUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/29/25.
//

import Foundation

protocol GetWalkDetailUseCase {
    func execute(request: GetWalkDetailRequest) async throws -> GetWalkDetailDTO
}

final class GetWalkDetailUseCaseImpl: GetWalkDetailUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkDetailRequest) async throws -> GetWalkDetailDTO {
        return try await repository.getWalkDetail(request: request)
    }
}
