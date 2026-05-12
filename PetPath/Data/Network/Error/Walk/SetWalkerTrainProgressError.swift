//
//  SetWalkerTrainProgressError.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

enum SetWalkerTrainProgressErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
    case chapterNotFound = "ChapterNotFound"
}

enum SetWalkerTrainProgressError: Error {
    case common(CommonError)
    case specific(SetWalkerTrainProgressErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SetWalkerTrainProgressErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
