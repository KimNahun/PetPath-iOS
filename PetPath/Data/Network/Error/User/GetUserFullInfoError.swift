//
//  GetUserFullInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

enum GetUserFullInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetUserFullInfoError: Error {
    case common(CommonError)
    case specific(GetUserFullInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetUserFullInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
