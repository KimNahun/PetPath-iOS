//
//  SignIn.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

import Foundation

struct SignInRequest: Encodable {
    let email: String
    let pw: String
    let deviceType: String = "IOS"
}

struct SignInDTO: Decodable {
    let token: String
}
