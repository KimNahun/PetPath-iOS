//
//  WelcomeViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let welcomeLabel = UILabel().then {
        $0.setTitleBold(text: "환영합니다")
    }
    
    private let startButton = BottomPlacedButton(frame: .zero, isSelected: true) .then {
        $0.setTitle("펫패스 시작하기", for: .normal)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationRightButtons(keys: ["cancel"])
        bind()
        setupUI()
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("회원가입")
    }
}

extension WelcomeViewController {
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    }
    @objc private func startButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
            SignInViewController(viewModel: SignInViewModel())
        })
    }

    
}

extension WelcomeViewController {
    
    private func setupLayOuts() {
        [welcomeLabel, startButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(63)
        }
        startButton.snp.makeConstraints {
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
