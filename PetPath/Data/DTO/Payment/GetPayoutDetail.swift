//
//  GetPayoutDetail.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct GetPayoutDetailRequest: Encodable {
    let pk: Int
}

struct GetPayoutDetailDTO: Decodable {
    let createAt: String
    let total: Int
    let amount: Int
    let fee: Int
    let tax: Int
    let executeAt: String?
    let status: PayoutStatus
    let bank: String
    let accountNum: String
    let failMessage: String?
}
