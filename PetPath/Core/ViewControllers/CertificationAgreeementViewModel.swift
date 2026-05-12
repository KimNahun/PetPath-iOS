//
//  CertificationAgreeementViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/13/25.
//

import Combine
import Foundation

final class CertificationAgreeementViewModel {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let findUserIdUseCase = FindUserIdUseCaseImpl(repository: UserRepositoryImpl())
    
    let resultPublisher = PassthroughSubject<(type: CertificationAgreementViewController.CertificationType, data: FindUserIdDTO?), Never>()
   
}

extension CertificationAgreeementViewModel {
    func findUserId(type: CertificationAgreementViewController.CertificationType) {
        Task {
            do {
                let response = try await findUserIdUseCase.execute(impUid: KeychainWorker.shared.read(key: .impUid) ?? "")
                resultPublisher.send((type, response))
            }  catch let error as CommonAPIError<FindUserIdError> {
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
                    case .certInfoNotFound, .impUidRequired, .inputValueNotValid: ToastMessenger.shared.showToast(message: error.message ?? "")
                    case .userNotSignUp:
                        resultPublisher.send((type, nil))
                    }
                }
            }
        }
    }
}
