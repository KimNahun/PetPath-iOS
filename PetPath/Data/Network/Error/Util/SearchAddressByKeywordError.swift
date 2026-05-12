//
//  SearchAddressByKeywordError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum SearchAddressByKeywordErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum SearchAddressByKeywordError: Error {
    case common(CommonError)
    case specific(SearchAddressByKeywordErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SearchAddressByKeywordErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
