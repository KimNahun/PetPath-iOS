//
//  GetWalkPayoutInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkPayoutInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case walkNotPaid = "WalkNotPaid"
}

enum GetWalkPayoutInfoError: Error {
    case common(CommonError)
    case specific(GetWalkPayoutInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkPayoutInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
