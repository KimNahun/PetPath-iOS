//
//  OwnerWalkDetailViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine

final class OwnerWalkDetailViewModel: Reportable {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let id: Int
    
    // MARK: - Walk UseCase
    private let getWalkDetailUseCase = GetWalkDetailUseCaseImpl(repository: WalkRepositoryImpl())
    private let getMatchedWalkerInfoUseCase = GetMatchedWalkerInfoUseCaseImpl(repository: WalkRepositoryImpl())
    private let matchWalkerUseCase = MatchWalkerUseCaseImpl(repository: WalkRepositoryImpl())
    private let getApplyWalkerListUseCase = GetApplyWalkerListUseCaseImpl(repository: WalkRepositoryImpl())
    private let cancelWalkUseCase = CancelWalkUseCaseImpl(repository: WalkRepositoryImpl())
    private let requestReportUseCase = RequestReportUseCaseImpl(repository: WalkRepositoryImpl())
    
    // MARK: - Payment UseCase
    private let getActualPayPriceUseCase = GetActualPayPriceUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getWalkPaymentInfoUseCase = GetWalkPaymentInfoUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getCardListUseCase = GetCardListUseCaseImpl(repository: PaymentRepositoryImpl())
    private let getAvailableCouponListUseCase = GetAvailableCouponListUseCaseImpl(repository: PaymentRepositoryImpl())
    private let calcCancelWalkPenaltyUseCase = CalcCancelWalkPenaltyUseCaseImpl(repository: PaymentRepositoryImpl())
    
    @Published var agreementChecks: [Bool] = [false, false]
    @Published var isMatchButtonEnabled: Bool = false
    let matchSuccessPublisher = PassthroughSubject<Void, Never>()
    let cancelSuccessPublisher = PassthroughSubject<Void, Never>()
    var reportSuccessPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Request Models
    @Published var getActualPayPriceRequest: GetActualPayPriceRequest
    @Published var getAvailableCouponListRequest: GetAvailableCouponListRequest
    @Published var matchWalkerRequest: MatchWalkerRequest
    @Published var cancelWalkRequest: CancelWalkRequest
    
    // MARK: - Response Models
    @Published var appliedWalkerList: [GetApplyWalkerListDTO] = []
    @Published var walkDetailResponse: GetWalkDetailDTO?
    @Published var showingWalker: GetApplyWalkerListDTO?
    @Published var getActualPayPriceResponse: GetActualPayPriceDTO?
    @Published var cardList: [CardData] = []
    @Published var couponList: [GetAvailableCouponListDTO] = []
    @Published var matchedWalkerinfo: GetMatchedWalkerInfoDTO?
    @Published var walkPaymentInfo: GetWalkPaymentInfoDTO?
    @Published var penaltyResponse: CalcCancelWalkPenaltyDTO?
    // MARK: - Initialization
    init(id: Int) {
        self.id = id
        self.getActualPayPriceRequest = .init(walk: id)
        self.getAvailableCouponListRequest = .init(walk: id)
        self.matchWalkerRequest = .init(walk: id)
        self.cancelWalkRequest = .init(walk: id)
        bind()
        getCardList()
    }
}

extension OwnerWalkDetailViewModel {
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
    func getWalkPaymentInfo() {
        Task {
            do {
                walkPaymentInfo = try await getWalkPaymentInfoUseCase.execute(request: .init(walk: id))
            } catch let error as CommonAPIError<GetWalkPaymentInfoError> {
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
    func getMatchedWalkerInfo() {
        Task {
            do {
                matchedWalkerinfo = try await getMatchedWalkerInfoUseCase.execute(request: .init(walk: id))
            } catch let error as CommonAPIError<GetMatchedWalkerInfoError> {
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
    func matchWalker() {
        Task {
            do {
                _ = try await matchWalkerUseCase.execute(request: matchWalkerRequest)
                matchSuccessPublisher.send()
            } catch let error as CommonAPIError<MatchWalkerError> {
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
                cardList = try await getCardListUseCase.execute()
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
    
    func getAvailableCouponList() {
        Task {
            do {
                couponList = try await getAvailableCouponListUseCase.execute(request: getAvailableCouponListRequest)
            } catch let error as CommonAPIError<GetAvailableCouponListError> {
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
    
    func getActualPayPrice() {
        Task {
            do {
                getActualPayPriceResponse = try await getActualPayPriceUseCase.execute(request: getActualPayPriceRequest)
            } catch let error as CommonAPIError<GetActualPayPriceError> {
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
    
    func getWalkDetail() {
        Task {
            do {
                walkDetailResponse = try await getWalkDetailUseCase.execute(request: .init(walk: id))
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
    
    func getApplyWalkerList() {
        Task {
            do {
                appliedWalkerList = try await getApplyWalkerListUseCase.execute(request: .init(walk: id))
            } catch let error as CommonAPIError<GetCouponListError> {
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

extension OwnerWalkDetailViewModel {
    private func bind() {        
        $showingWalker.compactMap { $0 }.sink { [weak self] walker in
            self?.getActualPayPriceRequest.walker = walker.pk
            self?.getAvailableCouponListRequest.walker = walker.pk
            self?.matchWalkerRequest.walker = walker.pk
        }.store(in: &subscriptions)
        
        $getActualPayPriceRequest.compactMap { $0 }.filter { $0.walker != nil }.sink { [weak self] _ in
            self?.getActualPayPrice()
        }.store(in: &subscriptions)
        
        $getAvailableCouponListRequest.compactMap { $0 }.filter { $0.walker != nil }.sink { [weak self] _ in
            self?.getAvailableCouponList()
        }.store(in: &subscriptions)
        
        Publishers.CombineLatest($matchWalkerRequest, $agreementChecks)
            .map { request, checks in
                let isWalkerValid = request.walker != nil
                let isPayMethodValid = request.payMethod != nil
                let allAgreementsChecked = checks.allSatisfy { $0 }
                
                return isWalkerValid && isPayMethodValid && allAgreementsChecked
            }.assign(to: &$isMatchButtonEnabled)
    }
}
