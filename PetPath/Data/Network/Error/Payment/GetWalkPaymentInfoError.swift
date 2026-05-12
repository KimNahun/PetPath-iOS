//
//  GetWalkPaymentInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkPaymentInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case walkNotPaid = "WalkNotPaid"
}

enum GetWalkPaymentInfoError: Error {
    case common(CommonError)
    case specific(GetWalkPaymentInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkPaymentInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
