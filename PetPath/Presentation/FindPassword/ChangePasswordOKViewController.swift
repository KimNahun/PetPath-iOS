//
//  ChangePasswordOKViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/13/25.
//

import Combine
import UIKit

final class ChangePasswordOKViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindPasswordViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let messageLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.setTitleBold(text: "비밀번호가 변경되었습니다.")
    }
    
    private let backSignInButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("로그인으로 돌아가기", for: .normal)
    }
    
    init(viewModel: FindPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationRightButtons(keys: ["cancel"])
        bind()
        backSignInButton.addTarget(self, action: #selector(backSignInButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("비밀번호 찾기")
        }
    // MARK: - Bind
    
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    }
}

extension ChangePasswordOKViewController {
    @objc private func backSignInButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
               SignInViewController(viewModel: SignInViewModel())
           })
    }

    
}

extension ChangePasswordOKViewController {
    
    private func setupLayOuts() {
        [messageLabel, backSignInButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(87)
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
