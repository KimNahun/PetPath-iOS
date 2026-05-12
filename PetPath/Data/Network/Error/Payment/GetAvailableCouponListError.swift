//
//  GetAvailableCouponListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetAvailableCouponListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case walkNotFindWalkerStatus = "WalkNotFindWalkerStatus"
    case applyWalkerNotFound = "ApplyWalkerNotFound"
    
}

enum GetAvailableCouponListError: Error {
    case common(CommonError)
    case specific(GetAvailableCouponListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetAvailableCouponListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
