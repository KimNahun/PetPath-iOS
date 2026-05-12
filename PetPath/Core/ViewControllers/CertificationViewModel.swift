//
//  CertificationViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/13/25.
//

import Combine
import Foundation

final class CertificationViewModel {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let getCertResultUseCase = GetCertResultUseCaseImpl(repository: UserRepositoryImpl())
    
    let errorPublisher = PassthroughSubject<GetCertResultErrorSpecific?, Never>()
}

extension CertificationViewModel {
    func getCertResult(impUid: String) {
        Task {
            do {
                _ = try await getCertResultUseCase.execute(impUid: impUid)
                errorPublisher.send(nil)
            }  catch let error as CommonAPIError<GetCertResultError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific(let specificError):
                    errorPublisher.send(specificError)
                }
            }
        }
    }
}
