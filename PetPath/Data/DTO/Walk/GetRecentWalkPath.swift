//
//  GetRecentWalkPath.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetRecentWalkPathRequest: Encodable {
    let page: Int
}

struct GetRecentWalkPathDTO: Codable {
    let pk: Int
    let pickupX: Double
    let pickupY: Double
    let pickupAddress: String
    let pickupDetail: String
    let startAt: String
    let duration: Int
    let path: [Path]
}

struct Path: Codable {
    let x, y: Double
}
