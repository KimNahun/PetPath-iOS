//
//  GetPayoutDetailError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum GetPayoutDetailErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case payoutHistoryNotFound = "PayoutHistoryNotFound"
}

enum GetPayoutDetailError: Error {
    case common(CommonError)
    case specific(GetPayoutDetailErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetPayoutDetailErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
