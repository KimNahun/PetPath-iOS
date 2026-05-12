//
//  SplashViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import Combine
import Foundation

final class SplashViewModel {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let getAppVersionUsecase = GetAppVersionUseCaseImpl(repository: UtilRepositoryImpl())
    private let setPushTokenUseCase = SetPushTokenUseCaseImpl(repository: UserRepositoryImpl())
    private let getUserInfoUseCase = GetUserInfoUseCaseImpl(repository: UserRepositoryImpl())
    /// 앱의 현재 버전이 낮은지 여부를 나타냄
    /// true: 업데이트 필요 / false: 최신 버전이거나 같음
    @Published var isVersion: Bool = false
    @Published var userType: UserType?
}

extension SplashViewModel {
    
    func getUserInfo() {
        Task {
            do {
                /// 아직 유저타입이 nil일수있기떄문에 unknown으로 바꿔서 워커 / 견주 선택창 진입 유도. nil은 실패시로만 있다고 가정.
                var type = try await GetUserInfoUseCaseImpl(repository: UserRepositoryImpl()).execute().type
                if type == nil { type = .unknown }
                userType = type
            } catch {
                userType = nil
            }
        }
    }
    func setPushToken() {
        if let token = KeychainWorker.shared.read(key: .fcm) {
            Task {
                do {
                    _ = try await setPushTokenUseCase.execute(request: .init(token: token))
                } catch let error as CommonAPIError<SetPushTokenError> {
                    Log.make().debug("\(error.message ?? "")")
                }
            }
        }
    }
    
    func getAppVersion() {
        Task {
            do {
                let requiredVersion = try await getAppVersionUsecase.execute().iOS
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                isVersion = isLowerThan(current: currentVersion, required: requiredVersion)
            } catch let error as CommonAPIError<GetPayoutDetailError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific:
                    ToastMessenger.shared.showToast(message: error.message ?? "")
                }
            }
        }
    }
    /// 두 버전 문자열을 비교하여 현재 버전이 더 낮은지를 판단하는 함수
    ///
    /// - Parameters:
    ///   - current: 현재 앱 버전 문자열 (예: "1.2.0")
    ///   - required: 서버에서 요구하는 최소 버전 문자열 (예: "1.3.0")
    /// - Returns: Bool. `true`이면 현재 버전이 낮고 업데이트가 필요함
    private func isLowerThan(current: String, required: String) -> Bool {
        // "." 기준으로 분할 후 숫자로 변환 (예: "1.2.0" -> [1, 2, 0])
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        let requiredComponents = required.split(separator: ".").compactMap { Int($0) }
        
        // 버전 자리수는 다를 수 있으므로 더 긴 배열을 기준으로 비교
        for i in 0..<max(currentComponents.count, requiredComponents.count) {
            let c = i < currentComponents.count ? currentComponents[i] : 0
            let r = i < requiredComponents.count ? requiredComponents[i] : 0
            
            // 현재 버전이 낮으면 true 반환 → 업데이트 필요
            if c < r { return true }
            
            // 현재 버전이 높으면 false → 업데이트 불필요
            if c > r { return false }
        }
        
        // 모든 자릿수가 동일하면 false → 동일 버전, 업데이트 불필요
        return false
    }
}
