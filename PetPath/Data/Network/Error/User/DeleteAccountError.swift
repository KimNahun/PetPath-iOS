//
//  DeleteAccountError.swift
//  PetPath
//
//  Created by 김나훈 on 4/26/25.
//

import Foundation

enum DeleteAccountErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case notDeletableAccount = "NotDeletableAccount"
}

enum DeleteAccountError: Error {
    case common(CommonError)
    case specific(DeleteAccountErrorSpecific)
    
    init(serverErrorCode: String) {
        self = DeleteAccountErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
