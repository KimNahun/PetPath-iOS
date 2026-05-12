//
//  SignInViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Combine
import Foundation

final class SignInViewModel {
    
    // MARK: - Properties
    
    private var subscriptions: Set<AnyCancellable> = []
    private let signInUseCase = SignInUseCaseImpl(repository: UserRepositoryImpl())
    private let getUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    private let setPushTokenUseCase = SetPushTokenUseCaseImpl(repository: UserRepositoryImpl())
    
    @Published var id: String = ""
    @Published var password: String = ""
    @Published var issignInButtonEnabled = false
    @Published var signInErrorResponse: String = ""
    @Published var userType: UserType? = nil
    
    // MARK: - Initialization
    
    init() {
        bind()
    }
    
    private func bind() {
        Publishers.CombineLatest($id, $password).map { !$0.isEmpty && !$1.isEmpty }.assign(to: &$issignInButtonEnabled)
    }
    
}

extension SignInViewModel {
    private func setPushToken() {
        if let token = KeychainWorker.shared.read(key: .fcm) {
            Task {
                do {
                    _ = try await setPushTokenUseCase.execute(request: .init(token: token))
                } catch let error as CommonAPIError<SetPushTokenError> {
                    Log.make().debug("\(error.message ?? "")")
                }
            }
        }
    }
    func signIn() {
        Task {
            do {
                _ = try await signInUseCase.execute(email: id, pw: password)
                getUserInfo()
                setPushToken()
            } catch let error as CommonAPIError<SignInError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        signInErrorResponse = "네트워크 오류가 발생했습니다. 다시 시도해 주세요."
                    case .unidentified:
                        signInErrorResponse = error.message ?? ""
                    }
                case .specific(let specificError):
                    switch specificError {
                    case .userNotFound:
                        signInErrorResponse = "계정 혹은 비밀번호가 일치하지 않습니다."
                    case .formInputRequired:
                        signInErrorResponse = error.message ?? ""
                    }
                }
            }
        }
    }
    private func getUserInfo() {
        Task {
            do {
                userType = try await getUserInfoUseCase.execute().type
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
