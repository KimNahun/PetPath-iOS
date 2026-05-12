//
//  RequestWalkError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum RequestWalkErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case dogCountExceeded = "DogCountExceeded"
    case dogNotFound = "DogNotFound"
    case lessThanMinWalkTime = "LessThanMinWalkTime"
    case walkTimeExceeded = "WalkTimeExceeded"
    case walkStartTimeTooFast = "walkStartTimeTooFast"
    case walkStartTimeTooLate = "WalkStartTimeTooLate"
    case dogWalkTimeCollision = "DogWalkTimeCollision"
    case requestPathNotFound = "RequestPathNotFound"
}

enum RequestWalkError: Error {
    case common(CommonError)
    case specific(RequestWalkErrorSpecific)
    
    init(serverErrorCode: String) {
        self = RequestWalkErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
