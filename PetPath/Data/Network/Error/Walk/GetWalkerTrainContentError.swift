//
//  GetWalkerTrainContentError.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

enum GetWalkerTrainContentErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetWalkerTrainContentError: Error {
    case common(CommonError)
    case specific(GetWalkerTrainContentErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkerTrainContentErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
