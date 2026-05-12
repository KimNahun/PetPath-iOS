//
//  GetWalkPredictPrice.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkPredictPriceRequest: Encodable {
    let dogs: [Int]
    let startAt, endAt: String
    let requestPath: Int?
    let pickupX, pickupY: Double
    let pickupDetail, require: String
}
