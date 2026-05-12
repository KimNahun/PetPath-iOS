//
//  GetMyDogDetailError.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

enum GetMyDogDetailErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case dogNotFound = "DogNotFound"
}

enum GetMyDogDetailError: Error {
    case common(CommonError)
    case specific(GetMyDogDetailErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetMyDogDetailErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
