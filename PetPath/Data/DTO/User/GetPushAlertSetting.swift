//
//  GetPushAlertSetting.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct GetPushAlertSettingDTO: Decodable {
    let marketing: Bool
    let newWalk: Bool
    let newWalkX: Double?
    let newWalkY: Double?
    let newWalkRange: WalkRange?
    let newWalkAddress: String?
}
extension GetPushAlertSettingDTO {
    func toModifyRequest() -> ModifyPushAlertSettingRequest {
        return ModifyPushAlertSettingRequest(
            marketing: self.marketing,
            newWalk: self.newWalk,
            newWalkX: nil,
            newWalkY: nil,
            newWalkRange: nil
        )
    }
}

enum WalkRange: String, Codable {
    case short
    case middle
    case long
    case unknown
    var koreanDescription: String {
        switch self {
        case .short: return "가까운 동네"
        case .middle: return "주변 동네"
        case .long: return "먼 동네"
        case .unknown: return ""
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = WalkRange(rawValue: rawValue) ?? .unknown
    }
}
