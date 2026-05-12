//
//  CalcCancelWalkPenaltyError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum CalcCancelWalkPenaltyErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case notInStatusToCancel = "NotInStatusToCancel"
}

enum CalcCancelWalkPenaltyError: Error {
    case common(CommonError)
    case specific(CalcCancelWalkPenaltyErrorSpecific)
    
    init(serverErrorCode: String) {
        self = CalcCancelWalkPenaltyErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
