//
//  DeleteAccount.swift
//  PetPath
//
//  Created by 김나훈 on 4/26/25.
//

import Foundation

struct DeleteAccountRequest: Encodable {
    var reason: String?
    var reasonDetail: String?
}


struct NotDeletableAccountResponse: Decodable {
    let reason: String
}
