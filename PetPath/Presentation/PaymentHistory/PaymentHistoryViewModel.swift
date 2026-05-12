//
//  PaymentHistoryViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Combine
import Foundation

final class PaymentHistoryViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getPaymentHistoryUseCase = GetPaymentHistoryUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    
    @Published var paymentHistoryList: [PaymentHistoryData] = []
    private(set) var userType: UserType = .unknown
    private var currentPage: Int = 0
    private var isLastPage = false
}

extension PaymentHistoryViewModel {
    func getUserInfo() {
        Task {
            do {
                userType = try await getUserInfoUseCase.execute().type ?? .unknown
            } catch let error as CommonAPIError<GetUserInfoError> {
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
    
    func getPaymentHistoryList(isReset: Bool) {
        Task {
            do {
                if isReset {
                    currentPage = 0
                    isLastPage = false
                }
                guard !isLastPage else { return }
                let response = try await getPaymentHistoryUseCase.execute(page: currentPage)
                if response.count < 10 {
                    isLastPage = true
                }
                if isReset {
                    paymentHistoryList = response
                } else {
                    paymentHistoryList.append(contentsOf: response)
                }
                currentPage += 1
            } catch let error as CommonAPIError<GetPaymentHistoryError> {
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
