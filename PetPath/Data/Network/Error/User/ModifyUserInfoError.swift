//
//  ModifyUserInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

enum ModifyUserInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case fileTokenIsNotValid = "FileTokenIsNotValid"
    case inputValueNotValid = "InputValueNotValid"
    case passwordIncorrect = "PasswordIncorrect"
    case alreadyInUse = "AlreadyInUse"
    case certInfoNotFound = "CertInfoNotFound"
    case notSupportImageFile = "NotSupportImageFile"
}

enum ModifyUserInfoError: Error {
    case common(CommonError)
    case specific(ModifyUserInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = ModifyUserInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
