//
//  GetPayoutContractError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum GetPayoutContractErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetPayoutContractError: Error {
    case common(CommonError)
    case specific(GetPayoutContractErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetPayoutContractErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
