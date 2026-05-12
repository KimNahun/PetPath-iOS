//
//  GetPaymentHistory.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetPaymentHistoryRequest: Encodable {
    let page: Int
}

struct PaymentHistoryData: Decodable, Hashable {
    let payMethod: String
    let amount: Int
    let pid: String
    let createAt: String
    let type: PaymentType
    let success: Bool
    let walk: Int?
}

enum PaymentType: String, Decodable {
    case pay
    case refund
    case unknown
    
    var koreanDescription: String {
        switch self {
        case .pay: return "결제"
        case .refund: return "환불"
        case .unknown: return "알수없음"
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PaymentType(rawValue: rawValue) ?? .unknown
    }
}
