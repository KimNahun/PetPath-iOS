//
//  FindWalkViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/27/25.
//

import Combine
import Foundation
// TODO: LifeCycle로 위치 요청 중지
final class FindWalkViewModel {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let getWalkRequestListUseCase = GetWalkRequestListUseCaseImpl(repository: WalkRepositoryImpl())
    private let searchAddressByKeywordUseCase = SearchAddressByKeywordUseCaseImpl(repository: UtilRepositoryImpl())
    private let positionToAddressUseCase = PositionToAddressUseCaseImpl(repository: UtilRepositoryImpl())
    
    @Published var getWalkRequestListResponse: [GetWalkRequestListDTO] = []
    @Published var searchedResponse: [SearchAddressByKeywordDTO] = []
    @Published var positionResponse: PositionToAddressDTO = .init(roadAddress: "", address: "")
    @Published var tappedResult: SearchAddressByKeywordDTO = .init(roadAddress: "", address: "", y: 0, x: 0)
    
    @Published var nowLocation: GetWalkRequestListRequest = .init(y: 0.0, x: 0.0, zoom: 14)
    var myLocation: GetWalkRequestListRequest = .init(y: 0.0, x: 0.0, zoom: 14)
    
    init() {
        bind()
    }
    
    
}

extension FindWalkViewModel {
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
    
    func getWalkRequestList() {
        Task {
            do {
                getWalkRequestListResponse = try await getWalkRequestListUseCase.execute(request: nowLocation)
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
    
    private func bind() {
        $nowLocation.dropFirst().sink { [weak self] _ in
            self?.getWalkRequestList()
        }.store(in: &subscriptions)
    }
}
