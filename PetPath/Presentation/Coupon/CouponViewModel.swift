//
//  CouponViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import Foundation

final class CouponViewModel {
    
    // MARK: - Properties
    private let getCouponListUseCase = GetCouponListUseCaseImpl(repository: PaymentRepositoryImpl())
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var couponList: [GetCouponListDTO] = []
    @Published var fetchType: CouponType = .active
    
    // MARK: - Initialization
    
    init() {
        bind()
    }
    
    private func bind() {
        $fetchType.dropFirst().sink { [weak self] _ in
            self?.getCouponList()
        }.store(in: &subscriptions)
    }
    
}

extension CouponViewModel {
    func getCouponList() {
        Task {
            do {
                couponList = try await getCouponListUseCase.execute(request: .init(type: fetchType))
            } catch let error as CommonAPIError<GetCouponListError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific:
                    ToastMessenger.shared.showToast(message: error.message ?? "")
                }
            }
        }
    }
}
