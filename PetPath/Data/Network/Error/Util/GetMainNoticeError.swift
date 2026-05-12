//
//  GetMainNoticeError.swift
//  PetPath
//
//  Created by 김나훈 on 4/22/25.
//

import Foundation

enum GetMainNoticeErrorSpecific: String, Error, CaseIterable {
    case inputValueNotValid = "InputValueNotValid"
}

enum GetMainNoticeError: Error {
    case common(CommonError)
    case specific(GetMainNoticeErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetMainNoticeErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
