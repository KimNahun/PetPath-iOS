//
//  CancelApplyContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 6/12/25.
//

import Combine
import UIKit

final class CancelApplyContentViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: WalkerWalkDetailViewModel
    
    private let messageLabel = UILabel().then {
        $0.text = "지원 취소"
    }
    private let subMessageLabel = UILabel().then {
        $0.text = "지원을 취소하시겠습니까?"
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let cancelWalkButton = DangerButton().then {
        $0.setTitle("지원 취소하기", for: .normal)
    }
    
    init(viewModel: WalkerWalkDetailViewModel) {
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
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelWalkButton.addTarget(self, action: #selector(cancelWalkButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
       
    }
}
extension CancelApplyContentViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func cancelWalkButtonTapped() {
        viewModel.cancelWalkApply()
        dismiss(animated: true)
    }
    
}

extension CancelApplyContentViewController {
    private func setupLayOuts() {
        [messageLabel, subMessageLabel, cancelButton, cancelWalkButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(17)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        cancelWalkButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
    }
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 20)
        subMessageLabel.textColor = .neutral11
        subMessageLabel.font = FontSet.pretendardMedium(size: 14)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
