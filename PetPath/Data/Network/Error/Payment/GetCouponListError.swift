//
//  GetCouponListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetCouponListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum GetCouponListError: Error {
    case common(CommonError)
    case specific(GetCouponListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetCouponListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
