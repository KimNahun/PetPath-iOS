//
//  GetRecentPickupPositionError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetRecentPickupPositionErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetRecentPickupPositionError: Error {
    case common(CommonError)
    case specific(GetRecentPickupPositionErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetRecentPickupPositionErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
