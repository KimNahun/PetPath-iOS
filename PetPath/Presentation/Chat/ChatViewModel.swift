//
//  ChatViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import Foundation

final class ChatViewModel: Reportable {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    @Published var activeWalks: [GetChatRoomListDTO] = []
    @Published var completedWalks: [GetChatRoomListDTO] = []
    private let getChatRoomListUseCase = GetChatRoomListUseCaseImpl(repository: ChatRepositoryImpl())
    private let getWalkDetailUseCase = GetWalkDetailUseCaseImpl(repository: WalkRepositoryImpl())
    private let requestReportUseCase = RequestReportUseCaseImpl(repository: WalkRepositoryImpl())
    private let getUserInfoUseCase: GetUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    
    let reportSuccessPublisher = PassthroughSubject<Void, Never>()
    @Published var userType: UserType?
    
    private var currentPage: Int = 0
    var id: Int = 0
    private var isLastPage = false
    @Published var walkDetail: GetWalkDetailDTO?
}

extension ChatViewModel {
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
    func report(content: String) {
        Task {
            do {
                _ = try await requestReportUseCase.execute(request: .init(walkId: Int(id), content: content))
                reportSuccessPublisher.send()
            } catch let error as CommonAPIError<RequestReportError> {
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
    func getWalkDetail(id: Int) {
        Task {
            do {
                walkDetail = try await getWalkDetailUseCase.execute(request: .init(walk: id))
            } catch let error as CommonAPIError<GetWalkDetailError> {
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
    
   
    @MainActor
    func getChatRoomList() {
        Task {
            do {
                var page = 0
                var allResponses: [(Int, [GetChatRoomListDTO])] = []

                while true {
                    let data = try await getChatRoomListUseCase.execute(request: .init(page: page))
                    allResponses.append((page, data))
                    if data.count < 10 { break }
                    page += 1
                }

                let sorted = allResponses.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
                self.activeWalks = sorted.filter { $0.active }
                self.completedWalks = sorted.filter { !$0.active }
                self.currentPage = page + 1
                self.isLastPage = true

            } catch let error as CommonAPIError<GetChatHistoryError> {
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
