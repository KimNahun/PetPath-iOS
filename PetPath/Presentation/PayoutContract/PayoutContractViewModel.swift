//
//  PayoutContractViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 5/3/25.
//

import Combine
import Foundation

final class PayoutContractViewModel {
    
    struct PayoutItem: Hashable {
        let message: String
        let title: String
        let isTitle: Bool
        let status: ContractStatus?
    }
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getPayoutContractUseCase = GetPayoutContractUseCaseImpl(repository: PaymentRepositoryImpl())
    private let modifyPayoutContractUseCase = ModifyPayoutContractUseCaseImpl(repository: PaymentRepositoryImpl())
    private let fileUploadUseCase = FileUploadUseCaseImpl(repository: UtilRepositoryImpl())
    
    @Published var payoutInfoList: [PayoutItem] = []
    @Published var modifyRequest: ModifyPayoutContractRequest?
    private(set) var payoutDto: GetPayoutContractDTO?
    let successPublisher = PassthroughSubject<Void, Never>()
    @Published var saveButtonEnabled: Bool = false
    init() {
        bind()
    }
}

extension PayoutContractViewModel {
    func fileUpload(imageData: Data, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let token = try await fileUploadUseCase.execute(fileData: imageData, fileName: "dog_profile5.jpg")
                completion(token)
            } catch let error as CommonAPIError<FileUploadError> {
                DispatchQueue.main.async {
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
                    completion(nil)
                }
            }
        }
    }
    func getPayoutContract() {
        Task {
            do {
                let dto = try await getPayoutContractUseCase.execute()
                payoutDto = dto
                modifyRequest = ModifyPayoutContractRequest(identifyNum: dto.identifyNum, bankName: dto.bankName, accountNum: dto.accountNum, accountOwnerName: dto.accountOwnerName)
                payoutInfoList = mapDTOToPayoutItems(dto: dto)
            } catch let error as CommonAPIError<GetPayoutContractError> {
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
    func modifyPayoutContract() {
        Task {
            do {
                _ = try await modifyPayoutContractUseCase.execute(request: modifyRequest ?? .init())
                ToastMessenger.shared.showToast(message: "수정 요청에 성공했습니다.")
                successPublisher.send()
            } catch let error as CommonAPIError<ModifyPayoutContractError> {
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

extension PayoutContractViewModel {
    private func bind() {
        $modifyRequest.receive(on: DispatchQueue.main).sink { [weak self] item in
            print(item)
        }.store(in: &subscriptions)
        Publishers.CombineLatest4(
            $modifyRequest.map { $0?.bankName != nil },
            $modifyRequest.map { $0?.accountNum != nil },
            $modifyRequest.map { $0?.accountOwnerName != nil },
            $modifyRequest.map { $0?.accountPhoto != nil }
        )
        .map { $0 && $1 && $2 && $3 }
        .assign(to: &$saveButtonEnabled)
    }
    func mapDTOToPayoutItems(dto: GetPayoutContractDTO) -> [PayoutItem]{
        let items: [PayoutItem] = [
            PayoutItem(
                message: "계좌번호",
                title: dto.accountNum ?? "입금계좌번호",
                isTitle: dto.accountNum != nil,
                status: dto.accountStatus
            ),
            PayoutItem(
                message: "입금계좌 은행",
                title: dto.bankName ?? "입금계좌 은행",
                isTitle: dto.bankName != nil,
                status: nil
            ),
            PayoutItem(
                message: "예금주명",
                title: dto.accountOwnerName ?? "입금계좌 예금주명",
                isTitle: dto.accountOwnerName != nil,
                status: nil
            ),
            PayoutItem(
                message: "주민등록번호",
                title: dto.identifyNum ?? "주민등록번호",
                isTitle: dto.identifyNum != nil,
                status: dto.identifyStatus
            )
        ]
        return items
    }
}
