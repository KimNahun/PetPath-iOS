//
//  GetPushAlertSettingUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

protocol GetPushAlertSettingUseCase {
    func execute() async throws -> GetPushAlertSettingDTO
}

final class GetPushAlertSettingUseCaseImpl: GetPushAlertSettingUseCase {

    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    func execute() async throws -> GetPushAlertSettingDTO {
        return try await repository.getPushAlertSetting()
    }
}
