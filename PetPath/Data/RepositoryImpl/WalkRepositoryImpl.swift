//
//  WalkRepositoryImpl.swift
//  PetPath
//
//  Created by 김나훈 on 3/20/25.
//

import Foundation

final class WalkRepositoryImpl: WalkRepository {
    
    private let service = CommonNetworkService()
    
    func getMainCurrentWalkList() async throws -> [GetMainCurrentWalkListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getMainCurrentWalkList.rawValue,
                param: EmptyParam(),
                successType: [GetMainCurrentWalkListDTO].self,
                codeInit: { codeString in
                    return GetMainCurrentWalkListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetMainCurrentWalkListError.common(error)
        }
    }
    
    func pushWalkPosition(request: PushWalkPositionRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.pushWalkPosition.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return PushWalkPositionError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw PushWalkPositionError.common(error)
        }
    }
    func getWalkerTrainStatus() async throws -> GetWalkerTrainStatusDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkerTrainStatus.rawValue,
                param: EmptyParam(),
                successType: GetWalkerTrainStatusDTO.self,
                codeInit: { codeString in
                    return GetWalkerTrainStatusError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkerTrainStatusError.common(error)
        }
    }
    
    func getWalkerTrainList() async throws -> [GetWalkerTrainListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkerTrainList.rawValue,
                param: EmptyParam(),
                successType: [GetWalkerTrainListDTO].self,
                codeInit: { codeString in
                    return GetWalkerTrainListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkerTrainListError.common(error)
        }
    }
    
    func getWalkerTrainContent(request: GetWalkerTrainContentRequest) async throws -> GetWalkerTrainContentDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkerTrainContent.rawValue,
                param: request,
                successType: GetWalkerTrainContentDTO.self,
                codeInit: { codeString in
                    return GetWalkerTrainContentError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkerTrainContentError.common(error)
        }
    }
    
    func setWalkerTrainProgress(request: SetWalkerTrainProgressRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.setWalkerTrainProgress.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return SetWalkerTrainProgressError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw SetWalkerTrainProgressError.common(error)
        }
    }
    
    func getWalkerTrainQuiz() async throws -> [GetWalkerTrainQuizDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkerTrainQuiz.rawValue,
                param: EmptyParam(),
                successType: [GetWalkerTrainQuizDTO].self,
                codeInit: { codeString in
                    return GetWalkerTrainQuizError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkerTrainQuizError.common(error)
        }
    }
    
    func submitWalkerTrainQuiz(request: [SubmitWalkerTrainQuizRequest]) async throws -> SubmitWalkerTrainQuizDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.submitWalkerTrainQuiz.rawValue,
                param: request,
                successType: SubmitWalkerTrainQuizDTO.self,
                codeInit: { codeString in
                    return SubmitWalkerTrainQuizError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw SubmitWalkerTrainQuizError.common(error)
        }
    }
    
    
    func requestReport(request: RequestReportRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.requestReport.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return RequestReportError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw RequestReportError.common(error)
        }
    }
    
    func cancelWalk(request: CancelWalkRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.cancelWalk.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return CancelWalkError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw CancelWalkError.common(error)
        }
    }
    
    func startWalk(request: StartOrEndWalkRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.startWalk.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return StartWalkError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw StartWalkError.common(error)
        }
    }
    
    func endWalk(request: StartOrEndWalkRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.endWalk.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return EndWalkError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw EndWalkError.common(error)
        }
    }
    
    func getRecentWalkPath(page: Int) async throws -> GetRecentWalkPathDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getRecentWalkPath.rawValue,
                param: GetRecentWalkPathRequest(page: page),
                successType: GetRecentWalkPathDTO.self,
                codeInit: { codeString in
                    return GetRecentWalkPathError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetRecentWalkPathError.common(error)
        }
    }
    
    func getRecentPickupPosition() async throws -> [GetRecentPickupPositionDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getRecentPickupPosition.rawValue,
                param: EmptyParam(),
                successType: [GetRecentPickupPositionDTO].self,
                codeInit: { codeString in
                    return GetRecentPickupPositionError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetRecentPickupPositionError.common(error)
        }
    }
    
    func getWalkPredictPrice(request: GetWalkPredictPriceRequest) async throws -> Int {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkPredictPrice.rawValue,
                param: request,
                successType: Int.self,
                codeInit: { codeString in
                    return GetWalkPredictPriceError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkPredictPriceError.common(error)
        }
    }
    
    func requstWalk(request: RequestWalkRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.requestWalk.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return RequestWalkError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw RequestWalkError.common(error)
        }
    }
    
    func getWalkRequestList(request: GetWalkRequestListRequest) async throws -> [GetWalkRequestListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkRequestList.rawValue,
                param: request,
                successType: [GetWalkRequestListDTO].self,
                codeInit: { codeString in
                    return GetWalkRequestListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkRequestListError.common(error)
        }
    }
    
    func getWalkHistoryList(request: GetWalkHistoryListRequest) async throws -> [GetWalkHistoryListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkHistoryList.rawValue,
                param: request,
                successType: [GetWalkHistoryListDTO].self,
                codeInit: { codeString in
                    return GetWalkHistoryListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkHistoryListError.common(error)
        }
    }
    
    func getWalkDetail(request: GetWalkDetailRequest) async throws -> GetWalkDetailDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkDetail.rawValue,
                param: request,
                successType: GetWalkDetailDTO.self,
                codeInit: { codeString in
                    return GetWalkDetailError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkDetailError.common(error)
        }
    }
    
    func applyWalker(request: ApplyWalkerRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.applyWalker.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return ApplyWalkerError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw ApplyWalkerError.common(error)
        }
    }
    
    func getApplyWalkerList(request: GetApplyWalkerListRequest) async throws -> [GetApplyWalkerListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getApplyWalkerList.rawValue,
                param: request,
                successType: [GetApplyWalkerListDTO].self,
                codeInit: { codeString in
                    return GetApplyWalkerListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetApplyWalkerListError.common(error)
        }
    }
    
    func getWalkerWalkApplied(request: GetWalkerWalkAppliedRequest) async throws -> GetWalkerWalkAppliedDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getWalkerWalkApplied.rawValue,
                param: request,
                successType: GetWalkerWalkAppliedDTO.self,
                codeInit: { codeString in
                    return GetWalkerWalkAppliedError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetWalkerWalkAppliedError.common(error)
        }
    }
    
    func cancelWalkApply(request: CancelWalkApplyRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.cancelWalkApply.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return CancelWalkApplyError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw CancelWalkApplyError.common(error)
        }
    }
    
    func getMatchedWalkerInfo(request: GetMatchedWalkerInfoRequest) async throws -> GetMatchedWalkerInfoDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getMatchedWalkerInfo.rawValue,
                param: request,
                successType: GetMatchedWalkerInfoDTO.self,
                codeInit: { codeString in
                    return GetMatchedWalkerInfoError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetMatchedWalkerInfoError.common(error)
        }
    }
    
    func matchWalker(request: MatchWalkerRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.matchWalker.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return MatchWalkerError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw MatchWalkerError.common(error)
        }
    }
    
    
}
