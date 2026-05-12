//
//  CalcCancelWalkPenaltyUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol CalcCancelWalkPenaltyUseCase {
    func execute(request: CalcCancelWalkPenaltyRequest) async throws -> CalcCancelWalkPenaltyDTO
}

final class CalcCancelWalkPenaltyUseCaseImpl: CalcCancelWalkPenaltyUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: CalcCancelWalkPenaltyRequest) async throws -> CalcCancelWalkPenaltyDTO {
        return try await repository.calcCancelWalkPenalty(request: request)
    }
}
