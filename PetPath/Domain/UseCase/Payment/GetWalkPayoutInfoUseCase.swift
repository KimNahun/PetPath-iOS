//
//  GetWalkPayoutInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Foundation

protocol GetWalkPayoutInfoUseCase {
    func execute(request: GetWalkPayoutInfoRequest) async throws -> GetWalkPayoutInfoDTO
}

final class GetWalkPayoutInfoUseCaseImpl: GetWalkPayoutInfoUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkPayoutInfoRequest) async throws -> GetWalkPayoutInfoDTO {
        return try await repository.getWalkPayoutInfo(request: request)
    }
}
