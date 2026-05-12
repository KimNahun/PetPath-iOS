//
//  ApplyWalkerError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum ApplyWalkerErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case myWalkDenied = "MyWalkDenied"
    case walkAlreadyMatched = "WalkAlreadyMatched"
    case walkApplyNotAvailable = "WalkApplyNotAvailable"
    case alreadyAppliedWalk = "AlreadyAppliedWalk"
    case priceTooLow = "PriceTooLow"
    case walkerWalkTimeCollision = "WalkerWalkTimeCollision"
}

enum ApplyWalkerError: Error {
    case common(CommonError)
    case specific(ApplyWalkerErrorSpecific)
    
    init(serverErrorCode: String) {
        self = ApplyWalkerErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
