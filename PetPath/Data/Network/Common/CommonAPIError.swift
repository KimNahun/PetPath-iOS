//
//  CommonAPIError.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

struct CommonAPIError<Code: Error>: Error {
    let code: Code
    let message: String?
    let target: String?
    let underlying: Error?
    let data: Any?

    /// 서버 에러 (response != 200) 생성자
    init(serverCode: String, message: String?, target: String?, data: Any?, codeInit: (String) -> Code) {
        self.code = codeInit(serverCode)
        self.message = message
        self.target = target
        self.underlying = nil
        self.data = data
    }
    
    /// 네트워크/디코딩/기타 에러 생성자
    init(code: Code, message: String? = nil, target: String? = nil, underlying: Error? = nil, data: Any? = nil) {
        self.code = code
        self.message = message
        self.target = target
        self.underlying = underlying
        self.data = data
    }
}
