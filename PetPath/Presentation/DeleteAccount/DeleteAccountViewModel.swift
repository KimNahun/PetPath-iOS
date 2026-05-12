//
//  DeleteAccountViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/21/25.
//

import Combine
import Foundation

final class DeleteAccountViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    private let deleteAccountUseCase = DeleteAccountUseCaseImpl(repository: UserRepositoryImpl())
    @Published var userDTO: GetUserInfoDTO?
    @Published var checkList: [Bool] = [false, false, false, false]
    
    @Published var deleteRequest = DeleteAccountRequest()
    @Published var isAgreementChecked: Bool = false
    @Published var buttonEnabled: Bool = false
    @Published var deleteFailReason: String?
    
    let deleteSuccessPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        setupBindings()
    }
    
    func deleteAccount() {
        Task {
            do {
                _ = try await deleteAccountUseCase.execute(request: deleteRequest)
                deleteSuccessPublisher.send()
            } catch let error as CommonAPIError<DeleteAccountError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific(let specificError):
                    switch specificError {
                    case .notDeletableAccount:
                        if let rawData = error.data as? Data {
                            if let commonResponse = try? JSONDecoder().decode([CommonResponse<NotDeletableAccountResponse>].self, from: rawData),
                               let first = commonResponse.first?.data {
                                deleteFailReason = first.reason
                            }
                        }
                    default:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                }
            }
        }
    }
    
    func getUserInfo() {
        Task {
            do {
                userDTO = try await getUserInfoUseCase.execute()
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
}

extension DeleteAccountViewModel {
    private func setupBindings() {
        Publishers.CombineLatest(
            $deleteRequest,
            $isAgreementChecked
        )
        .sink { [weak self] deleteRequest, isAgreementChecked in
            guard let self = self else { return }
            self.buttonEnabled = self.isButtonEnabled(deleteRequest: deleteRequest, isAgreementChecked: isAgreementChecked)
        }.store(in: &subscriptions)
    }
    
    private func isButtonEnabled(deleteRequest: DeleteAccountRequest, isAgreementChecked: Bool) -> Bool {
        guard let reason = deleteRequest.reason, !reason.isEmpty else { return false }
        
        if reason == DeleteReasonViewController.ReasonItem.etc.rawValue {
            guard let reasonDetail = deleteRequest.reasonDetail, !reasonDetail.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        }
        
        return isAgreementChecked
    }
    
}
