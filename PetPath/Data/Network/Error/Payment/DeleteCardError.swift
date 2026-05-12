//
//  DeleteCardError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum DeleteCardErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case cardNotFound = "CardNotFound"
    case lastCardAndActiveWalkExist = "LastCardAndActiveWalkExist"
    case deleteCardFail = "DeleteCardFail"
}

enum DeleteCardError: Error {
    case common(CommonError)
    case specific(DeleteCardErrorSpecific)
    
    init(serverErrorCode: String) {
        self = DeleteCardErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
