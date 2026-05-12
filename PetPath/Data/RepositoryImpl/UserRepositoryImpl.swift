//
//  UserRepositoryImpl.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

import Moya

final class UserRepositoryImpl: UserRepository {
    
    private let service = CommonNetworkService()
    
    func getPushAlertSetting() async throws -> GetPushAlertSettingDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getPushAlertSetting.rawValue,
                param: EmptyParam(),
                successType: GetPushAlertSettingDTO.self,
                codeInit: { codeString in
                    return GetPushAlertSettingError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetPushAlertSettingError.common(error)
        }
    }
    
    func modifyPushAlertSetting(request: ModifyPushAlertSettingRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.modifyPushAlertSetting.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return ModifyPushAlertSettingError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw ModifyPushAlertSettingError.common(error)
        }
    }
    
    func deleteAccount(request: DeleteAccountRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.deleteAccount.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return DeleteAccountError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw DeleteAccountError.common(error)
        }
    }
    
    func getCertResult(impUid: String) async throws -> EmptyResponse {
        let param = GetCertResultRequest(impUid: impUid)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getCertResult.rawValue,
                param: param,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return GetCertResultError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetCertResultError.common(error)
        }
    }
    
    func signUp(request: SignUpRequest) async throws -> SignUpDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.signUp.rawValue,
                param: request,
                successType: SignUpDTO.self,
                codeInit: { codeString in
                    return SignUpError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw SignUpError.common(error)
        }
    }
    
    func findUserId(impUid: String) async throws -> FindUserIdDTO {
        let param = FindUserIdRequest(impUid: impUid)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.findUserId.rawValue,
                param: param,
                successType: FindUserIdDTO.self,
                codeInit: { codeString in
                    return FindUserIdError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw FindUserIdError.common(error)
        }
    }
    
    func findUserPassword(impUid: String, pw: String) async throws -> EmptyResponse {
        let param = FindUserPasswordRequest(impUid: impUid, pw: pw)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.findUserPassword.rawValue,
                param: param,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return FindUserPasswordError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw FindUserPasswordError.common(error)
        }
    }
    
    func signIn(email: String, pw: String) async throws -> SignInDTO {
        let param = SignInRequest(email: email, pw: pw)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.signIn.rawValue,
                param: param,
                successType: SignInDTO.self,
                codeInit: { codeString in
                    return SignInError(serverErrorCode: codeString)
                }
            )
            KeychainWorker.shared.create(key: .access, token: dto.token)
            return dto
        } catch let error as CommonError {
            throw SignInError.common(error)
        }
    }
    func getIsEmailUsing(email: String) async throws -> EmptyResponse {
        let param = GetIsEmailUsingRequest(email: email)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getIsEmailUsing.rawValue,
                param: param,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return GetIsEmailUsingError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetIsEmailUsingError.common(error)
        }
    }
    func getUserInfo() async throws -> GetUserInfoDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getUserInfo.rawValue,
                param: EmptyParam(),
                successType: GetUserInfoDTO.self,
                codeInit: { codeString in
                    return GetUserInfoError(serverErrorCode: codeString)
                }
            )
            KeychainWorker.shared.create(key: .access, token: dto.token)
            return dto
        } catch let error as CommonError {
            throw SignInError.common(error)
        }
    }
    func setAccountType(type: UserType) async throws -> SetAccountTypeDTO {
        let param = SetAccountTypeRequest(type: type)
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.setAccountType.rawValue,
                param: param,
                successType: SetAccountTypeDTO.self,
                codeInit: { codeString in
                    return SetAccountTypeError(serverErrorCode: codeString)
                }
            )
            KeychainWorker.shared.create(key: .access, token: dto.token)
            return dto
        } catch let error as CommonError {
            throw SetAccountTypeError.common(error)
        }
    }
    func setPushToken(request: SetPushTokenRequest) async throws -> EmptyResponse {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.setPushToken.rawValue,
                param: request,
                successType: EmptyResponse.self,
                codeInit: { codeString in
                    return SetPushTokenError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw SetPushTokenError.common(error)
        }
    }
    
    func getUserFullInfo() async throws -> GetUserFullInfoDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.getUserFullInfo.rawValue,
                param: EmptyParam(),
                successType: GetUserFullInfoDTO.self,
                codeInit: { codeString in
                    return GetUserInfoError(serverErrorCode: codeString)
                }
            )
            return dto
        } catch let error as CommonError {
            throw GetUserInfoError.common(error)
        }
    }
    
    func modifyUserInfo(request: ModifyUserInfoRequest) async throws -> ModifyUserInfoDTO {
        do {
            let dto = try await service.requestSingleOperation(
                operationName: APIRequestName.modifyUserInfo.rawValue,
                param: request,
                successType: ModifyUserInfoDTO.self,
                codeInit: { codeString in
                    return ModifyUserInfoError(serverErrorCode: codeString)
                }
            )
            KeychainWorker.shared.create(key: .access, token: dto.token)
            return dto
        } catch let error as CommonError {
            throw ModifyUserInfoError.common(error)
        }
    }
}
