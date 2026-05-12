//
//  GetKeywordTagListUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

protocol GetKeywordTagListUseCase {
    func execute() async throws -> KeywordTagList
}

final class GetKeywordTagListUseCaseImpl: GetKeywordTagListUseCase {
    
    private let repository: DogRepository
    
    init(repository: DogRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> KeywordTagList {
        return try await repository.getKeywordTagList().toDomain()
    }
}
