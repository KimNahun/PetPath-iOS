//
//  MainPageViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

final class MainPageViewModel {
    
    private let getMyDogListUseCase = GetMyDogListUseCaseImpl(repository: DogRepositoryImpl())
    private let getUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    private let getMainNoticeUseCase = GetMainNoticeUseCaseImpl(repository: UtilRepositoryImpl())
    private let getAvailablePayoutAmountUseCase = GetAvailablePayoutAmountUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getMainCurrentWalkListUsecase = GetMainCurrentWalkListUsecaseImpl(repository: WalkRepositoryImpl())
    private let getCardListUseCase = GetCardListUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getWalkerTrainStatusUseCase = GetWalkerTrainStatusUseCaseImpl(repository: WalkRepositoryImpl())
    private let getPushAlertSettingUseCase = GetPushAlertSettingUseCaseImpl(repository: UserRepositoryImpl())
    
    @Published var dogList: [DogData] = []
    @Published var noticeList: [GetMainNoticeDTO] = []
    @Published var payoutAmount: Int?
    @Published var currentWalks: [GetMainCurrentWalkListDTO] = []
    @Published var walkerRequireList: (trainSuccess: Bool?, newWalkSuccess: Bool?)
    @Published var isNewWalk: Bool?
    @Published var ownerRequireList: (dogSuccess: Bool?, cardSuccess: Bool?)
    @Published var userType: UserType?
    init() {
        
    }
}

extension MainPageViewModel {
    
    func getPushSetting() {
        Task {
            do {
                walkerRequireList.newWalkSuccess = try await getPushAlertSettingUseCase.execute().newWalk
                isNewWalk = walkerRequireList.newWalkSuccess
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
    
    func getUserInfo() {
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
    func getCardList() {
        Task {
            do {
                ownerRequireList.cardSuccess = try await !getCardListUseCase.execute().isEmpty
            } catch let error as CommonAPIError<GetCardListError> {
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
    func getTrainStatus() {
        Task {
            do {
                walkerRequireList.trainSuccess = try await getWalkerTrainStatusUseCase.execute().completed
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
    
    func getCurrentWalks() {
        Task {
            do {
                currentWalks = try await getMainCurrentWalkListUsecase.execute()
            } catch let error as CommonAPIError<GetMainCurrentWalkListError> {
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
    
    func getAvailablePayoutAmount() {
        Task {
            do {
                payoutAmount = try await getAvailablePayoutAmountUseCase.execute().amount
            } catch let error as CommonAPIError<GetAvailablePayoutAmountError> {
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
    
    func getMainNotice(type: UserType) {
        Task {
            do {
                noticeList = try await getMainNoticeUseCase.execute(request: .init(type: type))
            } catch let error as CommonAPIError<GetMainNoticeError> {
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
    
    func getMyDogList()  {
        Task {
            do {
                dogList = try await getMyDogListUseCase.execute()
                ownerRequireList.dogSuccess = !dogList.isEmpty
            } catch let error as CommonAPIError<GetMyDogListError> {
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
