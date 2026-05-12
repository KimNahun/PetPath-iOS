//
//  GetKeywordTagListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

enum GetKeywordTagListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum GetKeywordTagListError: Error {
    case common(CommonError)
    case specific(GetKeywordTagListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetKeywordTagListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
