//
//  FindUserPassword.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

struct FindUserPasswordRequest: Encodable {
    let impUid: String
    let pw: String
    
    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
        case pw
    }
}
