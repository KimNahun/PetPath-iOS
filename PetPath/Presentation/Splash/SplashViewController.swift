//
//  SplashViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import Combine
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SplashViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let logoImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "appLogoFill")
    }
    
    private let updateModalViewController = UpdateModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let permissionModalViewController = PermissionModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.getAppVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("")
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$isVersion.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isVersion in
            guard let self = self else { return }
            if isVersion {
                present(updateModalViewController, animated: true)
            } else {
                requestPermissionsIfNeeded()
                viewModel.getUserInfo()
                viewModel.setPushToken()
            }
        }.store(in: &subscriptions)
        
        viewModel.$userType.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] type in
            guard let self = self else { return }
            
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            let viewController: UIViewController
            switch type {
            case .owner: viewController = OwnerMainPageViewController(viewModel: MainPageViewModel())
            case .walker: viewController = WalkerMainPageViewController(viewModel: MainPageViewModel())
            case .unknown: viewController = SetTypeViewController(viewModel: SetTypeViewModel())
            case nil: viewController = SignInViewController(viewModel: SignInViewModel())
            }
            guard var viewControllers = navigationController?.viewControllers,
                  let index = viewControllers.firstIndex(of: self) else { return }
            
            viewControllers[index] = viewController
            navigationController?.setViewControllers(viewControllers, animated: true)
        }.store(in: &subscriptions)
        
        permissionModalViewController.permissionSuccessPublisher.sink { [weak self] in
            self?.viewModel.getUserInfo()
            self?.viewModel.setPushToken()
        }.store(in: &subscriptions)
    }
}

extension SplashViewController {
    private func requestPermissionsIfNeeded() {
        let group = DispatchGroup()
        
        var notificationAuthorized = false
        var locationAuthorized = false
        
        // 알림 권한
        group.enter()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            // ✅ 약간의 지연 후 실제 상태 확인
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized, .provisional:
                        notificationAuthorized = true
                    default:
                        notificationAuthorized = false
                    }
                    group.leave()
                }
            }
        }
        
        // 위치 권한
        group.enter()
        LocationManager.shared.onAuthorizationChanged = { status in
            print("📍 위치 권한 상태:", status.rawValue)
            locationAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
            
            // ✅ 무조건 마지막 권한 변경 시점에만 nil로 만듭니다
            if status != .notDetermined {
                LocationManager.shared.onAuthorizationChanged = nil
                group.leave()
            }
        }
        LocationManager.shared.requestAuthorizationIfNeeded()
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            print("🔔 알림 권한:", notificationAuthorized)
            print("📍 위치 권한:", locationAuthorized)
            
          //  if notificationAuthorized && locationAuthorized {
                viewModel.getUserInfo()
                viewModel.setPushToken()
//            } else {
//                present(permissionModalViewController, animated: true)
//            }
        }
    }
}

extension SplashViewController {
    
    private func setupLayOuts() {
        [logoImageView].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(143)
            $0.height.equalTo(129)
        }
    }
    
    private func setupComponents() {
        
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = ColorSet.fromHex("F8E36D")
    }
}

