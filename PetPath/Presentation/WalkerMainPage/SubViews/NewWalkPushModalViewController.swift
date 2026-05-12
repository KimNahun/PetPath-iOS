//
//  NewWalkPushModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 7/17/25.
//

import Combine
import UIKit

final class NewWalkPushModalViewController: UIViewController {
    
    let moveButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.textColor = .dark
        $0.text = "신규 산책 알림받기"
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = FontSet.pretendardBold(size: 18)
    }
    private let subMessageLabel = UILabel().then {
        $0.textColor = .neutral11
        $0.numberOfLines = 0
        $0.text = "현재 워커와 견주를 열심히 모집하고 있어요\n새로운 산책이 있다면 바로 알려드릴게요! 📢\n알림을 설정하고 조금만 기다려 주세요 🥺"
        $0.textAlignment = .center
        $0.font = FontSet.pretendardMedium(size: 12)
    }
    
    private let cancelButton = BottomPlacedButton(isSelected: true, backColor: .neutral5).then {
        $0.setTitle("닫기", for: .normal)
    }
    
    private let moveButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("설정으로 이동", for: .normal)
    }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        moveButton.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        
    }
}

extension NewWalkPushModalViewController {
    
    @objc private func cancelButtonTapped() {
        UserDefaultManager.shared.create(.walkPushModal)
        dismiss(animated: true)
    }
    
    @objc private func moveButtonTapped() {
        moveButtonPublisher.send()
        dismiss(animated: true)
    }
    
}

extension NewWalkPushModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, subMessageLabel, cancelButton, moveButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.horizontalEdges.equalToSuperview().inset(40)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(21)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
            $0.trailing.equalTo(view.snp.centerX).offset(-2)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-10)
        }
        moveButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
            $0.leading.equalTo(view.snp.centerX).offset(2)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
    }
}
