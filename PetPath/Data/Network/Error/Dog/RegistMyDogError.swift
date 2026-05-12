//
//  RegistMyDogError.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

enum RegistMyDogErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case registNumIsAlreayInUse = "RegistNumIsAlreayInUse"
    case dogRegistNotFound = "DogRegistNotFound"
}

enum RegistMyDogError: Error {
    case common(CommonError)
    case specific(RegistMyDogErrorSpecific)
    
    init(serverErrorCode: String) {
        self = RegistMyDogErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
