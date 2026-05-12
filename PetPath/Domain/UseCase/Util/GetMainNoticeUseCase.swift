//
//  GetMainNoticeUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/22/25.
//

import Foundation

protocol GetMainNoticeUseCase {
    func execute(request: GetMainNoticeRequest) async throws -> [GetMainNoticeDTO]
}

final class GetMainNoticeUseCaseImpl: GetMainNoticeUseCase {
    private let repository: UtilRepository

    init(repository: UtilRepository) {
        self.repository = repository
    }

    func execute(request: GetMainNoticeRequest) async throws -> [GetMainNoticeDTO] {
        return try await repository.getMainNotice(request: request)
    }
}
