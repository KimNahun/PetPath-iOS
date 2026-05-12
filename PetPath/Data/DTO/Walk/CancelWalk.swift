//
//  CancelWalk.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Foundation

struct CancelWalkRequest: Encodable {
    let walk: Int
    var reason: String?
}
