//
//  GetPayoutContract.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct GetPayoutContractDTO: Decodable {
    let identifyNum: String?
    let identifyStatus: ContractStatus?
    let identifyDeniedReason: String?
    let accountNum: String?
    let accountOwnerName: String?
    let bankName: String?
    let accountStatus: ContractStatus?
    let accountDeniedReason: String?
}

enum ContractStatus: String, Decodable {
    case pending
    case denied
    case allow
    case unknown
    var koreanDescription: String {
        switch self {
        case .pending: return "심사중"
        case .denied: return "심사실패"
        case .allow: return "심사완료"
        case .unknown: return ""
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = ContractStatus(rawValue: rawValue) ?? .unknown
    }
}



