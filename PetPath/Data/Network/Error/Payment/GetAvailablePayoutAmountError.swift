//
//  GetAvailablePayoutAmountError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum GetAvailablePayoutAmountErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetAvailablePayoutAmountError: Error {
    case common(CommonError)
    case specific(GetAvailablePayoutAmountErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetAvailablePayoutAmountErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
