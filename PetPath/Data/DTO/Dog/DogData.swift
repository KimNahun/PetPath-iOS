//
//  DogData.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

struct DogData: Decodable, Hashable {
    let did: Int
    let dogName: String
    let gender: Gender
    let species, birthday, profileImg: String
    let isNeuter, isVerified: Bool
}


