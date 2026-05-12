//
//  NotSignupViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class NotSignupViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindIdViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let messageLabel = UILabel().then {
        $0.numberOfLines = 3
    }
    
    private let signupButton = CommonButton().then {
        $0.setTitle("회원가입하기", for: .normal)
    }
    
    private let backSignInButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("로그인으로 돌아가기", for: .normal)
    }
    
    init(viewModel: FindIdViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        messageLabel.setTitleBold(text: "고객님은\n펫패스에 가입되어있지\n않습니다")
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
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        backSignInButton.addTarget(self, action: #selector(backSignInButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("계정 찾기")
    }
    // MARK: - Bind
    
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    }
}

extension NotSignupViewController {
    @objc private func signupButtonTapped() {
        let viewController = AgreementViewController(viewModel: SignUpViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func backSignInButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
               SignInViewController(viewModel: SignInViewModel())
           })
    }
    
}

extension NotSignupViewController {
    
    private func setupLayOuts() {
        [messageLabel, signupButton, backSignInButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints { 
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(87)
        }
        signupButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(backSignInButton.snp.top).offset(-8)
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
