//
//  StartWalkError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum StartWalkErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case walkNotFound = "WalkNotFound"
    case walkAlreadyStarted = "WalkAlreadyStarted"
    case notWalkStartStep = "NotWalkStartStep"
}

enum StartWalkError: Error {
    case common(CommonError)
    case specific(StartWalkErrorSpecific)
    
    init(serverErrorCode: String) {
        self = StartWalkErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
