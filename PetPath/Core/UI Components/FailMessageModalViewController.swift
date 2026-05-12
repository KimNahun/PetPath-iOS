//
//  FailMessageModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/29/25.
//

import Combine
import UIKit

final class FailMessageModalViewController: UIViewController {
    
    let buttonTapPublisher = PassthroughSubject<Void, Never>()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.textColor = .dark
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = FontSet.pretendardBold(size: 18)
    }
    private let subMessageLabel = UILabel().then {
        $0.textColor = .neutral11
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = FontSet.pretendardMedium(size: 12)
    }

    private let actionButton = BottomPlacedButton(isSelected: true)
    
    init(message: String, subMessage: String, buttonMessage: String) {
        messageLabel.text = message
        subMessageLabel.text = subMessage
        actionButton.setTitle(buttonMessage, for: .normal)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    func setText(message: String? = nil, subMessage: String? = nil, buttonMessage: String? = nil) {
        messageLabel.text = message
        subMessageLabel.text = subMessage
        actionButton.setTitle(buttonMessage, for: .normal)
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
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        
    }
}

extension FailMessageModalViewController {
    
    @objc private func actionButtonTapped() {
        buttonTapPublisher.send()
    }
    
}

extension FailMessageModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, subMessageLabel, actionButton].forEach {
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
        actionButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
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
