//
//  AppDelegate.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Firebase
import FirebaseMessaging
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    // 앱 실행 시 초기 설정
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        configureNavigationBar()
        registerForPushNotifications(application: application)
        BackgroundTaskManager.shared.registerTasks()
        return true
    }
    
    // 푸시 알림 권한 요청 및 등록
    func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }
    
    
    // APNs 토큰 등록 성공 시 Firebase에 설정
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // FCM 토큰 수신 콜백
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        KeychainWorker.shared.create(key: .fcm, token: token)
    }
    
    // Foreground에서 푸시 알림 수신 시 동작 (배너 등 표시)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let screen = userInfo["screen"] as? String else { return completionHandler() }
        guard let idString = userInfo["id"] as? String else { return completionHandler() }
        guard let accountTypeString = userInfo["accountType"] as? String,
              let accountType = UserType(rawValue: accountTypeString) else {
            return completionHandler()
        }
        
        setAccountTypeAndNavigate(to: screen, id: idString, accountType: accountType, completion: completionHandler)
    }
    func setAccountTypeAndNavigate(to screen: String, id: String, accountType: UserType, completion: @escaping () -> Void) {
        Task {
            do {
                let useCase = SetAccountTypeUseCaseImpl(repository: UserRepositoryImpl())
                _ = try await useCase.execute(type: accountType)
                DispatchQueue.main.async {
                    self.navigateToScreen(screen: screen, id: id, accountType: accountType)
                    completion()
                }
            } catch {
                print("❌ accountType 설정 실패: \(error.localizedDescription)")
                completion()
            }
        }
    }
    func navigateToScreen(screen: String, id: String, accountType: UserType) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navigationController = window.rootViewController as? UINavigationController else {
            return
        }
        let topVC = navigationController.topViewController
        let viewController: UIViewController
        switch screen {
        case "walkDetail":
            switch accountType {
            case .owner: viewController = OwnerWalkDetailViewController(viewModel: .init(id: Int(id) ?? 0))
            case .walker: viewController = WalkerWalkDetailViewController(viewModel: .init(id: Int(id) ?? 0))
            case .unknown: return
            }
        case "chatDetail":
            if let current = topVC as? ChatWebViewController, current.id == id {
                        // 이미 chat 화면이면 아무것도 하지 않음
                        return
                    }
                    viewController = ChatWebViewController(id: id, viewModel: .init())
        default: return
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    // 씬 연결 설정
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // 씬 제거 시 호출 (사용하지 않아도 무방)
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
