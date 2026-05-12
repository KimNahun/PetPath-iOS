//
//  GetPayoutContractUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol GetPayoutContractUseCase {
    func execute() async throws -> GetPayoutContractDTO
}

final class GetPayoutContractUseCaseImpl: GetPayoutContractUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> GetPayoutContractDTO {
        return try await repository.getPayoutContract()
    }
}
