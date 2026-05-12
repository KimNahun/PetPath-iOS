//
//  AgeRejectionViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class AgeRejectionViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let ageWarningLabel = UILabel().then {
        $0.setTitleBold(text: "19세 미만은 펫패스를\n이용할 수 없어요")
    }
    
    private let backSignInButton = BottomPlacedButton(frame: .zero, isSelected: true) .then {
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
        backSignInButton.addTarget(self, action: #selector(backSignInButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("회원가입")
    }
}

extension AgeRejectionViewController {
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    }
    @objc private func backSignInButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
            SignInViewController(viewModel: SignInViewModel())
        })
    }
    
}

extension AgeRejectionViewController {
    
    private func setupLayOuts() {
        [ageWarningLabel, backSignInButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        ageWarningLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(63)
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
