//
//  GetMainCurrentWalkListError.swift
//  PetPath
//
//  Created by 김나훈 on 5/18/25.
//

import Foundation

enum GetMainCurrentWalkListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetMainCurrentWalkListError: Error {
    case common(CommonError)
    case specific(GetMainCurrentWalkListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetMainCurrentWalkListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
