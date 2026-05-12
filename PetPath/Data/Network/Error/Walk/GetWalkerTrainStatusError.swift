//
//  GetWalkerTrainStatusError.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

enum GetWalkerTrainStatusErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetWalkerTrainStatusError: Error {
    case common(CommonError)
    case specific(GetWalkerTrainStatusErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkerTrainStatusErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
