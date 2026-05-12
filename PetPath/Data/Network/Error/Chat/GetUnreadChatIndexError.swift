//
//  GetUnreadChatIndexError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetUnreadChatIndexErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case chatRoomNotFound = "ChatRoomNotFound"
}

enum GetUnreadChatIndexError: Error {
    case common(CommonError)
    case specific(GetUnreadChatIndexErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetUnreadChatIndexErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
