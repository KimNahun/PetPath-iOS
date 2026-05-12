//
//  GetUserFullInfoDTO.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

struct GetUserFullInfoDTO: Codable {
    let profileImg, name, phoneNumber: String
    let gender: Gender
    let email, nickname: String
}
