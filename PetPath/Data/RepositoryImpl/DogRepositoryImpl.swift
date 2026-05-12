//
//  DogRepositoryImpl.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

final class DogRepositoryImpl: DogRepository {
        
    private let service = CommonNetworkService()
 
    func modifyDogInfo(request: ModifyDogInfoRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.modifyDogInfo.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return ModifyDogInfoError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw ModifyDogInfoError.common(error)
        }
    }
    
    func deleteMyDog(id: Int) async throws -> EmptyResponse {
        let param = DeleteMyDogRequest(did: id)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.deleteMyDog.rawValue,
                param: param,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return DeleteMyDogError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw DeleteMyDogError.common(error)
        }
    }
    
    func getMyDogDetail(id: Int) async throws -> GetMyDogDetailDTO {
        let param = GetMyDogDetailRequest(did: id)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getMyDogDetail.rawValue,
                param: param,
                successType: GetMyDogDetailDTO.self,
                codeInit: { codeString in
                    return GetMyDogDetailError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetMyDogDetailError.common(error)
        }
    }
    
    func registMyDog(request: RegistMyDogRequest) async throws -> RegistMyDogDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.registMyDog.rawValue,
                param: request,
                successType: RegistMyDogDTO.self,
                codeInit: { codeString in
                    return RegistMyDogError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw RegistMyDogError.common(error)
        }
    }
    
    func getMyDogList() async throws -> [DogData] {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getMyDogList.rawValue,
                param: EmptyParam(),
                successType: [DogData].self,
                codeInit: { codeString in
                    return GetMyDogListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetMyDogListError.common(error)
        }
    }
    func getDogCertInfoValid(request: GetDogCertInfoValidRequest) async throws -> GetDogCertInfoValidDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getDogCertInfoValid.rawValue,
                param: request,
                successType: GetDogCertInfoValidDTO.self,
                codeInit: { codeString in
                    return GetDogCertInfoValidError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetDogCertInfoValidError.common(error)
        }
    }
    
    func getKeywordTagList() async throws -> GetKeywordTagListDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getKeywordTagList.rawValue,
                param: EmptyParam(),
                successType: GetKeywordTagListDTO.self,
                codeInit: { codeString in
                    return GetKeywordTagListError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetKeywordTagListError.common(error)
        }
    }
    
}
