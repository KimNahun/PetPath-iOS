//
//  GetCouponList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetCouponListRequest: Encodable {
    let type: CouponType
}

enum CouponType: String, Encodable {
    case active
    case used
}

enum CouponDescType: String, Decodable {
    case rate
    case sub
    case unknown
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CouponDescType(rawValue: rawValue) ?? .unknown
    }
}

struct GetCouponListDTO: Decodable, Hashable {
    let pk: Int
    let description: String
    let type: CouponDescType
    let amount: Int
    let activeMinPrice: Int
    let expireAt: String
    let useAt: String?
}
