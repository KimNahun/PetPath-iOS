//
//  LastCardDeleteFailModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/17/25.
//

import UIKit

final class LastCardDeleteFailModalViewController: UIViewController {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.text = "지금은 제거할 수 없어요."
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 18)
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "진행 중이거나 진행 예정인 산책이 없을 때\n다시 시도해 주세요."
        $0.numberOfLines = 2
        $0.textColor = .error1
        $0.textAlignment = .center
        $0.font = FontSet.pretendardMedium(size: 12)
    }
    
    private let closeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("닫기", for: .normal)
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

extension LastCardDeleteFailModalViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
  
}

extension LastCardDeleteFailModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, subMessageLabel, closeButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.horizontalEdges.equalToSuperview().inset(39)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
    }
}
