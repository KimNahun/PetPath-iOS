//
//  MoyaProvider+Async.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

import Moya

extension MoyaProvider {
    /// Swift Concurrency 지원을 위한 async wrapper
    func requestAsync(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
