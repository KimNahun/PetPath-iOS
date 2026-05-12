//
//  UserRepository.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

import Foundation


protocol UserRepository {
    func getCertResult(impUid: String) async throws -> EmptyResponse
    func getIsEmailUsing(email: String) async throws -> EmptyResponse
    func signUp(request: SignUpRequest) async throws -> SignUpDTO
    func findUserId(impUid: String) async throws -> FindUserIdDTO
    func findUserPassword(impUid: String, pw: String) async throws -> EmptyResponse
    func signIn(email: String, pw: String) async throws -> SignInDTO
    func getUserInfo() async throws -> GetUserInfoDTO
    func setAccountType(type: UserType) async throws -> SetAccountTypeDTO
    func setPushToken(request: SetPushTokenRequest) async throws -> EmptyResponse
    func getUserFullInfo() async throws -> GetUserFullInfoDTO
    func modifyUserInfo(request: ModifyUserInfoRequest) async throws -> ModifyUserInfoDTO
    func deleteAccount(request: DeleteAccountRequest) async throws -> EmptyResponse
    func getPushAlertSetting() async throws -> GetPushAlertSettingDTO
    func modifyPushAlertSetting(request: ModifyPushAlertSettingRequest) async throws -> EmptyResponse
}
