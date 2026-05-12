//
//  ApplyWalker.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct ApplyWalkerRequest: Encodable {
    let walk: Int
    var price: Int?
    var description: String?
}

struct WalkApplyNotAvailableResponse: Decodable {
    let reason: WalkApplyNotAvailableCase
}

enum WalkApplyNotAvailableCase: String, Decodable {
    case walkerTrainNotComplete
    case payMethodNotFound
    case penaltyNotPaid
    case unknown
    
    var message: String {
        switch self {
        case .walkerTrainNotComplete: "워커 교육을 이수하지 않아 산책에 지원할 수 없습니다.\n교육 이수 후 지원해 주세요."
        case .payMethodNotFound: "워커의 취소, 노쇼 등의 페널티 결제를 위한\n결제수단 등록이 필요합니다."
        case .penaltyNotPaid: "미결제 페널티가 존재하여 산책에 지원할 수 없습니다.\n고객센터를 통해 미결제 페널티를 결제해주세요"
        case .unknown: ""
        }
    }
    var buttonText: String {
        switch self {
        case .walkerTrainNotComplete: "워커 교육 이수하기"
        case .payMethodNotFound: "결제수단 등록"
        case .penaltyNotPaid: "홈으로 이동"
        case .unknown: ""
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = WalkApplyNotAvailableCase(rawValue: rawValue) ?? .unknown
    }
}
