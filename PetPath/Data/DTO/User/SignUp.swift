//
//  SignUp.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Foundation

struct SignUpRequest: Codable {
    let marketingAgree: Bool
    let impUid, email, pw: String
    let source: SignupSourceType
    let sourceDetail: String?
    enum CodingKeys: String, CodingKey {
        case marketingAgree
        case impUid = "imp_uid"
        case email, pw, source, sourceDetail
    }
}

struct SignUpDTO: Decodable {
    let token: String
}

enum SignupSourceType: String, Codable, CaseIterable {
    case store = "앱/플레이 스토어"
    case community = "동네 커뮤니티 (당근마켓, 맘카페 등)"
    case sns = "SNS (인스타그램, 페이스북 등)"
    case engine = "검색엔진 (네이버, 구글 등)"
    case content = "블로그/유튜브 콘텐츠"
    case link = "이벤트/프로모션 링크"
    case advertisement = "실물광고 (전단지, 옥외광고 등)"
    case recommendation = "지인 추천"
    case etc = "기타"
}
