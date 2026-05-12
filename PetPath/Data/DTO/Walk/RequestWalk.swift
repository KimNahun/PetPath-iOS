//
//  RequestWalk.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct RequestWalkRequest: Encodable {
    var dogs: [Int] = []
    var startAt: String = ""
    var endAt: String = ""
    var requestPath: Int?
    var address: String = ""
    var pickupX: Double = 0.0
    var pickupY: Double = 0.0
    var pickupDetail: String = ""
    var require: String = ""
}

extension RequestWalkRequest {
    func toGetWalkPredictPriceRequest() -> GetWalkPredictPriceRequest {
        .init(dogs: dogs, startAt: startAt, endAt: endAt, requestPath: requestPath, pickupX: pickupX, pickupY: pickupY, pickupDetail: pickupDetail, require: require)
    }
}
