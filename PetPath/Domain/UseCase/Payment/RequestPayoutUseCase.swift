//
//  RequestPayoutUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol RequestPayoutUseCase {
    func execute() async throws -> EmptyResponse
}

final class RequestPayoutUseCaseImpl: RequestPayoutUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> EmptyResponse {
        return try await repository.requestPayout()
    }
}
