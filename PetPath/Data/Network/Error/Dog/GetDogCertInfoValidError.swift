//
//  GetDogCertInfoValidError.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Foundation

enum GetDogCertInfoValidErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case registNumIsAlreayInUse = "RegistNumIsAlreayInUse"
    case dogRegistNotFound = "DogRegistNotFound"
}

enum GetDogCertInfoValidError: Error {
    case common(CommonError)
    case specific(GetDogCertInfoValidErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetDogCertInfoValidErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
