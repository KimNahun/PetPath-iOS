//
//  GetUserInfo.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Foundation

struct GetUserInfoDTO: Decodable {
    let uid: Int
    let name: String
    var type: UserType?
    let profileImg: String
    let token: String
}
