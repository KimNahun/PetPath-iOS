//
//  GetActualPayPrice.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetActualPayPriceRequest: Encodable {
    let walk: Int
    var walker: Int?
    var coupon: Int?
}

struct GetActualPayPriceDTO: Decodable {
    let totalPrice: Double
}
