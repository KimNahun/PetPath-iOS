//
//  ModifyPayoutContract.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct ModifyPayoutContractRequest: Encodable {
    var identifyNum: String?

    var identifyPhoto: String?
    var bankName: String?
    var accountNum: String?
    var accountOwnerName: String?
    var accountPhoto: String?

    var firstNum: String? {
        didSet {
            updateIdentifyNum()
        }
    }

    var secondNum: String? {
        didSet {
            updateIdentifyNum()
        }
    }

    private mutating func updateIdentifyNum() {
        if let first = firstNum, let second = secondNum {
            identifyNum = "\(first)-\(second)"
        } else {
            identifyNum = nil
        }
    }

}
