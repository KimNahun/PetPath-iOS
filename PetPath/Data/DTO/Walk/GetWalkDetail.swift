//
//  GetWalkDetail.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetWalkDetailRequest: Encodable {
    let walk: Int
}

struct GetWalkDetailDTO: Decodable {
    let pk: Int
    let status: WalkStatus
    let owner: Int
    let walker: Int?
    let predictPrice: Int
    let title, startAt: String
    let endAt: String
    let price: Int
    let pickupX, pickupY: Double
    let pickupAddress: String
    let pickupDetail, request: String
    let qrUrl: String?
    let dogs: [DogDTO]
}

struct DogDTO: Decodable, Hashable {
    var did: Int
    var dogName: String
    var gender: Gender
    var isNeuter: Bool
    var species: String
    var birthday: String
    var profileImg: String
    var size: DogSize
    var char: [String]
    var require: [String]
    var description: String
}
