//
//  ModifyUserInfo.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

struct ModifyUserInfoRequest: Codable {
    var profileImage, newPw: String?
}

struct ModifyUserInfoDTO: Decodable {
    let token: String
}
