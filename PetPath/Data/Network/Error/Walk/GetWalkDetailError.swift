//
//  GetWalkDetailError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkDetailErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case accountTypeNotValid = "AccountTypeNotValid"
    case walkNotFound = "WalkNotFound"
    case walkAlreadyMatched = "WalkAlreadyMatched"
}

enum GetWalkDetailError: Error {
    case common(CommonError)
    case specific(GetWalkDetailErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkDetailErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
