//
//  TrainViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Combine
import Foundation

final class TrainViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getWalkerTrainListUseCase = GetWalkerTrainListUseCaseImpl(repository: WalkRepositoryImpl())
    private let getWalkerTrainContentUseCase = GetWalkerTrainContentUseCaseImpl(repository: WalkRepositoryImpl())
    private let setWalkerTrainProgressUseCase = SetWalkerTrainProgressUseCaseImpl(repository: WalkRepositoryImpl())
    private let getWalkerTrainQuizUseCase = GetWalkerTrainQuizUseCaseImpl(repository: WalkRepositoryImpl())
    private let submitWalkerTrainQuizUseCase = SubmitWalkerTrainQuizUseCaseImpl(repository: WalkRepositoryImpl())
    private let getWalkerTrainStatusUseCase = GetWalkerTrainStatusUseCaseImpl(repository: WalkRepositoryImpl())
    
    let successPublisher = PassthroughSubject<Void, Never>()
    
    @Published var trainList: [GetWalkerTrainListDTO] = []
    @Published var selectedKey: String?
    @Published var trainContent: GetWalkerTrainContentDTO?
    @Published var selectedContentIndex = 0
    @Published var quizList: [GetWalkerTrainQuizDTO] = []
    @Published var selectedQuizIndex = 0
    @Published var quizResult: SubmitWalkerTrainQuizDTO?
    @Published var trainSuccess: Bool = false
    var submitQuizList: [SubmitWalkerTrainQuizRequest] = []
}

extension TrainViewModel {
    func getWalkerTrainStatus() {
        Task {
            do {
                let response = try await getWalkerTrainStatusUseCase.execute()
                trainSuccess = response.completed
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
    func getWalkerTrainList() {
        Task {
            do {
                trainList = try await getWalkerTrainListUseCase.execute()
            } catch let error as CommonAPIError<GetWalkerTrainListError> {
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
    func getWalkerTrainContent() {
        Task {
            do {
                trainContent = try await getWalkerTrainContentUseCase.execute(request: GetWalkerTrainContentRequest(key: selectedKey ?? ""))
                       
                       if let selectedKey = selectedKey,
                          let matching = trainList.first(where: { $0.key == selectedKey }) {
                           if matching.progress >= matching.page {
                               selectedContentIndex = 0
                           } else {
                               selectedContentIndex = matching.progress
                           }
                       } else {
                           selectedContentIndex = 0
                       }
            } catch let error as CommonAPIError<GetWalkerTrainContentError> {
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
    func setWalkerTrainProgress() {
        Task {
            do {
                _ = try await setWalkerTrainProgressUseCase.execute(request: .init(key: selectedKey ?? "", progress: selectedContentIndex))
                if selectedContentIndex == trainContent?.pages.count {
                    successPublisher.send()
                }
            } catch let error as CommonAPIError<SetWalkerTrainProgressError> {
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
    func getWalkerTrainQuiz() {
        Task {
            do {
                quizList = try await getWalkerTrainQuizUseCase.execute()
                selectedQuizIndex = 0
                submitQuizList = quizList.map { quiz in
                    SubmitWalkerTrainQuizRequest(pk: quiz.pk, answer: "")
                }
            } catch let error as CommonAPIError<GetWalkerTrainQuizError> {
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
    func submitWalkerTrainQuiz() {
        Task {
            do {
                quizResult = try await submitWalkerTrainQuizUseCase.execute(request: submitQuizList)
            } catch let error as CommonAPIError<SubmitWalkerTrainQuizError> {
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
