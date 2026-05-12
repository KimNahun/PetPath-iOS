//
//  PayoutViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Combine
import Foundation

final class PayoutViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getAvailablePayoutAmountUseCase = GetAvailablePayoutAmountUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getPayoutHistoryUseCase = GetPayoutHistoryUseCaseImpl(repository: PaymentRepositoryImpl())
    private let requestPayoutUseCase = RequestPayoutUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getPayoutDetailUseCase = GetPayoutDetailUseCaseImpl(repository: PaymentRepositoryImpl())
    
    @Published var payoutAmount: Int?
    
    @Published var payoutHistoryList: [GetPayoutHistoryDTO] = []
    @Published var payoutDetail: GetPayoutDetailDTO?
    var selectedPk: Int?
    
    let successPublisher = PassthroughSubject<Void, Never>()
    
    func getPayoutDetail() {
        Task {
            do {
                payoutDetail = try await getPayoutDetailUseCase.execute(request: .init(pk: selectedPk ?? 0))
            } catch let error as CommonAPIError<GetPayoutDetailError> {
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
    
    func requestPayout() {
        Task {
            do {
                _ = try await requestPayoutUseCase.execute()
                ToastMessenger.shared.showToast(message: "정산 요청에 성공했습니다.")
                successPublisher.send()
            } catch let error as CommonAPIError<RequestPayoutError> {
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
    
    func getPayoutHistory() {
        Task {
            do {
                payoutHistoryList = try await getPayoutHistoryUseCase.execute()
            } catch let error as CommonAPIError<GetPayoutHistoryError> {
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
    
    func getAvailablePayoutAmount() {
        Task {
            do {
                payoutAmount = try await getAvailablePayoutAmountUseCase.execute().amount
            } catch let error as CommonAPIError<GetAvailablePayoutAmountError> {
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

extension PayoutViewModel {
 
    
}
