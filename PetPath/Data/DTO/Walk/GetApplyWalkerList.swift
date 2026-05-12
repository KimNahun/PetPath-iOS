//
//  GetApplyWalkerList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetApplyWalkerListRequest: Encodable {
    let walk: Int
}

struct GetApplyWalkerListDTO: Decodable, Hashable {
    let pk: Int
    let profileImage: String
    let walkerName: String
    let gender: Gender
    let age: Int
    let price: Int
    let description: String
}
