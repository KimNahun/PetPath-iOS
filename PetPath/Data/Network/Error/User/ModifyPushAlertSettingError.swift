//
//  ModifyPushAlertSettingError.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

enum ModifyPushAlertSettingErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum ModifyPushAlertSettingError: Error {
    case common(CommonError)
    case specific(ModifyPushAlertSettingErrorSpecific)
    
    init(serverErrorCode: String) {
        self = ModifyPushAlertSettingErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
