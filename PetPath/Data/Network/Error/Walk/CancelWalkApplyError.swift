//
//  CancelWalkApplyError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum CancelWalkApplyErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case walkStatusNotInFindWalker = "WalkStatusNotInFindWalker"
    case walkNotApplied = "WalkNotApplied"
}

enum CancelWalkApplyError: Error {
    case common(CommonError)
    case specific(CancelWalkApplyErrorSpecific)
    
    init(serverErrorCode: String) {
        self = CancelWalkApplyErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
