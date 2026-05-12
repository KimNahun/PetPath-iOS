//
//  WalkerWalkDetailViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/29/25.
//

import Combine
import Foundation

final class WalkerWalkDetailViewModel: Reportable {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let getWalkDetailUseCase = GetWalkDetailUseCaseImpl(repository: WalkRepositoryImpl())
    private let applyWalkerUseCase = ApplyWalkerUseCaseImpl(repository: WalkRepositoryImpl())
    private let getWalkerWalkAppliedUseCase = GetWalkerWalkAppliedUseCaseImpl(repository: WalkRepositoryImpl())
    private let cancelWalkApplyUseCase = CancelWalkApplyUseCaseImpl(repository: WalkRepositoryImpl())
    private let cancelWalkUseCase = CancelWalkUseCaseImpl(repository: WalkRepositoryImpl())
    private let getWalkPayoutInfoUseCase = GetWalkPayoutInfoUseCaseImpl(repository: PaymentRepositoryImpl())
    private let calcCancelWalkPenaltyUseCase = CalcCancelWalkPenaltyUseCaseImpl(repository: PaymentRepositoryImpl())
    private let requestReportUseCase = RequestReportUseCaseImpl(repository: WalkRepositoryImpl())
    private let startWalkUseCase = StartWalkUseCaseImpl(repository: WalkRepositoryImpl())
    private let endWalkUseCase = EndWalkUseCaseImpl(repository: WalkRepositoryImpl())
    private let id: Int
    
    @Published var applyWalkRequest: ApplyWalkerRequest?
    @Published var cancelWalkRequest: CancelWalkRequest
    private let getWalkPayoutInfoRequest: GetWalkPayoutInfoRequest
    
    @Published var walkDetailResponse: GetWalkDetailDTO?
    @Published var payoutInfoResponse: GetWalkPayoutInfoDTO?
    @Published var penaltyResponse: CalcCancelWalkPenaltyDTO?
    @Published var applyFailReason: WalkApplyNotAvailableCase?
    @Published var walkerAppliedResponse: GetWalkerWalkAppliedDTO?
    
    @Published var isRequestValid: Bool = false
    let applySuccessPublisher = PassthroughSubject<Void, Never>()
    let popPublisher = PassthroughSubject<Void, Never>()
    let appliedPublisher = PassthroughSubject<(status: WalkStatus, applied: Bool), Never>()
    let cancelSuccessPublisher = PassthroughSubject<Void, Never>()
    let reportSuccessPublisher = PassthroughSubject<Void, Never>()
    let startOfEndSuccessPublisher = PassthroughSubject<Void, Never>()
    
    // ???: 이거 applyWalkRequest 초기화 때문에 api요청 2번되는게 아닌지?
    init(id: Int) {
        self.applyWalkRequest = .init(walk: id)
        self.id = id
        self.getWalkPayoutInfoRequest = .init(walk: id)
        self.cancelWalkRequest = .init(walk: id)
        bind()
    }
    
    
}

extension WalkerWalkDetailViewModel {
    func startWalk(request: StartOrEndWalkRequest) {
        Task {
            do {
                PushWalkPositionManager.shared.setWalkId(id: request.walkId)
                    _ = try await startWalkUseCase.execute(request: request)
                    DispatchQueue.main.async {
                        PushWalkPositionManager.shared.start()
                    }
                ToastMessenger.shared.showToast(message: "산책이 시작되었습니다. 위치 추적이 시작됩니다.")
                startOfEndSuccessPublisher.send()
            } catch let error as CommonAPIError<StartWalkError> {
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
    func endWalk(request: StartOrEndWalkRequest) {
        Task {
            do {
                _ = try await endWalkUseCase.execute(request: request)
                startOfEndSuccessPublisher.send()
                ToastMessenger.shared.showToast(message: "산책이 종료되었습니다. 위치 추적이 종료됩니다.")
                PushWalkPositionManager.shared.stop()
            } catch let error as CommonAPIError<EndWalkError> {
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
                _ = try await requestReportUseCase.execute(request: .init(walkId: id, content: content))
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
    
    func calcCancelWalkPenalty() {
        Task {
            do {
                penaltyResponse = try await calcCancelWalkPenaltyUseCase.execute(request: .init(walk: id))
            } catch let error as CommonAPIError<CalcCancelWalkPenaltyError> {
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
    func getWalkPayoutInfo() {
        Task {
            do {
                payoutInfoResponse = try await getWalkPayoutInfoUseCase.execute(request: getWalkPayoutInfoRequest)
            } catch let error as CommonAPIError<GetWalkPayoutInfoError> {
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
    func cancelWalk() {
        Task {
            do {
                _ = try await cancelWalkUseCase.execute(request: cancelWalkRequest)
                cancelSuccessPublisher.send()
            } catch let error as CommonAPIError<CancelWalkError> {
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
    
    func cancelWalkApply() {
        Task {
            do {
                _ = try await cancelWalkApplyUseCase.execute(request: .init(walk: id))
                popPublisher.send()
                ToastMessenger.shared.showToast(message: "산책 지원을 취소했습니다.")
            } catch let error as CommonAPIError<CancelWalkApplyError> {
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
    func getWalkerWalkApplied(status: WalkStatus) {
        Task {
            do {
                walkerAppliedResponse  = try await getWalkerWalkAppliedUseCase.execute(request: .init(walk: id))
                appliedPublisher.send((status: status, applied: true))
            } catch let error as CommonAPIError<GetWalkerWalkAppliedError> {
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
                    case .inputValueNotValid, .unauthorized: ToastMessenger.shared.showToast(message: error.message ?? "")
                    case .walkNotApplied:
                        appliedPublisher.send((status: status, applied: false))
                        walkerAppliedResponse = nil
                    }
                }
            }
        }
    }
    
    func applyWalker() {
        Task {
            do {
                _ = try await applyWalkerUseCase.execute(request: applyWalkRequest ?? ApplyWalkerRequest(walk: id, price: 0, description: ""))
                applySuccessPublisher.send()
            } catch let error as CommonAPIError<ApplyWalkerError> {
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
                    case .walkApplyNotAvailable:
                        if let rawData = error.data as? Data {
                            if let commonResponse = try? JSONDecoder().decode([CommonResponse<WalkApplyNotAvailableResponse>].self, from: rawData),
                               let first = commonResponse.first?.data {
                                applyFailReason = first.reason
                            }
                        }
                    default: ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                }
            }
        }
    }
    
    func getWalkDetail() {
        Task {
            do {
                walkDetailResponse = try await getWalkDetailUseCase.execute(request: .init(walk: id))
                if walkDetailResponse?.status != .findWalker && walkDetailResponse?.status != .walkerNotMatch {
                    getWalkPayoutInfo()
                }
            } catch let error as CommonAPIError<GetWalkRequestListError> {
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

extension WalkerWalkDetailViewModel {

    private func bind() {
        $applyWalkRequest
                .map { request in
                    guard let request = request else { return false }
                    return request.price != nil && !(request.description?.isEmpty ?? true)
                }
                .assign(to: \.isRequestValid, on: self)
                .store(in: &subscriptions)
    }
}
