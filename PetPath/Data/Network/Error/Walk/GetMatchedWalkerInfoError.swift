//
//  GetMatchedWalkerInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetMatchedWalkerInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case walkerNotMatched = "WalkerNotMatched"
}

enum GetMatchedWalkerInfoError: Error {
    case common(CommonError)
    case specific(GetMatchedWalkerInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetMatchedWalkerInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
