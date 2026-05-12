//
//  GetWalkPredictPriceError.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

enum GetWalkPredictPriceErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetWalkPredictPriceError: Error {
    case common(CommonError)
    case specific(GetWalkPredictPriceErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkPredictPriceErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
