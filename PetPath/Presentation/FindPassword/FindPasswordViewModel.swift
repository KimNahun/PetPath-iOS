//
//  FindPasswordViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/13/25.
//

import Combine

final class FindPasswordViewModel {

    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private(set) var userId: FindUserIdDTO
    private let findUserPasswordUseCase = FindUserPasswordUseCaseImpl(repository: UserRepositoryImpl())
    @Published var passwordLetterSuccess: ProcessState = .common
    @Published var passwordCountSuccess: ProcessState = .common
    @Published var passwordMatchSuccess: ProcessState = .common
    @Published var isChangeEnabled: Bool = false
    
    
    @Published var mainPassword: String = "" { didSet { validateMainPassword() } }
    @Published var repeatPassword: String = "" { didSet { validateRepeatPassword() } }
    let successPublisher = PassthroughSubject<Void, Never>()
 
    init(userId: FindUserIdDTO) {
        self.userId = userId
        bindSignUpEnabled()
    }

    func findUserPassword() {
        Task {
            do {
                _ = try await findUserPasswordUseCase.execute(impUid: KeychainWorker.shared.read(key: .impUid) ?? "", pw: mainPassword)
                successPublisher.send()
            } catch let error as CommonAPIError<FindUserPasswordError> {
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

extension FindPasswordViewModel {
    private func bindSignUpEnabled() {
        Publishers.CombineLatest3($passwordLetterSuccess, $passwordCountSuccess, $passwordMatchSuccess)
            .map { letter, count, match in
                let isLetterValid = (letter == .success)
                let isCountValid = (count == .success)
                let isMatchValid = (match == .success)
                return isLetterValid && isCountValid && isMatchValid
            }.assign(to: &$isChangeEnabled)
    }
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
    }
}
