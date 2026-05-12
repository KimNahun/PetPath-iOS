//
//  PositionToAddressError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum PositionToAddressErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case internalServerError = "InternalServerError"
}

enum PositionToAddressError: Error {
    case common(CommonError)
    case specific(PositionToAddressErrorSpecific)
    
    init(serverErrorCode: String) {
        self = PositionToAddressErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
