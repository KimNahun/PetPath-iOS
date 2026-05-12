//
//  GetWalkerTrainList.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

struct GetWalkerTrainListDTO: Decodable, Hashable {
    let title: String
    let page: Int
    let progress: Int
    let key: String
}
