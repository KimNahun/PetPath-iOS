//
//  Int+.swift
//  PetPath
//
//  Created by 김나훈 on 3/26/25.
//

import Foundation

extension Int {
    var formattedWithComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
