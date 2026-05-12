//
//  EndWalkError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum EndWalkErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case walkNotFound = "WalkNotFound"
    case walkAlreadyEnded = "WalkAlreadyEnded"
    case notWalkEndStep = "NotWalkEndStep"
}

enum EndWalkError: Error {
    case common(CommonError)
    case specific(EndWalkErrorSpecific)
    
    init(serverErrorCode: String) {
        self = EndWalkErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
