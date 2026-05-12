//
//  GetUserInfoError.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

enum GetUserInfoErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetUserInfoError: Error {
    case common(CommonError)
    case specific(GetUserInfoErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetUserInfoErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
