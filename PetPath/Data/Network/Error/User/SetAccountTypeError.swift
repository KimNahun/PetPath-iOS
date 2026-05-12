//
//  SetAccountTypeError.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

enum SetAccountTypeErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum SetAccountTypeError: Error {
    case common(CommonError)
    case specific(SetAccountTypeErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SetAccountTypeErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
