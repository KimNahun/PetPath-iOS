//
//  GetWalkerTrainContent.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

struct GetWalkerTrainContentRequest: Encodable {
    let key: String
}

struct GetWalkerTrainContentDTO: Decodable {
    let chapterTitle: String
    let pages: [TrainPage]
}

struct TrainPage: Decodable {
    let image: String
    let title: String
    let content: String
}
