//
//  GetWalkRequestListError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkRequestListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetWalkRequestListError: Error {
    case common(CommonError)
    case specific(GetWalkRequestListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkRequestListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
