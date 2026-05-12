//
//  PushViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import Foundation

final class PushViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getPushAlertSettingUseCase = GetPushAlertSettingUseCaseImpl(repository: UserRepositoryImpl())
    private let modifyPushAlertSettingUseCase = ModifyPushAlertSettingUseCaseImpl(repository: UserRepositoryImpl())
    private let positionToAddressUseCase = PositionToAddressUseCaseImpl(repository: UtilRepositoryImpl())

    @Published var pushAlertSetting: GetPushAlertSettingDTO?
    var nowLocation: (y: Double, x: Double)?
    @Published var positionResponse: PositionToAddressDTO?
    
    var modifyRequest: ModifyPushAlertSettingRequest?
    let modifySuccessPublisher = PassthroughSubject<Void, Never>()
    
}

extension PushViewModel {
    
    func positionToAddress(lat: Double, lng: Double) {
         Task {
             do {
                 positionResponse = try await positionToAddressUseCase.execute(request: PositionToAddressRequest(y: lat, x: lng))
             } catch let error as CommonAPIError<PositionToAddressError> {
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
    func getPushAlertSetting() {
        Task {
            do {
                let response = try await getPushAlertSettingUseCase.execute()
                pushAlertSetting = response
                modifyRequest = response.toModifyRequest()
            } catch let error as CommonAPIError<GetPushAlertSettingError> {
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
    func modifyPushAlertSetting(isRange: Bool = false) {
        if let modifyRequest = modifyRequest {
            Task {
                do {
                    _ = try await modifyPushAlertSettingUseCase.execute(request: modifyRequest)
                    modifySuccessPublisher.send()
                } catch let error as CommonAPIError<ModifyPushAlertSettingError> {
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
}
