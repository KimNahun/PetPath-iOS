//
//  GetMainCurrentWalkList.swift
//  PetPath
//
//  Created by 김나훈 on 5/18/25.
//

import Foundation

struct GetMainCurrentWalkListDTO: Codable, Hashable {
    let pk: Int
    let status: WalkStatus
    let title: String
    let startAt: String
    let endAt: String
    let pickupAddress: String
    let profileImg: String
    let applyWalkerCount: Int?
}
