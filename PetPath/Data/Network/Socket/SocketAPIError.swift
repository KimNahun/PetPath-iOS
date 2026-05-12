//
//  SocketAPIError.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Foundation

struct SocketAPIError<Code: Error>: Error {
    let code: Code
    let message: String?
    let target: String?
    let raw: Any?

    init(serverCode: String, message: String?, target: String?, raw: Any?, codeInit: (String) -> Code) {
        self.code = codeInit(serverCode)
        self.message = message
        self.target = target
        self.raw = raw
    }

    init(code: Code, message: String? = nil, target: String? = nil, raw: Any? = nil) {
        self.code = code
        self.message = message
        self.target = target
        self.raw = raw
    }
}
