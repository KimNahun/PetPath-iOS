//
//  GetWalkerWalkAppliedError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkerWalkAppliedErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotApplied = "WalkNotApplied"
}

enum GetWalkerWalkAppliedError: Error {
    case common(CommonError)
    case specific(GetWalkerWalkAppliedErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkerWalkAppliedErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
