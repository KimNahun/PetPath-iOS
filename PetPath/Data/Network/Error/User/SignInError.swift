//
//  SignInError.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

enum SignInErrorSpecific: String, Error, CaseIterable {
    case formInputRequired = "FormInputRequired"
    case userNotFound = "UserNotFound"
}

enum SignInError: Error {
    case common(CommonError)
    case specific(SignInErrorSpecific)
    
    init(serverErrorCode: String) {
        self = SignInErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
