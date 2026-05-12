//
//  FileUploadError.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Foundation

enum FileUploadErrorSpecific: String, Error, CaseIterable {
    case fileNotFound = "FileNotFound"
    case fileTooLarge = "FileTooLarge"
}

enum FileUploadError: Error {
    case common(CommonError)
    case specific(FileUploadErrorSpecific)
    
    init(serverErrorCode: String) {
        self = FileUploadErrorSpecific(rawValue: serverErrorCode).map { .specific($0) }
        ?? CommonError(rawValue: serverErrorCode).map { .common($0) }
        ?? .common(.unidentified)
    }
}
