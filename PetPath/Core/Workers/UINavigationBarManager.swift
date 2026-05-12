//
//  UINavigationBarManager.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import UIKit
import Combine
import SnapKit
import ObjectiveC

private var buttonManagerKey: UInt8 = 0

final class NavigationBarButtonManager {
    private var subjects: [String: PassthroughSubject<Void, Never>] = [:]

    func publisher(for key: String) -> AnyPublisher<Void, Never> {
        if let existing = subjects[key] {
            return existing.eraseToAnyPublisher()
        }
        let new = PassthroughSubject<Void, Never>()
        subjects[key] = new
        return new.eraseToAnyPublisher()
    }

    func trigger(key: String) {
        subjects[key]?.send()
    }

    func clear() {
        subjects.removeAll()
    }
}

extension UIViewController {

    private var buttonManager: NavigationBarButtonManager {
        get {
            if let manager = objc_getAssociatedObject(self, &buttonManagerKey) as? NavigationBarButtonManager {
                return manager
            }
            let newManager = NavigationBarButtonManager()
            objc_setAssociatedObject(self, &buttonManagerKey, newManager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newManager
        }
    }

    /// 💡 시스템 back 유지 + title과 status를 왼쪽에 오버레이로 붙임
    func setNavigationTitle(_ title: String, status: WalkStatus? = nil) {
        guard let navBar = navigationController?.navigationBar else { return }

        // ✅ 기존 타이틀 뷰 제거
        navBar.subviews
            .filter { $0.tag == 9999 }
            .forEach { $0.removeFromSuperview() }

        navigationItem.title = nil
        navigationItem.titleView = nil

        // ✅ 타이틀 라벨
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = FontSet.pretendardBold(size: 16)
        titleLabel.textColor = .dark

        let stackView = UIStackView(arrangedSubviews: [titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center

        if let status = status {
            let statusLabel = PaddingLabel(padding: UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5))
            statusLabel.text = status.koreanDescription
            statusLabel.font = FontSet.pretendardSemiBold(size: 10)
            statusLabel.textColor = ColorSet.fromHex("3D3D3D")
            statusLabel.setBackgroundColor(with: status)
            statusLabel.layer.cornerRadius = 8
            statusLabel.clipsToBounds = true
            stackView.addArrangedSubview(statusLabel)
        }

        let titleContainer = UIView()
        titleContainer.tag = 9999
        navBar.addSubview(titleContainer)
        titleContainer.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }

        UIView.performWithoutAnimation {
            navBar.addSubview(titleContainer)
            titleContainer.snp.makeConstraints {
                $0.leading.equalTo(navBar.snp.leading).offset(33)
                $0.centerY.equalTo(navBar.snp.centerY).offset(-1)
                $0.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.6)
                $0.height.equalTo(44)
            }
            navBar.layoutIfNeeded() // 즉시 반영
        }

        navigationItem.titleView = UIView() // 충돌 방지
    }
    func setNavigationTitle(imageName: String) {
        guard let navBar = navigationController?.navigationBar else { return }

        // 기존 타이틀 제거
        navBar.subviews
            .filter { $0.tag == 9999 }
            .forEach { $0.removeFromSuperview() }

        navigationItem.title = nil
        navigationItem.titleView = nil

        // 이미지 뷰 생성
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints {
            $0.width.equalTo(65)
            $0.height.equalTo(25)
        }

        let containerView = UIView()
        containerView.tag = 9999
        containerView.addSubview(imageView)
        navBar.addSubview(containerView)

        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.equalTo(navBar.snp.leading).offset(20)
            $0.centerY.equalTo(navBar.snp.centerY).offset(-1)
            $0.width.equalTo(65)
            $0.height.equalTo(25)
        }

        navigationItem.titleView = UIView() // 충돌 방지용
    }
    // MARK: - 오른쪽 버튼 설정
    func setNavigationRightButtons(keys: [String]) {
        buttonManager.clear()
        let items: [UIBarButtonItem] = keys.reversed().map { key in
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: key), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            button.addAction(UIAction { [weak self] _ in
                self?.buttonManager.trigger(key: key)
            }, for: .touchUpInside)
            return UIBarButtonItem(customView: button)
        }
        navigationItem.rightBarButtonItems = items
    }

    // MARK: - 버튼 액션 구독
    func navigationButtonPublisher(for key: String) -> AnyPublisher<Void, Never> {
        buttonManager.publisher(for: key)
    }
}
