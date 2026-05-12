//
//  GetDogCertInfoValid.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Foundation

struct GetDogCertInfoValidRequest: Encodable {
    var ownerName: String
    var registNumber: String
}

struct GetDogCertInfoValidDTO: Decodable {
    let dogName: String
    let gender: String
    let isNeuter: Bool
    let species: String
}
