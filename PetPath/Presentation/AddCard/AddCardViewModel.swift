//
//  AddCardViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import Foundation

final class AddCardViewModel {
    
    private let addCardUseCase = AddCardUseCaseImpl(repository: PaymentRepositoryImpl())
    
    @Published var addCardForm = AddCardForm()
    @Published var addButtonEnabled = false
    let successPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        setupBindings()
    }
    
    func addCard() {
        Task {
            do {
                _ = try await addCardUseCase.execute(request: addCardForm.toRequest())
                ToastMessenger.shared.showToast(message: "카드를 등록했습니다.")
                successPublisher.send()
            } catch let error as CommonAPIError<AddCardError> {
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

extension AddCardViewModel {
    private func setupBindings() {
        $addCardForm.map { form in
            let cardValid = form.cardParts.count == 4 && form.cardParts.allSatisfy { $0.count == 4 }
            
            let expiryValid = form.expiryYear.count == 4 && form.expiryMonth.count == 2
            
            let birthValid = form.birthYear.count == 4 &&
            form.birthMonth.count >= 1 &&
            form.birthDay.count >= 1
            
            let pwdValid = form.pwd.count == 2
            
            return cardValid && expiryValid && birthValid && pwdValid
        }.removeDuplicates().assign(to: &$addButtonEnabled)
    }
}
