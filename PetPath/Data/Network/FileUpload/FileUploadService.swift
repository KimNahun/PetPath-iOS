//
//  FileUploadService.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Moya

final class FileUploadNetworkService {
    private let provider = MoyaProvider<FileUploadAPI>()

    func uploadFile<Code: Error>(
        data: Data,
        fileName: String,
        codeInit: @escaping (String) -> Code
    ) async throws -> String {
        do {
            let response = try await provider.requestAsync(.uploadFile(data: data, fileName: fileName))
            print("🟦 Upload Status: \(response.statusCode)")

            let decoded = try JSONDecoder().decode(CommonResponse<String>.self, from: response.data)

            guard decoded.response == 200, let token = decoded.data else {
                throw CommonAPIError<Code>(
                    serverCode: decoded.errorCode ?? "unknown_error",
                    message: decoded.message,
                    target: decoded.target, data: nil,
                    codeInit: codeInit
                )
            }

            return token

        } catch let moyaErr as MoyaError {
            throw CommonAPIError<Code>(
                serverCode: "network_error",
                message: moyaErr.localizedDescription,
                target: nil, data: nil,
                codeInit: codeInit
            )
        } catch let decodingErr as DecodingError {
            throw CommonAPIError<Code>(
                serverCode: "decode_error",
                message: "응답 디코딩 실패",
                target: nil, data: nil,
                codeInit: codeInit
            )
        } catch {
            throw CommonAPIError<Code>(
                serverCode: "unknown_error",
                message: error.localizedDescription,
                target: nil, data: nil,
                codeInit: codeInit
            )
        }
    }
}
