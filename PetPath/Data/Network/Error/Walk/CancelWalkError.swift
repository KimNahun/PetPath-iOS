//
//  CancelWalkError.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Foundation

enum CancelWalkErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case notInStatusToCancel = "NotInStatusToCancel"
}

enum CancelWalkError: Error {
    case common(CommonError)
    case specific(CancelWalkErrorSpecific)
    
    init(serverErrorCode: String) {
        self = CancelWalkErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
