//
//  RequestReportError.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Foundation

enum RequestReportErrorSpecific: String, Error, CaseIterable {
    case unauthorized = "Unauthorized"
    case inputValueNotValid = "InputValueNotValid"
}

enum RequestReportError: Error {
    case common(CommonError)
    case specific(RequestReportErrorSpecific)
    
    init(serverErrorCode: String) {
        self = RequestReportErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
