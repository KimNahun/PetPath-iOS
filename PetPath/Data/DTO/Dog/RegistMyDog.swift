//
//  RegistMyDog.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

struct RegistMyDogRequest: Encodable {
    var ownerName: String?
    var registNumber: String?
    var species: String?
    var dogName: String?
    var gender: Gender?
    var isNeuter: Bool?
    private(set) var birthday: String = ""
    var size: DogSize?
    var char: [String] = []
    var require: [String] = []
    var description: String = ""
    
    
    var birthYear: String? {
        didSet { updateBirthday() }
    }
    var birthMonth: String? {
        didSet { updateBirthday() }
    }
    
    private mutating func updateBirthday() {
        if let year = birthYear, let month = birthMonth, !year.isEmpty, !month.isEmpty {
            birthday = "\(year)-\(String(format: "%02d", Int(month) ?? 1))-01" 
        } else {
            birthday = ""
        }
    }
}

struct RegistMyDogDTO: Decodable {
    let dogName: String
    let gender: Gender
    let isNeuter: Bool
    let isVerified: Bool
    let species: String
    let birthday: String
    let profileImg: String
    let size: DogSize
    let char: [String]
    let require: [String]
    let description: String
}
