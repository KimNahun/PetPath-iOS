//
//  PositionToAddress.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct PositionToAddressRequest: Encodable {
    let y: Double
    let x: Double
}

struct PositionToAddressDTO: Decodable {
    let roadAddress: String
    let address: String
}
