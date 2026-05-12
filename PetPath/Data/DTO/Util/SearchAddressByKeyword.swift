//
//  SearchAddressByKeyword.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct SearchAddressByKeywordRequest: Encodable {
    let keyword: String
}

struct SearchAddressByKeywordDTO: Decodable, Hashable {
    let roadAddress: String
    let address: String
    let y: Double
    let x: Double
}
