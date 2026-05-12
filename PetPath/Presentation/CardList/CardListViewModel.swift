//
//  CardListViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import Foundation

final class CardListViewModel {
    
    private let getCardListUseCase = GetCardListUseCaseImpl(repository: PaymentRepositoryImpl())
    private let deleteCardUseCase = DeleteCardUseCaseImpl(repository: PaymentRepositoryImpl())
    
    @Published var cardList: [CardData] = []
    let lastCardFailPublisher = PassthroughSubject<Void, Never>()
    
    func getCardList() {
        Task {
            do {
                cardList = try await getCardListUseCase.execute()
            } catch let error as CommonAPIError<GetCardListError> {
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
    
    func deleteCard(id: String) {
        Task {
            do {
                _ = try await deleteCardUseCase.execute(request: DeleteCardRequest(cardId: id))
                cardList = cardList.filter { $0.cardId != id }
                ToastMessenger.shared.showToast(message: "카드를 삭제했습니다.")
            } catch let error as CommonAPIError<DeleteCardError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific(let specific):
                    switch specific {
                    case .lastCardAndActiveWalkExist: lastCardFailPublisher.send()
                    default: ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                }
            }
        }
    }
}
