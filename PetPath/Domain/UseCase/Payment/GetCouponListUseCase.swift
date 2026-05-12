//
//  GetCouponListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Foundation

protocol GetCouponListUseCase {
    func execute(request: GetCouponListRequest) async throws -> [GetCouponListDTO]
}

final class GetCouponListUseCaseImpl: GetCouponListUseCase {
    
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }
    
    func execute(request: GetCouponListRequest) async throws -> [GetCouponListDTO] {
        return try await repository.getCouponList(request: request)
    }
}
