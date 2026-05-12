//
//  ModifyDogInfo.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct ModifyDogInfoRequest: Encodable {
    var did: Int = 0
    var ownerName: String? = nil
    var registNumber: String? = nil
    var species: String? = nil
    var dogName: String? = nil
    var gender: Gender? = .unknown
    var isNeuter: Bool = false
    var profileImage: String? = nil
    var birthday: String = ""
    var size: DogSize = .unknown
    var char: [String] = []
    var require: [String] = []
    var description: String = ""
    var isVerified: Bool = false
    
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
