//
//  AppRouter.swift
//  PetPath
//
//  Created by 김나훈 on 7/14/25.
//

import UIKit

@MainActor
final class AppRouter {
    static let shared = AppRouter()

    private init() {}

    func setAccountAndNavigate(screen: String, id: String, accountType: UserType) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let useCase = SetAccountTypeUseCaseImpl(repository: UserRepositoryImpl())
                _ = try await useCase.execute(type: accountType)
                DispatchQueue.main.async { [weak self] in
                    self?.navigateToScreen(screen: screen, id: id, accountType: accountType)
                }
            } catch {
                print("❌ accountType 설정 실패: \(error.localizedDescription)")
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
            case .owner:
                viewController = OwnerWalkDetailViewController(viewModel: .init(id: Int(id) ?? 0))
            case .walker:
                viewController = WalkerWalkDetailViewController(viewModel: .init(id: Int(id) ?? 0))
            case .unknown:
                return
            }
        case "chatDetail":
            if let current = topVC as? ChatWebViewController, current.id == id {
                return
            }
            viewController = ChatWebViewController(id: id, viewModel: .init())

        case "pushAlertSetting":
            switch accountType {
            case .owner:
                viewController = OwnerPushViewController(viewModel: .init())
            case .walker:
                viewController = WalkerPushViewController(viewModel: .init())
            case .unknown:
                return
            }

        case "payoutContractView":
            viewController = ShowPayoutContractViewController(viewModel: .init())
            case "requestWalk":
                viewController = SelectDogViewController(viewModel: .init())
            case "addDog":
                viewController = RegistNumberViewController()
        case "":
            switch accountType {
            case .owner:
                navigationController.setViewControllers([OwnerMainPageViewController(viewModel: .init())], animated: true)
                return
            case .walker:
                navigationController.setViewControllers([WalkerMainPageViewController(viewModel: .init())], animated: true)
                return
            case .unknown:
                return
            }
        default: return
        }

        navigationController.pushViewController(viewController, animated: true)
    }
}
