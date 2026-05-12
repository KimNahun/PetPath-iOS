//
//  GetCardList.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct CardData: Decodable, Hashable {
    let cardId: String
    let firstNum: String
    let cardVendor: String
    let createAt: String
    let recentPay: String?
    let isSuccess: Bool?
}
