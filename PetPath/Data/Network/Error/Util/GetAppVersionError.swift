//
//  GetAppVersionError.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import Foundation

enum GetAppVersionErrorSpecific: String, Error, CaseIterable {
    case none
}

enum GetAppVersionError: Error {
    case common(CommonError)
    case specific(GetAppVersionErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetAppVersionErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
