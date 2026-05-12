//
//  GetPayoutHistoryUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol GetPayoutHistoryUseCase {
    func execute() async throws -> [GetPayoutHistoryDTO]
}

final class GetPayoutHistoryUseCaseImpl: GetPayoutHistoryUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [GetPayoutHistoryDTO] {
        return try await repository.getPayoutHistory()
    }
}
