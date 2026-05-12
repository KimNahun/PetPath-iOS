//
//  FindUserIdError.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

enum FindUserIdErrorSpecific: String, Error, CaseIterable {
    case inputValueNotValid = "InputValueNotValid"
    case impUidRequired = "ImpUidRequired"
    case certInfoNotFound = "CertInfoNotFound"
    case userNotSignUp = "UserNotSignUp"
}

enum FindUserIdError: Error {
    case common(CommonError)
    case specific(FindUserIdErrorSpecific)
    
    init(serverErrorCode: String) {
        self = FindUserIdErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}

