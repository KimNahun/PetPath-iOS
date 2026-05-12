//
//  SubmitWalkerTrainQuizError.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

enum SubmitWalkerTrainQuizErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case InputValueNotValid = "InputValueNotValid"
    case alreadyWalkerTrainComplete = "AlreadyWalkerTrainComplete"
    case walkerTrainStudyNotComplete = "WalkerTrainStudyNotComplete"
}

enum SubmitWalkerTrainQuizError: Error {
    case common(CommonError)
    case specific(SubmitWalkerTrainQuizErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SubmitWalkerTrainQuizErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
