//
//  GetCardListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Foundation

protocol GetCardListUseCase {
    func execute() async throws -> [CardData]
}

final class GetCardListUseCaseImpl: GetCardListUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [CardData] {
        return try await repository.getCardList()
    }
}
