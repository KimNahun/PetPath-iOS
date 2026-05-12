//
//  DeleteMyDogError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum DeleteMyDogErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case dogNotFound = "DogNotFound"
}

enum DeleteMyDogError: Error {
    case common(CommonError)
    case specific(DeleteMyDogErrorSpecific)
    
    init(serverErrorCode: String) {
        self = DeleteMyDogErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
