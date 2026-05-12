//
//  GetPayoutHistory.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct GetPayoutHistoryDTO: Decodable, Hashable {
    let pk: Int
    let createAt: String
    let total: Int
    let status: PayoutStatus
}

enum PayoutStatus: String, Decodable {
    case pending
    case success
    case fail
    case unknown
    var koreanDescription: String {
        switch self {
        case .pending: return "정산 대기"
        case .success: return "정산 완료"
        case .fail: return "정산 실패"
        case .unknown: return ""
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PayoutStatus(rawValue: rawValue) ?? .unknown
    }
}
