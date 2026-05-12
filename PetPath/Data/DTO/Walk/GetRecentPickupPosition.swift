//
//  GetRecentPickupPosition.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetRecentPickupPositionDTO: Decodable, Hashable {
    let pickupY: Double
    let pickupX: Double
    let pickupAddress: String
    let pickupDetail: String
}
