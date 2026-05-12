//
//  CommonError.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

enum CommonError: String, Error, CaseIterable {
    case decode = "decode_error"
    case network = "network_error"
    case unknown = "unknown_error"
    case unidentified = "unidentified_error"
}
