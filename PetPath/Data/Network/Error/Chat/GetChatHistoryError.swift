//
//  GetChatHistoryError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetChatHistoryErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case chatRoomNotFound = "ChatRoomNotFound"
}

enum GetChatHistoryError: Error {
    case common(CommonError)
    case specific(GetChatHistoryErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetChatHistoryErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
