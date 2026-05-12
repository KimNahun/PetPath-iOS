//
//  PushWalkPosition.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Foundation

struct PushWalkPositionRequest: Encodable {
    let walk: Int
    let x: Double
    let y: Double
}

