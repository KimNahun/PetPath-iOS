//
//  FindUserId.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

struct FindUserIdRequest: Encodable {
    let impUid: String
    
    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
    }
}

struct FindUserIdDTO: Decodable {
    let name: String
    let email: String
}
