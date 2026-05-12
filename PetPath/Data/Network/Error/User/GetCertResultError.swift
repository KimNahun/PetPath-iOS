//
//  GetCertResultError.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

enum GetCertResultErrorSpecific: String, Error, CaseIterable {
    case impUidRequired = "ImpUidRequired"
    case CertInfoNotFound = "CertInfoNotFound"
    case notAdult = "NotAdult"
    case alreadyInUse = "AlreadyInUse"
}

enum GetCertResultError: Error {
    case common(CommonError)
    case specific(GetCertResultErrorSpecific)
    
    init(serverErrorCode: String) {
        self = GetCertResultErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
