//
//  GetWalkPayoutInfo.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkPayoutInfoRequest: Encodable {
    let walk: Int
}

struct GetWalkPayoutInfoDTO: Codable {
    let price: Int
    let fee: Int?
    let cancelAt: String?
    let cancelMessage: String?
    let penalty: Int?
    let rewardPrice: Int?
    let totalPrice: Int
}
