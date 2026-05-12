//
//  GetAvailableCouponList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetAvailableCouponListRequest: Encodable {
    let walk: Int
    var walker: Int?
}

struct GetAvailableCouponListDTO: Decodable {
    let pk: Int
    let description: String
    let type: String
    let amount: Int
}
