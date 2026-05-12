//
//  ModifyDogInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum ModifyDogInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case fileTokenIsNotValid = "FileTokenIsNotValid"
    case notSupportImageFile = "NotSupportImageFile"
    case dogNotFound = "DogNotFound"
    case registNumIsAlreayInUse = "RegistNumIsAlreayInUse"
    case dogRegistNotFound = "DogRegistNotFound"
}

enum ModifyDogInfoError: Error {
    case common(CommonError)
    case specific(ModifyDogInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = ModifyDogInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
