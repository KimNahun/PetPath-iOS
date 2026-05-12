//
//  SignUpError.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

enum SignUpErrorSpecific: String, Error, CaseIterable {
    case inputValueNotValid = "InputValueNotValid"
    case alreadyInUse = "AlreadyInUse"
    case certInfoNotFound = "CertInfoNotFound"
}

enum SignUpError: Error {
    case common(CommonError)
    case specific(SignUpErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SignUpErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
