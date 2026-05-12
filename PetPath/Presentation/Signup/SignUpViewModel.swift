//
//  SignUpViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Combine
import Foundation

final class SignUpViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case toggleAgreement(index: Int, isSelected: Bool)
        case toggleAllAgreements(Bool)
    }
    
    enum AgreementOutput {
        case toggleNextButton(isEnabled: Bool)
        case updateAllAgreementButton(isSelected: Bool)
        case updateAgreementStates(states: [Bool])
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<AgreementOutput, Never>()
    private let getIsEmailUsingUseCase = GetIsEmailUsingUseCaseImpl(repository: UserRepositoryImpl())
    private let signUpUseCase = SignUpUseCaseImpl(repository: UserRepositoryImpl())
    private var subscriptions = Set<AnyCancellable>()
    private var agreementStates: [Bool] = [false, false, false, false]
    @Published var isValidEmail: Bool = false
    @Published var getIsEmailUsingSuccess: Bool = false
    @Published var signUpSuccess: Bool = false
    
    @Published var passwordLetterSuccess: ProcessState = .common
    @Published var passwordCountSuccess: ProcessState = .common
    @Published var passwordMatchSuccess: ProcessState = .common
    
    @Published var isSignUpEnabled: Bool = false
    
    @Published var idErrorMessage: String = ""
    
    @Published var id: String = "" { didSet { validateEmail() } }
    @Published var mainPassword: String = "" { didSet { validateMainPassword() } }
    @Published var repeatPassword: String = "" { didSet { validateRepeatPassword() } }
    
    @Published var signupSource: SignupSourceType?
    @Published var signupDetail: String?
    @Published private(set) var isSourceValid: Bool = false
    
    init() {
        bindSignUpEnabled()
        
        $signupSource.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] source in
            if source != .etc {
                self?.signupDetail = nil
            }
        }.store(in: &subscriptions)
        
        Publishers.CombineLatest($signupSource, $signupDetail)
               .map { source, detail in
                   guard let source = source else { return false }
                   if source == .etc {
                       guard let detail = detail?.trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty else {
                           return false
                       }
                   }
                   return true
               }
               .assign(to: &$isSourceValid)
    }
    
    private func bindSignUpEnabled() {
        Publishers.CombineLatest3($passwordLetterSuccess, $passwordCountSuccess, $passwordMatchSuccess)
            .map { letter, count, match in
                let isLetterValid = (letter == .success)
                let isCountValid = (count == .success)
                let isMatchValid = (match == .success)
                return isLetterValid && isCountValid && isMatchValid
            }
            .assign(to: &$isSignUpEnabled)
    }
    
    
    func getIsUsingEmail() {
        Task {
            do {
                _ = try await getIsEmailUsingUseCase.execute(email: id)
                getIsEmailUsingSuccess = true
            } catch let error as CommonAPIError<GetIsEmailUsingError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        idErrorMessage = "네트워크 오류가 발생했습니다. 다시 시도해 주세요."
                    case .unidentified:
                        idErrorMessage = error.message ?? ""
                    }
                case .specific(let specificError):
                    switch specificError {
                    case .alreadyInUse, .inputValueNotValid: idErrorMessage = error.message ?? ""
                    }
                }
            }
        }
    }
    
    func signUp() {
        Task {
            do {
                if let source = signupSource {
                    _ = try await signUpUseCase.execute(request: .init(marketingAgree: agreementStates[3], impUid: KeychainWorker.shared.read(key: .impUid) ?? "", email: id, pw: mainPassword, source: source, sourceDetail: signupDetail))
                }
                signUpSuccess = true
            } catch let error as CommonAPIError<SignUpError> {
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
extension SignUpViewModel {
    // MARK: - Transform Function
    func agreementTransform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<AgreementOutput, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case let .toggleAgreement(index, isSelected):
                self.updateAgreementState(index: index, isSelected: isSelected)
                
            case let .toggleAllAgreements(isSelected):
                self.toggleAllAgreements(isSelected: isSelected)
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Helpers
    private func updateAgreementState(index: Int, isSelected: Bool) {
        agreementStates[index] = isSelected
        
        let requiredAgreementsChecked = agreementStates[0...2].allSatisfy { $0 }
        let isAllChecked = agreementStates.allSatisfy { $0 }
        
        outputSubject.send(.toggleNextButton(isEnabled: requiredAgreementsChecked))
        outputSubject.send(.updateAllAgreementButton(isSelected: isAllChecked))
        outputSubject.send(.updateAgreementStates(states: agreementStates))
    }
    
    private func toggleAllAgreements(isSelected: Bool) {
        agreementStates = [isSelected, isSelected, isSelected, isSelected]
        outputSubject.send(.toggleNextButton(isEnabled: isSelected))
        outputSubject.send(.updateAllAgreementButton(isSelected: isSelected))
        outputSubject.send(.updateAgreementStates(states: agreementStates))
    }
    // ???: 이거 이메일 양식 유효성 맞는지??
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        isValidEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: id)
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
