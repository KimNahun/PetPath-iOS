//
//  ChatRepositoryImpl.swift
//  PetPath
//
//  Created by 김나훈 on 3/20/25.
//

import Foundation

final class ChatRepositoryImpl: ChatRepository {
    
    private let service = CommonNetworkService()
    
    func getChatRoomList(request: GetChatRoomListRequest) async throws -> [GetChatRoomListDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getChatRoomList.rawValue,
                param: request,
                successType: [GetChatRoomListDTO].self,
                codeInit: { codeString in
                    return GetChatRoomListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetChatRoomListError.common(error)
        }
    }
    
    func getUnReadChatIndex(request: GetUnreadChatIndexRequest) async throws -> GetUnreadChatIndexDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getUnreadChatIndex.rawValue,
                param: request,
                successType: GetUnreadChatIndexDTO.self,
                codeInit: { codeString in
                    return GetUnreadChatIndexError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetUnreadChatIndexError.common(error)
        }
    }
    
    func getChatHistory(request: GetChatHistoryRequest) async throws -> GetChatHistoryDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getChatHistory.rawValue,
                param: request,
                successType: GetChatHistoryDTO.self,
                codeInit: { codeString in
                    return GetChatHistoryError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetChatHistoryError.common(error)
        }
    }
    

    
    
}
