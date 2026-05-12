//
//  RequestPayoutError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum RequestPayoutErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case PayoutContractNotFound = "PayoutContractNotFound"
    case currentAvailableAmountNotValid = "CurrentAvailableAmountNotValid"
    case notPaidPenaltyExist = "NotPaidPenaltyExist"
}

enum RequestPayoutError: Error {
    case common(CommonError)
    case specific(RequestPayoutErrorSpecific)
    
    init(serverErrorCode: String) {
        self = RequestPayoutErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
