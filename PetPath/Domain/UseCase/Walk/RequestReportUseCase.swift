//
//  RequestReportUseCase.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Foundation

protocol RequestReportUseCase {
    func execute(request: RequestReportRequest) async throws -> EmptyResponse
}

final class RequestReportUseCaseImpl: RequestReportUseCase {
    
    private let repository: WalkRepository
    
    init(repository: WalkRepository) {
        self.repository = repository
    }
    func execute(request: RequestReportRequest) async throws -> EmptyResponse {
        return try await repository.requestReport(request: request)
    }
   
}
