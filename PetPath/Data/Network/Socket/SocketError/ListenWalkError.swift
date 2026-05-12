//
//  ListenWalkError.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

enum ListenWalkErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case walkNotFound = "WalkNotFound"
}

enum ListenWalkError: Error {
    case common(CommonError)
    case specific(ListenWalkErrorSpecific)

    init(serverErrorCode: String) {
        self = ListenWalkErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
