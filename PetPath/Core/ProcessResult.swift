//
//  ProcessResult.swift
//  PetPath
//
//  Created by 김나훈 on 3/10/25.
//

import Foundation

enum ProcessResult {
    case success(String?)
    case fail(String?) 
}

extension ProcessResult {
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}

