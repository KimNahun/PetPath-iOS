//
//  CommonAPI.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

import Moya

/// OperationRequest: "operation" + "param"
struct OperationRequest<Param: Encodable>: Encodable {
    let operation: String
    let param: Param
}

/// Moya Target: 공통 /API POST
enum CommonAPI {
    case sendOperations([AnyEncodable])
}
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    
    init<T: Encodable>(_ wrapped: T) {
        self.encodeFunc = { encoder in
            try wrapped.encode(to: encoder)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

extension CommonAPI: TargetType {
    var baseURL: URL {
        // 예시
        return URL(string: UrlManager.baseUrl.urlString)!
    }
    
    var path: String {
        return "/API"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .sendOperations(let ops):
            return .requestCustomJSONEncodable(ops, encoder: JSONEncoder())
        }
    }
    
    var headers: [String : String]? {
           var headers = ["Content-Type": "application/json"]
           if let token = KeychainWorker.shared.read(key: .access) {
               headers["auth"] = token 
           }
           return headers
       }
    
    
    var sampleData: Data {
        return Data()
    }
}
