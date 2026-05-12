//
//  UtilRepository.swift
//  PetPath
//
//  Created by 김나훈 on 3/19/25.
//

import Foundation

protocol UtilRepository {
    func searchAddressByKeyword(keyword: String) async throws -> [SearchAddressByKeywordDTO]
    func positionToAddress(request: PositionToAddressRequest) async throws -> PositionToAddressDTO
    func uploadFile(data: Data, fileName: String) async throws -> String
    func getMainNotice(request: GetMainNoticeRequest) async throws -> [GetMainNoticeDTO]
    func getAppVersion() async throws -> GetAppVersionDTO
}

