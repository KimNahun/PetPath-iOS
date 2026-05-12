//
//  FileUploadAPI.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Moya

enum FileUploadAPI {
    case uploadFile(data: Data, fileName: String)
}

extension FileUploadAPI: TargetType {
    var baseURL: URL {
        return URL(string: UrlManager.baseUrl.urlString)!
    }

    var path: String {
        return "/API/fileUpload"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case .uploadFile(let data, let fileName):
            let formData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName, mimeType: "image/jpeg")
            return .uploadMultipart([formData])
        }
    }

    var headers: [String : String]? {
        var headers = ["Content-Type": "multipart/form-data"]
        if let token = KeychainWorker.shared.read(key: .access) {
            headers["auth"] = token
        }
        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
