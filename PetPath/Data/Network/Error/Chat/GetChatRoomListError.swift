//
//  GetChatRoomListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetChatRoomListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case accountTypeNotValid = "AccountTypeNotValid"
}

enum GetChatRoomListError: Error {
    case common(CommonError)
    case specific(GetChatRoomListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetChatRoomListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
