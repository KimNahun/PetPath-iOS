//
//  GetWalkerTrainQuiz.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

struct GetWalkerTrainQuizDTO: Decodable {
    let pk: Int
    let question: String
    let A: String
    let B: String
    let C: String
    let D: String
}
