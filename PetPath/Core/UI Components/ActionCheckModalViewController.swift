//
//  ActionCheckModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 6/22/25.
//

import Combine
import UIKit

final class ActionCheckModalViewController: UIViewController {
    
    let processPublisher = PassthroughSubject<String?, Never>()
    private var actionId: String?
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.textColor = .dark
        $0.text = "알림"
        $0.textAlignment = .center
        $0.font = FontSet.pretendardBold(size: 18)
    }
    private let subMessageLabel = UILabel().then {
        $0.textColor = .neutral11
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = FontSet.pretendardMedium(size: 12)
    }
    
    private let cancelButton = BottomPlacedButton(isSelected: true, backColor: .neutral5).then {
        $0.setTitle("취소", for: .normal)
    }
    
    private let processButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("확인", for: .normal)
    }
    
    init(message: String) {
        subMessageLabel.text = message
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
        processButton.addTarget(self, action: #selector(processButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
     
    }
    func setActionId(id: String) {
        self.actionId = id
    }
}

extension ActionCheckModalViewController {
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func processButtonTapped() {
        processPublisher.send(actionId)
        dismiss(animated: true)
    }
    
}

extension ActionCheckModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, subMessageLabel, cancelButton, processButton].forEach {
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
        processButton.snp.makeConstraints {
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
