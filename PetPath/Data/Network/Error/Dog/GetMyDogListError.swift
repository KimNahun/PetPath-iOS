//
//  GetMyDogListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//


import Foundation

enum GetMyDogListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetMyDogListError: Error {
    case common(CommonError)
    case specific(GetMyDogListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetMyDogListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
