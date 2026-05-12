//
//  DogDetailViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import Foundation

final class DogDetailViewModel {
    
    private let getMyDogDetailUseCase = GetMyDogDetailUseCaseImpl(repository: DogRepositoryImpl())
    private let deleteMyDogDetailUseCase = DeleteMyDogUseCaseImpl(repository: DogRepositoryImpl())
    let dogId: Int
    
    @Published var dogDetail = GetMyDogDetailDTO()
    let deleteSuccess = PassthroughSubject<Void, Never>()
    
    init(dogId: Int) {
        self.dogId = dogId
    }
    
    func getMyDogDetail()  {
        Task {
            do {
                dogDetail = try await getMyDogDetailUseCase.execute(id: dogId)
            } catch let error as CommonAPIError<GetMyDogDetailError> {
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
    
    func deleteMyDog() {
        Task {
            do {
                _ = try await deleteMyDogDetailUseCase.execute(id: dogId)
                deleteSuccess.send()
            } catch let error as CommonAPIError<DeleteMyDogError> {
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
