//
//  ModifyPayoutContractError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum ModifyPayoutContractErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case fileTokenIsNotValid = "FileTokenIsNotValid"
    case inputValueNotValid = "InputValueNotValid"
    case notSupportImageFile = "NotSupportImageFile"
}

enum ModifyPayoutContractError: Error {
    case common(CommonError)
    case specific(ModifyPayoutContractErrorSpecific)
    
    init(serverErrorCode: String) {
        self = ModifyPayoutContractErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
