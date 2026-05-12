//
//  GetAvailableCouponListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/2/25.
//

import Foundation

protocol GetAvailableCouponListUseCase {
    func execute(request: GetAvailableCouponListRequest) async throws -> [GetAvailableCouponListDTO]
}

final class GetAvailableCouponListUseCaseImpl: GetAvailableCouponListUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: GetAvailableCouponListRequest) async throws -> [GetAvailableCouponListDTO] {
        return try await repository.getAvailableCouponList(request: request)
    }
}
