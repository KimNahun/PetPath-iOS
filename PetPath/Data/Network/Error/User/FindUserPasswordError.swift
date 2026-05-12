//
//  FindUserPasswordError.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

enum FindUserPasswordErrorSpecific: String, Error, CaseIterable {
    case inputValueNotValid = "InputValueNotValid"
    case impUidRequired = "ImpUidRequired"
}

enum FindUserPasswordError: Error {
    case common(CommonError)
    case specific(FindUserPasswordErrorSpecific)
    
    init(serverErrorCode: String) {
        self = FindUserPasswordErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
