//
//  PermissionModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import Combine
import UIKit
import UserNotifications
import CoreLocation

final class PermissionModalViewController: UIViewController {

    let permissionSuccessPublisher = PassthroughSubject<Void, Never>()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }

    private let messageLabel = UILabel().then {
        $0.text = "권한이 필요합니다"
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 20)
    }

    private let subMessageLabel = UILabel().then {
        $0.text = "이 기능을 활용하기 위해서는 권한이 필요합니다\n권한을 부여하시겠습니까?"
        $0.numberOfLines = 2
        $0.textColor = .dark
        $0.textAlignment = .center
        $0.font = FontSet.pretendardBold(size: 12)
    }
    private let descriptionLabel = UILabel().then {
        $0.text = "위치, 알림"
        $0.textColor = .neutral7
        $0.textAlignment = .center
        $0.font = FontSet.pretendardBold(size: 12)
    }

    private let settingsButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("설정으로 이동", for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        settingsButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionsOnForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func settingButtonTapped() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:])
    }

    @objc private func checkPermissionsOnForeground() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            let notificationGranted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            let locationStatus = CLLocationManager().authorizationStatus
            let locationGranted = locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways

            if notificationGranted && locationGranted {
                DispatchQueue.main.async {
                    self.permissionSuccessPublisher.send()
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension PermissionModalViewController {
    private func setupLayOuts() {
           view.addSubview(containerView)
           [messageLabel, subMessageLabel, descriptionLabel, settingsButton].forEach {
               containerView.addSubview($0)
           }
       }

       private func setupConstraints() {
           containerView.snp.makeConstraints {
               $0.center.equalToSuperview()
               $0.horizontalEdges.equalToSuperview().inset(21)
           }
           messageLabel.snp.makeConstraints {
               $0.top.equalToSuperview().offset(15)
               $0.centerX.equalToSuperview()
           }
           subMessageLabel.snp.makeConstraints {
               $0.top.equalTo(messageLabel.snp.bottom).offset(27)
               $0.centerX.equalToSuperview()
           }
           descriptionLabel.snp.makeConstraints {
               $0.top.equalTo(subMessageLabel.snp.bottom).offset(10)
               $0.centerX.equalToSuperview()
           }
           settingsButton.snp.makeConstraints {
               $0.top.equalTo(descriptionLabel.snp.bottom).offset(17)
               $0.leading.trailing.equalToSuperview().inset(16)
               $0.height.equalTo(44)
               $0.bottom.equalToSuperview().offset(-16)
           }
       }

       private func setupUI() {
           setupLayOuts()
           setupConstraints()
           view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
       }
}
