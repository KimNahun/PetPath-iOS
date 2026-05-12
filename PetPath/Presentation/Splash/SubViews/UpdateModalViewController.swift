//
//  UpdateModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/1/25.
//

import UIKit

final class UpdateModalViewController: UIViewController {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.text = "업데이트 필요"
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 20)
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "앱을 계속 사용하기 위해서 업데이트가 필요합니다.\n스토어에서 앱을 업데이트 해주세요."
        $0.numberOfLines = 2
        $0.textColor = .dark
        $0.textAlignment = .center
        $0.font = FontSet.pretendardBold(size: 12)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
    }
    
    private func bind() {
        
    }
}

extension UpdateModalViewController {
    
  
}

extension UpdateModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, subMessageLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.horizontalEdges.equalToSuperview().inset(21)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
    }
}
