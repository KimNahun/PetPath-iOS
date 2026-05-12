//
//  GetWalkerWalkApplied.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkerWalkAppliedRequest: Encodable {
    let walk: Int
}

struct GetWalkerWalkAppliedDTO: Decodable {
    let price: Int
    let description: String
}
