//
//  ExistingUserViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class ExistingUserViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let existingUserLabel = UILabel().then {
        $0.setTitleBold(text: "이미 가입된 회원입니다")
    }
    
    private let findIdButton = CommonButton().then {
        $0.setTitle("계정 찾기", for: .normal)
    }
    
    private let findPasswordButton = CommonButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
    }
    
    private let backSignInButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("로그인으로 돌아가기", for: .normal)
    }
   
    init(viewModel: SignUpViewModel) {
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
        findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        backSignInButton.addTarget(self, action: #selector(backSignInButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("회원가입")
    }
}

extension ExistingUserViewController {
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    }
    @objc private func findIdButtonTapped() {
        let SigninViewController = SignInViewController(viewModel: SignInViewModel())
        let certificationAgreementViewController = CertificationAgreementViewController(type: .findId, viewModel: CertificationAgreeementViewModel())
        navigationController?.setViewControllers([SigninViewController, certificationAgreementViewController], animated: true)
    }
    @objc private func findPasswordButtonTapped() {
        let SigninViewController = SignInViewController(viewModel: SignInViewModel())
        let certificationAgreementViewController = CertificationAgreementViewController(type: .findPassword, viewModel: CertificationAgreeementViewModel())
        navigationController?.setViewControllers([SigninViewController, certificationAgreementViewController], animated: true)
    }
    @objc private func backSignInButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
            SignInViewController(viewModel: SignInViewModel())
        })
    }
    
}

extension ExistingUserViewController {
    
    private func setupLayOuts() {
        [existingUserLabel, findIdButton, findPasswordButton, backSignInButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        existingUserLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(63)
        }
        findIdButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(findPasswordButton.snp.top).offset(-16)
        }
        findPasswordButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(backSignInButton.snp.top).offset(-16)
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
