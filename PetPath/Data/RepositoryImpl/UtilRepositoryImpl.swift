//
//  UtilRepositoryImpl.swift
//  PetPath
//
//  Created by 김나훈 on 3/20/25.
//

import Foundation

final class UtilRepositoryImpl: UtilRepository {
    
    private let service = CommonNetworkService()
    private let uploadService = FileUploadNetworkService()
    
    func getAppVersion() async throws -> GetAppVersionDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getAppVersion.rawValue,
                param: EmptyParam(),
                successType: GetAppVersionDTO.self,
                codeInit: { codeString in
                    return GetAppVersionError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetAppVersionError.common(error)
        }
    }
    
    func getMainNotice(request: GetMainNoticeRequest) async throws -> [GetMainNoticeDTO] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getMainNotice.rawValue,
                param: request,
                successType: [GetMainNoticeDTO].self,
                codeInit: { codeString in
                    return GetMainNoticeError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetMainNoticeError.common(error)
        }
    }
    
    func uploadFile(data: Data, fileName: String) async throws -> String {
            return try await uploadService.uploadFile(
                data: data,
                fileName: fileName,
                codeInit: { FileUploadError(serverErrorCode: $0) }
            )
        }
    
    func searchAddressByKeyword(keyword: String) async throws -> [SearchAddressByKeywordDTO] {
        let param = SearchAddressByKeywordRequest(keyword: keyword)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.searchAddressByKeyword.rawValue,
                param: param,
                successType: [SearchAddressByKeywordDTO].self,
                codeInit: { codeString in
                    return SearchAddressByKeywordError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw SearchAddressByKeywordError.common(error)
        }
    }
    
    func positionToAddress(request: PositionToAddressRequest) async throws -> PositionToAddressDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.positionToAddress.rawValue,
                param: request,
                successType: PositionToAddressDTO.self,
                codeInit: { codeString in
                    return PositionToAddressError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw PositionToAddressError.common(error)
        }
    }
    
    
}
