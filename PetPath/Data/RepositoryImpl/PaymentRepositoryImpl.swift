//
//  PaymentRepositoryImpl.swift
//  PetPath
//
//  Created by 김나훈 on 3/20/25.
//

import Foundation

final class PaymentRepositoryImpl: PaymentRepository {
    
    private let service = CommonNetworkService()
    
    func getPayoutContract() async throws -> GetPayoutContractDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getPayoutContract.rawValue,
                param: EmptyParam(),
                successType: GetPayoutContractDTO.self,
                codeInit: { codeString in
                    return GetPayoutContractError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetPayoutContractError.common(error)
        }
    }
    
    func modifyPayoutContract(request: ModifyPayoutContractRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.modifyPayoutContract.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return ModifyPayoutContractError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw ModifyPayoutContractError.common(error)
        }
    }
    
    func getAvailablePayoutAmount() async throws -> GetAvailablePayoutAmountDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getAvailablePayoutAmount.rawValue,
                param: EmptyParam(),
                successType: GetAvailablePayoutAmountDTO.self,
                codeInit: { codeString in
                    return GetAvailablePayoutAmountError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetAvailablePayoutAmountError.common(error)
        }
    }
    
    func getPayoutHistory() async throws -> [GetPayoutHistoryDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getPayoutHistory.rawValue,
                param: EmptyParam(),
                successType: [GetPayoutHistoryDTO].self,
                codeInit: { codeString in
                    return GetPayoutHistoryError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetPayoutHistoryError.common(error)
        }
    }
    
    func getPayoutDetail(request: GetPayoutDetailRequest) async throws -> GetPayoutDetailDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getPayoutDetail.rawValue,
                param: request,
                successType: GetPayoutDetailDTO.self,
                codeInit: { codeString in
                    return GetPayoutDetailError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetPayoutDetailError.common(error)
        }
    }
    
    func requestPayout() async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.requestPayout.rawValue,
                param: EmptyParam(),
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return RequestPayoutError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw RequestPayoutError.common(error)
        }
    }
    
    func calcCancelWalkPenalty(request: CalcCancelWalkPenaltyRequest) async throws -> CalcCancelWalkPenaltyDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.calcCancelWalkPenalty.rawValue,
                param: request,
                successType: CalcCancelWalkPenaltyDTO.self,
                codeInit: { codeString in
                    return CalcCancelWalkPenaltyError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw CalcCancelWalkPenaltyError.common(error)
        }
    }
    func addCard(request: AddCardRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.addCard.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return AddCardError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw AddCardError.common(error)
        }
    }
    
    func getCardList() async throws -> [CardData] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getCardList.rawValue,
                param: EmptyParam(),
                successType: [CardData].self,
                codeInit: { codeString in
                    return GetCardListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetCardListError.common(error)
        }
    }
    
    func deleteCard(request: DeleteCardRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.deleteCard.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return DeleteCardError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw DeleteCardError.common(error)
        }
    }
    
    func getPaymentHistory(page: Int) async throws -> [PaymentHistoryData] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getPaymentHistory.rawValue,
                param: GetPaymentHistoryRequest(page: page),
                successType: [PaymentHistoryData].self,
                codeInit: { codeString in
                    return GetPaymentHistoryError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetPaymentHistoryError.common(error)
        }
    }
    
    func getCouponList(request: GetCouponListRequest) async throws -> [GetCouponListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getCouponList.rawValue,
                param: request,
                successType: [GetCouponListDTO].self,
                codeInit: { codeString in
                    return GetCouponListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetCouponListError.common(error)
        }
    }
    
    func getAvailableCouponList(request: GetAvailableCouponListRequest) async throws -> [GetAvailableCouponListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getAvailableCouponList.rawValue,
                param: request,
                successType: [GetAvailableCouponListDTO].self,
                codeInit: { codeString in
                    return GetAvailableCouponListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetAvailableCouponListError.common(error)
        }
    }
    
    func getActualPayPrice(request: GetActualPayPriceRequest) async throws -> GetActualPayPriceDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getActualPayPrice.rawValue,
                param: request,
                successType: GetActualPayPriceDTO.self,
                codeInit: { codeString in
                    return GetActualPayPriceError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetActualPayPriceError.common(error)
        }
    }
    
    func getWalkPaymentInfo(request: GetWalkPaymentInfoRequest) async throws -> GetWalkPaymentInfoDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkPaymentInfo.rawValue,
                param: request,
                successType: GetWalkPaymentInfoDTO.self,
                codeInit: { codeString in
                    return GetWalkPaymentInfoError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkPaymentInfoError.common(error)
        }
    }
    
    func getWalkPayoutInfo(request: GetWalkPayoutInfoRequest) async throws -> GetWalkPayoutInfoDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkPayoutInfo.rawValue,
                param: request,
                successType: GetWalkPayoutInfoDTO.self,
                codeInit: { codeString in
                    return GetWalkPayoutInfoError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkPayoutInfoError.common(error)
        }
    }
}
