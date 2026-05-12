//
//  GetApplyWalkerListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetApplyWalkerListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case walkNotFound = "WalkNotFound"
    case walkAlreadyMatched = "WalkAlreadyMatched"
}

enum GetApplyWalkerListError: Error {
    case common(CommonError)
    case specific(GetApplyWalkerListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetApplyWalkerListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
