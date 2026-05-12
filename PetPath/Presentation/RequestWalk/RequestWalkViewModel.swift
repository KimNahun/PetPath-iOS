//
//  RequestWalkViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/23/25.
//

import Combine
import Foundation

final class RequestWalkViewModel {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let getMyDogListUseCase = GetMyDogListUseCaseImpl(repository: DogRepositoryImpl())
    private let getRecentPickupPositionUseCase = GetRecentPickupPositionUseCaseImpl(repository: WalkRepositoryImpl())
    private let positionToAddressUseCase = PositionToAddressUseCaseImpl(repository: UtilRepositoryImpl())
    private let searchAddressByKeywordUseCase = SearchAddressByKeywordUseCaseImpl(repository: UtilRepositoryImpl())
    private let requestWalkUseCase = RequestWalkUseCaseImpl(repository: WalkRepositoryImpl())
    private let getWalkPredictPriceUseCase = GetWalkPredictPriceUseCaseImpl(repository: WalkRepositoryImpl())
    
    @Published var dogList: [DogData] = []
    @Published var selectedList: [Bool] = []
    @Published var recentPickupPositionList: [GetRecentPickupPositionDTO] = []
    @Published var positionResponse: PositionToAddressDTO = .init(roadAddress: "", address: "")
    @Published var searchedResponse: [SearchAddressByKeywordDTO] = []
    @Published var predictedPrice: Int = 0
    
    
    @Published var walkButtonEnabled: Bool = false
    @Published var requestButtonEnabled: Bool = false
    @Published var requestWalkRequest = RequestWalkRequest()
    @Published var finalRequest = RequestWalkRequest()
    @Published var computedResult: (priceText: String, success: Bool) = (priceText: "", success: false)
    let walkRequestSuccessPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        bind()
    }
    
    func getWalkPredictPrice() {
        Task {
            do {
                predictedPrice = try await getWalkPredictPriceUseCase.execute(request: finalRequest.toGetWalkPredictPriceRequest())
            } catch let error as CommonAPIError<GetWalkPredictPriceError> {
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
    
    func requestWalk() {
        Task {
            do {
                _ = try await requestWalkUseCase.execute(request: finalRequest)
                walkRequestSuccessPublisher.send()
            } catch let error as CommonAPIError<RequestWalkError> {
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
    
    func searchAddressByKeyword(keyword: String) {
        Task {
            do {
                searchedResponse = try await searchAddressByKeywordUseCase.execute(keyword: keyword)
            } catch let error as CommonAPIError<SearchAddressByKeywordError> {
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
    
    func positionToAddress(lat: Double, lng: Double) {
        // FIXME: 일단 안좋은 방식으로 위치 오류 수신 방지. 추후에 고치기
        if lat == 37.35959299999998 && lng == 127.10531600000002 { return }
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
    
    func getRecentPickupPosition() {
        Task {
            do {
                recentPickupPositionList = try await getRecentPickupPositionUseCase.execute()
            } catch let error as CommonAPIError<GetRecentPickupPositionError> {
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
                selectedList = Array(repeating: false, count: dogList.count)
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

extension RequestWalkViewModel {
    private func bind() {
        $selectedList.map { list in
            list.contains(where: { $0 })
        }.removeDuplicates().assign(to: &$walkButtonEnabled)
        
        $requestWalkRequest
            .map { [weak self] request in
                self?.calculateTimeDiff(from: request.startAt, to: request.endAt) ?? ("", false)
            }.assign(to: &$computedResult)
        
        $finalRequest.map { request in
            return !request.dogs.isEmpty &&
            !request.startAt.isEmpty &&
            !request.endAt.isEmpty &&
            request.pickupX != 0.0 &&
            request.pickupY != 0.0
        }.assign(to: &$requestButtonEnabled)
        
        $requestButtonEnabled.sink { [weak self] isEnabled in
            if isEnabled {
                self?.getWalkPredictPrice()
            }
        }.store(in: &subscriptions)
    }
    func toggleDogSelection(dogId: Int) -> (count: Int, index: Int, selcted: Bool) {
        guard let index = dogList.firstIndex(where: { $0.did == dogId }) else { return (0, 0, false) }
        let selectedCount = selectedList.filter { $0 }.count
        let selected = selectedList[index]
        if selected {
            selectedList[index].toggle()
        } else {
            if selectedCount >= 1 {
                ToastMessenger.shared.showToast(message: "최대 1마리까지 선택 가능합니다.")
            } else {
                selectedList[index].toggle()
            }
        }
        
        return (selectedList.filter { $0 }.count, index, selectedList[index])
    }
    func calculateTimeDiff(from start: String, to end: String) -> (String, Bool) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else {
            return ("", false)
        }
        
        let now = Date()
        
        if startDate < now {
            return ("산책 시간을 현재 시간 기준으로 조정하세요", false)
        }
        
        let diff = Int(endDate.timeIntervalSince(startDate))
        guard diff > 0 else { return ("", false) }
        
        if diff > 7200 {
            return ("산책은 2시간 내로 가능합니다", false)
        }
        
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return ("\(hours)시간 \(minutes)분", true)
        } else if hours > 0 {
            return ("\(hours)시간", true)
        } else {
            return ("\(minutes)분", true)
        }
    }
}
