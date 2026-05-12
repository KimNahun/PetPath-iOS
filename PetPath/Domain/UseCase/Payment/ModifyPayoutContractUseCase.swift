//
//  ModifyPayoutContractUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol ModifyPayoutContractUseCase {
    func execute(request: ModifyPayoutContractRequest) async throws -> EmptyResponse
}

final class ModifyPayoutContractUseCaseImpl: ModifyPayoutContractUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: ModifyPayoutContractRequest) async throws -> EmptyResponse {
        return try await repository.modifyPayoutContract(request: request)
    }
}
