//
//  GetPayoutHistoryError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum GetPayoutHistoryErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetPayoutHistoryError: Error {
    case common(CommonError)
    case specific(GetPayoutHistoryErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetPayoutHistoryErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
