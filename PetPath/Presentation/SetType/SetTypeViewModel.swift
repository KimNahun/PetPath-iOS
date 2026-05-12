//
//  SetTypeViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

final class SetTypeViewModel {
    
    private let setAccountTypeUseCase = SetAccountTypeUseCaseImpl(repository: UserRepositoryImpl())
    @Published var accountType: UserType = .unknown
    
    func setAccountType(type: UserType) {
        Task {
            do {
                _ = try await setAccountTypeUseCase.execute(type: type)
                self.accountType = type
            } catch let error as CommonAPIError<SetAccountTypeError> {
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
