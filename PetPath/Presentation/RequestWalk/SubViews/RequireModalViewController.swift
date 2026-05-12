//
//  RequireContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import UIKit

final class RequireModalViewController: UIViewController {
    
    private let viewModel: RequestWalkViewModel
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    private let messageLabel = UILabel().then {
        $0.text = "요청사항"
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 20)
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let requireTextField = BindableTextField().then {
        $0.placeholder = "요청사항을 입력해주세요"
    }
    private let completeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("완료", for: .normal)
    }
    
    init(viewModel: RequestWalkViewModel) {
        self.viewModel = viewModel
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
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        
    }
}

extension RequireModalViewController {
    
    @objc private func completeButtonTapped() {
        viewModel.finalRequest.require = requireTextField.text ?? ""
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension RequireModalViewController {
    private func setupLayOuts() {
        view.addSubview(containerView)
        [messageLabel, cancelButton, requireTextField, completeButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(166)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(messageLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        requireTextField.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(37)
        }
        completeButton.snp.makeConstraints {
            $0.top.equalTo(requireTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
        }

    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
    }
}
