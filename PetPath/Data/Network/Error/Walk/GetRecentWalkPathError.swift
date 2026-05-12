//
//  GetRecentWalkPathError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetRecentWalkPathErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum GetRecentWalkPathError: Error {
    case common(CommonError)
    case specific(GetRecentWalkPathErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetRecentWalkPathErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
