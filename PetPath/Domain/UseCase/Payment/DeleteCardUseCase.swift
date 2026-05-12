//
//  DeleteCardUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Foundation

protocol DeleteCardUseCase {
    func execute(request: DeleteCardRequest) async throws -> EmptyResponse
}

final class DeleteCardUseCaseImpl: DeleteCardUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: DeleteCardRequest) async throws -> EmptyResponse {
        return try await repository.deleteCard(request: request)
    }
}
