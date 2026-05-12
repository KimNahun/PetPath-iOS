//
//  AddCardError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum AddCardErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case cardAlreadyAdded = "CardAlreadyAdded"
    case addCardFail = "AddCardFail"
}

enum AddCardError: Error {
    case common(CommonError)
    case specific(AddCardErrorSpecific)
    
    init(serverErrorCode: String) {
        self = AddCardErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
