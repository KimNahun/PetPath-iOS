//
//  GetWalkRequestList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkRequestListRequest: Encodable {
    let y: Double
    let x: Double
    let zoom: Double
}

struct GetWalkRequestListDTO: Decodable, Hashable {
    let pk: Int
    let title, startAt, endAt: String
    let pickupX, pickupY: Double
    let shortAddress, profileImg: String
    let size: DogSize
    let char, require: [String]
    let minPrice: Int
    let isApplied: Bool
}
