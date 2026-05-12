//
//  SetEmailViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class SetEmailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let emailLabel = UILabel().then {
        $0.setTitleBold(text: "이메일을\n입력해주세요")
        $0.numberOfLines = 2
    }
    
    private let emailCaptionTextField = BindableCaptionTextField(title: "이메일 설정").then {
        $0.setPlaceHolder(text: "이메일")
    }
    
    private let nextButton = BottomPlacedButton().then {
        $0.setTitle("다음", for: .normal)
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
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("회원가입")
    }
    
    
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    
        emailCaptionTextField.textPublisher.assign(to: \.id, on: viewModel)
            .store(in: &subscriptions)
        
        viewModel.$isValidEmail
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] isValid in
                self?.emailCaptionTextField.setState(success: isValid)
                self?.nextButton.setupButtonStatus(isSelected: isValid)
                if !isValid {
                    self?.emailCaptionTextField.setCaptionText(text: "이메일 형식이 잘못되었습니다.")
                    self?.emailCaptionTextField.setState(success: false)
                }
            }.store(in: &subscriptions)
        
        viewModel.$getIsEmailUsingSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] success in
                guard let strongSelf = self else { return }
                let viewController = SetPasswordViewController(viewModel: strongSelf.viewModel)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscriptions)
        
        viewModel.$idErrorMessage.receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] text in
                self?.emailCaptionTextField.setCaptionText(text: text)
                self?.emailCaptionTextField.setState(success: false)
            }.store(in: &subscriptions)
    }
    
}

extension SetEmailViewController {
    @objc private func nextButtonTapped() {
        viewModel.getIsUsingEmail()
    }
    
    
}

extension SetEmailViewController {
    
    private func setupLayOuts() {
        [emailLabel, emailCaptionTextField, nextButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(63)
        }
        emailCaptionTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(79)
        }
        nextButton.snp.makeConstraints {
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
