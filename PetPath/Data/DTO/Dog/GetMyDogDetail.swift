//
//  GetMyDogDetail.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct GetMyDogDetailRequest: Encodable {
    let did: Int
}

struct GetMyDogDetailDTO: Decodable {
    var did: Int = 0
    var dogName: String = ""
    var gender: Gender = .unknown
    var isNeuter: Bool = false
    var species: String = ""
    var birthday: String = ""
    var profileImg: String = ""
    var size: DogSize = .small
    var char: [String] = []
    var require: [String] = []
    var description: String = ""
    var isVerified: Bool = false
}

extension GetMyDogDetailDTO {
    func toModifyDogInfo() -> ModifyDogInfoRequest {
        let birthYear = birthday.extractYearMonth()?.year ?? ""
        let birthMonth = birthday.extractYearMonth()?.month ?? ""
        return .init(did: did, ownerName: nil, registNumber: nil, species: species, dogName: dogName, gender: gender, isNeuter: isNeuter, profileImage: nil, birthday: birthday, size: size, char: char, require: require, description: description, isVerified: isVerified, birthYear: birthYear, birthMonth: birthMonth)
    }
}
