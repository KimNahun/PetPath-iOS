//
//  GetWalkHistoryListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkHistoryListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case accountTypeNotValid = "AccountTypeNotValid"
}

enum GetWalkHistoryListError: Error {
    case common(CommonError)
    case specific(GetWalkHistoryListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkHistoryListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
