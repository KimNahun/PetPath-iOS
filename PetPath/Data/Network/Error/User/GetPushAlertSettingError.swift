//
//  GetPushAlertSettingError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum GetPushAlertSettingErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
}

enum GetPushAlertSettingError: Error {
    case common(CommonError)
    case specific(GetPushAlertSettingErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetPushAlertSettingErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
