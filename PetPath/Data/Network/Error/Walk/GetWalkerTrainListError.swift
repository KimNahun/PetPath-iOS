//
//  GetWalkerTrainListError.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

enum GetWalkerTrainListErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetWalkerTrainListError: Error {
    case common(CommonError)
    case specific(GetWalkerTrainListErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkerTrainListErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
