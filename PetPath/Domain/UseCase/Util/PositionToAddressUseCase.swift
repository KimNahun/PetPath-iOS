//
//  PositionToAddressUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import Foundation

protocol PositionToAddressUseCase {
    func execute(request: PositionToAddressRequest) async throws -> PositionToAddressDTO
}

final class PositionToAddressUseCaseImpl: PositionToAddressUseCase {
    
    private let repository: UtilRepository
    
    init(repository: UtilRepository) {
        self.repository = repository
    }
    
    func execute(request: PositionToAddressRequest) async throws -> PositionToAddressDTO {
        return try await repository.positionToAddress(request: request)
    }
}
