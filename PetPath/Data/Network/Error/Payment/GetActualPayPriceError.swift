//
//  GetActualPayPriceError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetActualPayPriceErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case applyWalkerNotFound = "ApplyWalkerNotFound"
    case internalServerError = "InternalServerError"
    case couponNotFound = "CouponNotFound"
}

enum GetActualPayPriceError: Error {
    case common(CommonError)
    case specific(GetActualPayPriceErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetActualPayPriceErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
