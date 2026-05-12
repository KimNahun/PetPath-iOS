//
//  NotDeletableModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/26/25.
//

import UIKit

final class NotDeletableModalViewController: UIViewController {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.text = "지금은 탈퇴를 할 수 없어요."
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 18)
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "아래 사유를 참고해 주세요."
        $0.textColor = .neutral11
        $0.font = FontSet.pretendardMedium(size: 12)
    }
    
    private let reasonLabel = UILabel().then {
        $0.textColor = .error1
        $0.font = FontSet.pretendardMedium(size: 12)
        $0.numberOfLines = 0
    }
    private let closeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("닫기", for: .normal)
    }
    
    init(message: String) {
        self.reasonLabel.text = "탈퇴 불가사유: \(message)"
        super.init(nibName: nil, bundle: nil)
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
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        
    }
}

extension NotDeletableModalViewController {
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
}

extension NotDeletableModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, subMessageLabel, reasonLabel, closeButton].forEach {
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
        reasonLabel.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(2)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(reasonLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-18)
        }
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
    }
}
