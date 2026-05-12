//
//  AddCardUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/23/25.
//

import Foundation

protocol AddCardUseCase {
    func execute(request: AddCardRequest) async throws -> EmptyResponse
}

final class AddCardUseCaseImpl: AddCardUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: AddCardRequest) async throws -> EmptyResponse {
        return try await repository.addCard(request: request)
    }
}
