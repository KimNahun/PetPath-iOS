//
//  GetWalkPaymentInfoUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Foundation

protocol GetWalkPaymentInfoUseCase {
    func execute(request: GetWalkPaymentInfoRequest) async throws -> GetWalkPaymentInfoDTO
}

final class GetWalkPaymentInfoUseCaseImpl: GetWalkPaymentInfoUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: GetWalkPaymentInfoRequest) async throws -> GetWalkPaymentInfoDTO {
        return try await repository.getWalkPaymentInfo(request: request)
    }
}
