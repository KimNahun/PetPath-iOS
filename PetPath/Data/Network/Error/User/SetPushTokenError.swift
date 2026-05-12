//
//  SetPushTokenError.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

enum SetPushTokenErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case InputValueNotValid = "InputValueNotValid"
    case fCMTokenNotValid = "FCMTokenNotValid"
}

enum SetPushTokenError: Error {
    case common(CommonError)
    case specific(SetPushTokenErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SetPushTokenErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
