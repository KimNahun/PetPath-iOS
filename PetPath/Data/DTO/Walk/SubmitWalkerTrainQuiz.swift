//
//  SubmitWalkerTrainQuiz.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Foundation

struct SubmitWalkerTrainQuizRequest: Encodable {
    let pk: Int
    var answer: String
}

struct SubmitWalkerTrainQuizDTO: Decodable {
    let correct: Int
    let isPass: Bool
}
