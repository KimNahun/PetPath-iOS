//
//  WalkStatus.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Foundation

enum WalkStatus: String, Codable {
    case findWalker = "find-walker"
    case tobeWalk = "tobe-walk"
    case walking
    case endWalking = "end-walking"
    case ownerCancel = "owner-cancel"
    case ownerNoShow = "owner-no-show"
    case walkerCancel = "walker-cancel"
    case walkerNoShow = "walker-no-show"
    case walkerNotMatch = "walker-not-match"
    case unknown
    var koreanDescription: String {
        switch self {
        case .findWalker: return "모집중"
        case .tobeWalk: return "산책예정"
        case .walking: return "산책중"
        case .endWalking: return "산책 완료"
        case .ownerCancel: return "취소"
        case .ownerNoShow: return "취소"
        case .walkerCancel: return "취소"
        case .walkerNoShow: return "취소"
        case .walkerNotMatch: return "매칭실패"
        case .unknown: return "-"
        }
    }
    var koreanDetailDescription: String {
        switch self {
        case .findWalker: return "모집중"
        case .tobeWalk: return "산책예정"
        case .walking: return "산책중"
        case .endWalking: return "산책 완료"
        case .ownerCancel: return "견주 취소"
        case .ownerNoShow: return "견주 노쇼"
        case .walkerCancel: return "워커 취소"
        case .walkerNoShow: return "워커 노쇼"
        case .walkerNotMatch: return "매칭실패"
        case .unknown: return "-"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = WalkStatus(rawValue: rawValue) ?? .unknown
    }
}
