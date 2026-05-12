//
//  AddCardForm.swift
//  PetPath
//
//  Created by 김나훈 on 3/23/25.
//

import Foundation

struct AddCardForm {
    var cardParts: [String] = ["", "", "", ""]
    var expiryYear: String = ""
    var expiryMonth: String = ""
    var birthYear: String = ""
    var birthMonth: String = ""
    var birthDay: String = ""
    var pwd: String = ""
}

extension AddCardForm {
    func toRequest() -> AddCardRequest {
        let cardNum = cardParts.joined(separator: "-")

        let expiry = "\(expiryYear)-\(expiryMonth.padLeft(count: 2))"
        
        let birthday = formatBirthday(
            year: birthYear,
            month: birthMonth,
            day: birthDay
        )
        
        return AddCardRequest(
            cardNum: cardNum,
            expiry: expiry,
            birthday: birthday,
            pwd: pwd
        )
    }
    private func formatBirthday(year: String, month: String, day: String) -> String {
        guard year.count == 4 else { return "" }
        let yy = year.suffix(2)
        let mm = month.padLeft(count: 2)
        let dd = day.padLeft(count: 2)
        return "\(yy)\(mm)\(dd)"
    }
}
