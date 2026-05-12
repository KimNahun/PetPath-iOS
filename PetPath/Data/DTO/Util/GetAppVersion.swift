//
//  GetAppVersion.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import Foundation

struct GetAppVersionDTO: Decodable {
    let iOS: String

    private enum CodingKeys: String, CodingKey {
        case iOS = "IOS"
    }
}
