//
//  WalkHistoryViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import Foundation

final class WalkHistoryViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getWalkHistoryListUseCase = GetWalkHistoryListUseCaseImpl(repository: WalkRepositoryImpl())
    private let getUserInfoUseCase: GetUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    
    @Published var activeWalks: [GetWalkHistoryListDTO] = []
    @Published var completedWalks: [GetWalkHistoryListDTO] = []
    private var currentPage: Int = 0
    private var isLastPage = false
    @Published var userType: UserType?
    
    // MARK: - Initialization
    
    init() {
        bind()
    }
    
    private func bind() {
        $userType
               .compactMap { $0 } 
               .sink { [weak self] _ in
                   Task { @MainActor in
                           self?.getWalkHistoryList()
                       }
               }
               .store(in: &subscriptions)
    }
    
}

extension WalkHistoryViewModel {
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
    
    @MainActor
    func getWalkHistoryList() {
        Task {
            do {
                var page = 0
                var allResponses: [(Int, [GetWalkHistoryListDTO])] = []

                while true {
                    let data = try await getWalkHistoryListUseCase.execute(request: .init(page: page))
                    allResponses.append((page, data))
                    if data.count < 10 { break }
                    page += 1
                }

                let sorted = allResponses.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
                self.activeWalks = sorted.filter { $0.active }
                self.completedWalks = sorted.filter { !$0.active }
                self.currentPage = page + 1
                self.isLastPage = true

            } catch let error as CommonAPIError<GetWalkHistoryListError> {
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
