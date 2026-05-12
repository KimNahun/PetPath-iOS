//
//  UrlManager.swift
//  PetPath
//
//  Created by 김나훈 on 4/21/25.
//

import Foundation

enum UrlManager {
    
    case baseUrl
    case service
    case privacy
    case marketing
    case payment
    case location
    var urlString: String {
        switch self {
        case .baseUrl:
            return Bundle.main.infoDictionary?["BASE_URL"] as? String ?? ""
        case .service:
            return "\(UrlManager.baseUrl.urlString)/app/terms/service"
        case .privacy:
            return "\(UrlManager.baseUrl.urlString)/app/terms/privacy"
        case .marketing:
            return "\(UrlManager.baseUrl.urlString)/app/terms/marketing"
        case .payment:
            return "\(UrlManager.baseUrl.urlString)/app/terms/payment"
        case .location:
            return "\(UrlManager.baseUrl.urlString)/app/terms/location"
        }
    }
    
    var url: URL? {
        URL(string: self.urlString)
    }
    static var isDev: Bool {
        return UrlManager.baseUrl.urlString.contains("dev")
    }
}
