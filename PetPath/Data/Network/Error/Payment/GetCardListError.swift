//
//  GetCardListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetCardListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetCardListError: Error {
    case common(CommonError)
    case specific(GetCardListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetCardListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
