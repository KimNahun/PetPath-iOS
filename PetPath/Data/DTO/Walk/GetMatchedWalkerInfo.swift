//
//  GetMatchedWalkerInfo.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetMatchedWalkerInfoRequest: Encodable {
    let walk: Int
}

struct GetMatchedWalkerInfoDTO: Decodable {
    let profileImage: String
    let walkerName: String
    let gender: Gender
    let age: Int
    let description: String?
}
