//
//  PaymentRepository.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol PaymentRepository {
    func addCard(request: AddCardRequest) async throws -> EmptyResponse
    func getCardList() async throws -> [CardData]
    func deleteCard(request: DeleteCardRequest) async throws -> EmptyResponse
    func getPaymentHistory(page: Int) async throws -> [PaymentHistoryData]
    func getCouponList(request: GetCouponListRequest) async throws -> [GetCouponListDTO]
    func getAvailableCouponList(request: GetAvailableCouponListRequest) async throws -> [GetAvailableCouponListDTO]
    func getActualPayPrice(request: GetActualPayPriceRequest) async throws -> GetActualPayPriceDTO
    func getWalkPaymentInfo(request: GetWalkPaymentInfoRequest) async throws -> GetWalkPaymentInfoDTO
    func getWalkPayoutInfo(request: GetWalkPayoutInfoRequest) async throws -> GetWalkPayoutInfoDTO
    func getPayoutContract() async throws -> GetPayoutContractDTO
    func modifyPayoutContract(request: ModifyPayoutContractRequest) async throws -> EmptyResponse
    func getAvailablePayoutAmount() async throws -> GetAvailablePayoutAmountDTO
    func getPayoutHistory() async throws -> [GetPayoutHistoryDTO]
    func getPayoutDetail(request: GetPayoutDetailRequest) async throws -> GetPayoutDetailDTO
    func requestPayout() async throws -> EmptyResponse
    func calcCancelWalkPenalty(request: CalcCancelWalkPenaltyRequest) async throws -> CalcCancelWalkPenaltyDTO
}
