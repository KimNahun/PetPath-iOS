//
//  SettingViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Combine

final class SettingViewModel {
    
    private let getUserInfoUseCase: GetUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    private let setAccountTypeUseCase = SetAccountTypeUseCaseImpl(repository: UserRepositoryImpl())
    private let getWalkerTrainStatusUseCase = GetWalkerTrainStatusUseCaseImpl(repository: WalkRepositoryImpl())
    
    @Published var userData: GetUserInfoDTO = .init(uid: 0, name: "", type: nil, profileImg: "", token: "")
    @Published var trainSuccess: Bool?
    
    func getWalkerTrainStatus() {
        Task {
            do {
                let response = try await getWalkerTrainStatusUseCase.execute()
                trainSuccess = response.completed
            } catch let error as CommonAPIError<GetWalkerTrainStatusError> {
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
    
    func getUserInfo() {
        Task {
            do {
                let response = try await getUserInfoUseCase.execute()
                userData = response
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
    func changeUserType() {
        let type: UserType = userData.type == .owner ? .walker : .owner
        Task {
            do {
                _ = try await setAccountTypeUseCase.execute(type: type)
                if userData.type == .owner {
                    userData.type = .walker
                } else {
                    userData.type = .owner
                }
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
