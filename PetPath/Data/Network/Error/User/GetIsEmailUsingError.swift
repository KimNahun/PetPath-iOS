//
//  GetIsEmailUsingError.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

enum GetIsEmailUsingErrorSpecific: String, Error, CaseIterable {
    case inputValueNotValid = "InputValueNotValid"
    case alreadyInUse = "AlreadyInUse"
}

enum GetIsEmailUsingError: Error {
    case common(CommonError)
    case specific(GetIsEmailUsingErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetIsEmailUsingErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
    
}
