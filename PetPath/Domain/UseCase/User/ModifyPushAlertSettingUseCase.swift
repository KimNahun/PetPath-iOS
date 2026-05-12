//
//  ModifyPushAlertSettingUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol ModifyPushAlertSettingUseCase {
    func execute(request: ModifyPushAlertSettingRequest) async throws -> EmptyResponse
}

final class ModifyPushAlertSettingUseCaseImpl: ModifyPushAlertSettingUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute(request: ModifyPushAlertSettingRequest) async throws -> EmptyResponse {
        return try await repository.modifyPushAlertSetting(request: request)
    }
}
