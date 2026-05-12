//
//  AddCard.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

struct AddCardRequest: Encodable {
    var cardNum: String
    var expiry: String
    var birthday: String
    var pwd: String
}
