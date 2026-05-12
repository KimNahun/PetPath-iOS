//
//  RequestReport.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Foundation

struct RequestReportRequest: Encodable {
    let walkId: Int
    let content: String
}
