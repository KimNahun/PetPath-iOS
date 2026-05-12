//
//  MatchWalkerError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum MatchWalkerErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case applyWalkerNotFound = "ApplyWalkerNotFound"
    case internalServerError = "InternalServerError"
    case couponNotFound = "CouponNotFound"
    case cardNotFound = "CardNotFound"
    case paymentFail = "PaymentFail"
}

enum MatchWalkerError: Error {
    case common(CommonError)
    case specific(MatchWalkerErrorSpecific)
    
    init(serverErrorCode: String) {
        self = MatchWalkerErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
