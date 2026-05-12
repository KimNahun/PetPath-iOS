//
//  GetWalkPaymentInfo.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkPaymentInfoRequest: Encodable {
    let walk: Int
}

struct GetWalkPaymentInfoDTO: Codable {
    let price: Int
    let discount: Int
    let payAt: String
    let totalPrice: Int
    let refundAt: String?
    let message: String?
    let penalty: Int?
    let refundPrice: Int?
}
