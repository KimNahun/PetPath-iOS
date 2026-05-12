//
//  SetAccountType.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

struct SetAccountTypeRequest: Encodable {
    let type: UserType
}

struct SetAccountTypeDTO: Decodable {
    let token: String
}
