//
//  GetPaymentHistoryUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Foundation

protocol GetPaymentHistoryUseCase {
    func execute(page: Int) async throws -> [PaymentHistoryData]
}

final class GetPaymentHistoryUseCaseImpl: GetPaymentHistoryUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(page: Int) async throws -> [PaymentHistoryData] {
        return try await repository.getPaymentHistory(page: page)
    }
}
