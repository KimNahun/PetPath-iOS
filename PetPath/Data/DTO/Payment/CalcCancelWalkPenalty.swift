//
//  CalcCancelWalkPenalty.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct CalcCancelWalkPenaltyRequest: Encodable {
    let walk: Int
}

struct CalcCancelWalkPenaltyDTO: Decodable {
    let penalty: Int
    let startAt: String
}
