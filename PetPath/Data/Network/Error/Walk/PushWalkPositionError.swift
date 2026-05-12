//
//  PushWalkPositionError.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Foundation

enum PushWalkPositionErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case InputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
    case walkNotWalking = "WalkNotWalking"
}

enum PushWalkPositionError: Error {
    case common(CommonError)
    case specific(PushWalkPositionErrorSpecific)
    
    init(serverErrorCode: String) {
        self = PushWalkPositionErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
