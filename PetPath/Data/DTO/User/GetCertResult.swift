//
//  GetCertResult.swift
//  PetPath
//
//  Created by 김나훈 on 3/4/25.
//

import Foundation

struct GetCertResultRequest: Encodable {
    let impUid: String
    
    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
    }
}
