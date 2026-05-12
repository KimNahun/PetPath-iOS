//
//  GetWalkerTrainQuizError.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

enum GetWalkerTrainQuizErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case alreadyWalkerTrainComplete = "AlreadyWalkerTrainComplete"
    case walkerTrainStudyNotComplete = "WalkerTrainStudyNotComplete"
}

enum GetWalkerTrainQuizError: Error {
    case common(CommonError)
    case specific(GetWalkerTrainQuizErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetWalkerTrainQuizErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
