//
//  ModifyUserInfoViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/25/25.
//

import Combine
import Foundation

final class ModifyUserInfoViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getUserFullInfoUseCase = GetUserFullInfoUseCaseImpl(repository: UserRepositoryImpl())
    private let modifyUserInfoUseCase = ModifyUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    private let fileUploadUseCase = FileUploadUseCaseImpl(repository: UtilRepositoryImpl())
    
    @Published var userInfo: GetUserFullInfoDTO?
    @Published var profileToken: String = ""

    @Published var modifyRequest: ModifyUserInfoRequest = .init(profileImage: nil, newPw: nil)
    
    @Published var passwordLetterSuccess: ProcessState = .common
    @Published var passwordCountSuccess: ProcessState = .common
    @Published var passwordMatchSuccess: ProcessState = .common
    
    @Published var mainPassword: String = "" { didSet { validateMainPassword() } }
    @Published var repeatPassword: String = "" { didSet { validateRepeatPassword() } }
    
    let popPublisher = PassthroughSubject<Void, Never>()
}

extension ModifyUserInfoViewModel {
    func fileUpload(imageData: Data) {
        Task {
            do {
                let token = try await fileUploadUseCase.execute(fileData: imageData, fileName: "dog_profile5.jpg")
                modifyRequest.profileImage = token
            } catch let error as CommonAPIError<FileUploadError> {
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
    func getUserFullInfo() {
        Task {
            do {
                userInfo = try await getUserFullInfoUseCase.execute()
            } catch let error as CommonAPIError<GetUserFullInfoError> {
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
    func modifyUser() {
        Task {
            do {
                _ = try await modifyUserInfoUseCase.execute(request: modifyRequest)
                popPublisher.send()
                ToastMessenger.shared.showToast(message: "회원정보 수정이 완료되었습니다.")
            } catch let error as CommonAPIError<ModifyUserInfoError> {
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

extension ModifyUserInfoViewModel {
    private func validateMainPassword() {
        validateLetter()
        validateCount()
        validateRepeatPassword()
        func validateLetter() {
            if mainPassword.isEmpty {
                passwordLetterSuccess = .common
                return
            }
            let letterRegex = "[A-Za-z]"
            let numberRegex = "[0-9]"
            let specialCharRegex = "[!@#$%^&*?]"
            let letterMatch = mainPassword.range(of: letterRegex, options: .regularExpression) != nil
            let numberMatch = mainPassword.range(of: numberRegex, options: .regularExpression) != nil
            let specialCharMatch = mainPassword.range(of: specialCharRegex, options: .regularExpression) != nil
            let categoryCount = [letterMatch, numberMatch, specialCharMatch].filter { $0 }.count
            passwordLetterSuccess = categoryCount >= 2 ? .success : .fail
        }
        
        func validateCount() {
            if mainPassword.isEmpty {
                passwordCountSuccess = .common
                return
            }
            passwordCountSuccess = mainPassword.count >= 8 ? .success : .fail
        }
    }
    private func validateRepeatPassword() {
        if mainPassword.isEmpty && repeatPassword.isEmpty { passwordMatchSuccess = .common }
        else if mainPassword.isEmpty && !repeatPassword.isEmpty { passwordMatchSuccess = .fail }
        else if !mainPassword.isEmpty && repeatPassword.isEmpty { passwordMatchSuccess = .common }
        else {
            passwordMatchSuccess = mainPassword == repeatPassword ? .success : .fail
        }
        let isValid = passwordLetterSuccess == .success &&
                          passwordCountSuccess == .success &&
                          passwordMatchSuccess == .success

        modifyRequest.newPw = isValid ? mainPassword : nil
    }
}

