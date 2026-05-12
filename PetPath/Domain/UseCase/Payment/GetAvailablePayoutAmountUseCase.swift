//
//  GetAvailablePayoutAmountUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol GetAvailablePayoutAmountUseCase {
    func execute() async throws -> GetAvailablePayoutAmountDTO
}

final class GetAvailablePayoutAmountUseCaseImpl: GetAvailablePayoutAmountUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> GetAvailablePayoutAmountDTO {
        return try await repository.getAvailablePayoutAmount()
    }
}
