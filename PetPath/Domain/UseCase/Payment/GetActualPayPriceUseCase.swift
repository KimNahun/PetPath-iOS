//
//  GetActualPayPriceUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Foundation

protocol GetActualPayPriceUseCase {
    func execute(request: GetActualPayPriceRequest) async throws -> GetActualPayPriceDTO
}

final class GetActualPayPriceUseCaseImpl: GetActualPayPriceUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: GetActualPayPriceRequest) async throws -> GetActualPayPriceDTO {
        return try await repository.getActualPayPrice(request: request)
    }
}
