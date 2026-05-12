//
//  SearchAddressByKeywordUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import Foundation

protocol SearchAddressByKeywordUseCase {
    func execute(keyword: String) async throws -> [SearchAddressByKeywordDTO]
}

final class SearchAddressByKeywordUseCaseImpl: SearchAddressByKeywordUseCase {
    
    private let repository: UtilRepository
    
    init(repository: UtilRepository) {
        self.repository = repository
    }
    
    func execute(keyword: String) async throws -> [SearchAddressByKeywordDTO] {
        return try await repository.searchAddressByKeyword(keyword: keyword)
    }
}
