//
//  WalkRepository.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol WalkRepository {
    func getRecentWalkPath(page: Int) async throws -> GetRecentWalkPathDTO
    func getRecentPickupPosition() async throws -> [GetRecentPickupPositionDTO]
    func getWalkPredictPrice(request: GetWalkPredictPriceRequest) async throws -> Int
    func requstWalk(request: RequestWalkRequest) async throws -> EmptyResponse
    func getWalkRequestList(request: GetWalkRequestListRequest) async throws -> [GetWalkRequestListDTO]
    func getWalkHistoryList(request: GetWalkHistoryListRequest) async throws -> [GetWalkHistoryListDTO]
    func getWalkDetail(request: GetWalkDetailRequest) async throws -> GetWalkDetailDTO
    func applyWalker(request: ApplyWalkerRequest) async throws -> EmptyResponse
    func getApplyWalkerList(request: GetApplyWalkerListRequest) async throws -> [GetApplyWalkerListDTO]
    func getWalkerWalkApplied(request: GetWalkerWalkAppliedRequest) async throws -> GetWalkerWalkAppliedDTO
    func cancelWalkApply(request: CancelWalkApplyRequest) async throws -> EmptyResponse
    func getMatchedWalkerInfo(request: GetMatchedWalkerInfoRequest) async throws -> GetMatchedWalkerInfoDTO
    func matchWalker(request: MatchWalkerRequest) async throws -> EmptyResponse
    func startWalk(request: StartOrEndWalkRequest) async throws -> EmptyResponse
    func endWalk(request: StartOrEndWalkRequest) async throws -> EmptyResponse
    func cancelWalk(request: CancelWalkRequest) async throws -> EmptyResponse
    func requestReport(request: RequestReportRequest) async throws -> EmptyResponse
    func getWalkerTrainStatus() async throws -> GetWalkerTrainStatusDTO
    func getWalkerTrainList() async throws -> [GetWalkerTrainListDTO]
    func getWalkerTrainContent(request: GetWalkerTrainContentRequest) async throws -> GetWalkerTrainContentDTO
    func setWalkerTrainProgress(request: SetWalkerTrainProgressRequest) async throws -> EmptyResponse
    func getWalkerTrainQuiz() async throws -> [GetWalkerTrainQuizDTO]
    func submitWalkerTrainQuiz(request: [SubmitWalkerTrainQuizRequest]) async throws -> SubmitWalkerTrainQuizDTO
    func pushWalkPosition(request: PushWalkPositionRequest) async throws -> EmptyResponse
    func getMainCurrentWalkList() async throws -> [GetMainCurrentWalkListDTO]
}
