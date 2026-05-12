//
//  CertificationFailureViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class CertificationFailureViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let failureLabel = UILabel().then {
        $0.setTitleBold(text: "본인인증에 실패했습니다.")
    }
    private let messageLabel = UILabel().then {
        $0.text = "해당 현상이 지속된다면 문의해주시기 바랍니다."
    }
    private let backSignInButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("로그인으로 돌아가기", for: .normal)
    }
 
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        backSignInButton.addTarget(self, action: #selector(backSignInButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Bind
    
    private func bind() {
       
    }
}

extension CertificationFailureViewController {
    @objc private func backSignInButtonTapped() {        
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
            SignInViewController(viewModel: SignInViewModel())
        })
    }

    
}

extension CertificationFailureViewController {
    
    private func setupLayOuts() {
        [failureLabel, messageLabel, backSignInButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        failureLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(29)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(failureLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        backSignInButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
