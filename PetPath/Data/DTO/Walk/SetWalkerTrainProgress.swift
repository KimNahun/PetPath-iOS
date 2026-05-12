//
//  SetWalkerTrainProgress.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

struct SetWalkerTrainProgressRequest: Encodable {
    let key: String
    let progress: Int
}
