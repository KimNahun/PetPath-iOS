//
//  FileUploadUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Foundation

protocol FileUploadUseCase {
    func execute(fileData: Data, fileName: String) async throws -> String
}

final class FileUploadUseCaseImpl: FileUploadUseCase {
    private let repository: UtilRepository

    init(repository: UtilRepository) {
        self.repository = repository
    }

    func execute(fileData: Data, fileName: String) async throws -> String {
        return try await repository.uploadFile(data: fileData, fileName: fileName)
    }
}
