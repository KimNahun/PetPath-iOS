//
//  GetPaymentHistoryError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetPaymentHistoryErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case accountTypeNotValid = "AccountTypeNotValid"
}

enum GetPaymentHistoryError: Error {
    case common(CommonError)
    case specific(GetPaymentHistoryErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetPaymentHistoryErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
