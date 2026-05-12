//
//  CommonResponse.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

struct CommonResponse<T: Decodable>: Decodable {
    let response: Int
    let message: String?
    let errorCode: String?
    let target: String?
    let data: T?
}
