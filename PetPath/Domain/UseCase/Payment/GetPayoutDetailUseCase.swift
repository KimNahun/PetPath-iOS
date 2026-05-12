//
//  GetPayoutDetailUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol GetPayoutDetailUseCase {
    func execute(request: GetPayoutDetailRequest) async throws -> GetPayoutDetailDTO
}

final class GetPayoutDetailUseCaseImpl: GetPayoutDetailUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: GetPayoutDetailRequest) async throws -> GetPayoutDetailDTO {
        return try await repository.getPayoutDetail(request: request)
    }
}
