//
//  GetAppVersionUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import Foundation

protocol GetAppVersionUseCase {
    func execute() async throws -> GetAppVersionDTO
}

final class GetAppVersionUseCaseImpl: GetAppVersionUseCase {
    private let repository: UtilRepository

    init(repository: UtilRepository) {
        self.repository = repository
    }

    func execute() async throws -> GetAppVersionDTO {
        return try await repository.getAppVersion()
    }
}
