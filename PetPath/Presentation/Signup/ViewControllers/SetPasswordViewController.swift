//
//  SetPasswordViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class SetPasswordViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let passwordLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.setTitleBold(text: "비밀번호를\n설정해주세요")
    }
    
    private let mainPasswordTextFieldView = BindableTextFieldView(title: "비밀번호 설정", mode: .secure).then {
        $0.setPlaceHolder(text: "비밀번호 설정")
    }
    
    private let letterConditionCheckView = ConditionCheckView(text: "영문 대/소문자, 숫자, 특수문자 중 2개 이상 포함").then { _ in}
    
    private let passwordConditionLabel = UILabel().then {
        $0.font = FontSet.pretendardRegular(size: 10)
        $0.textColor = .gray500
        $0.text = "특수문자는 !@#$%^&*?만 가능"
    }
    
    private let countConditionCheckView = ConditionCheckView(text: "8자리 이상").then { _ in }
    
    private let repeatPasswordCheckTextFieldView = BindableCaptionTextField(title: "비밀번호 확인", mode: .secure).then {
        $0.setPlaceHolder(text: "비밀번호 확인")
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
        hideKeyboardWhenTappedAround()
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
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
        mainPasswordTextFieldView.textPublisher.assign(to: \.mainPassword, on: viewModel)
            .store(in: &subscriptions)
        repeatPasswordCheckTextFieldView.textPublisher.assign(to: \.repeatPassword, on: viewModel)
            .store(in: &subscriptions)
        viewModel.$passwordLetterSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] state in
                self?.letterConditionCheckView.setState(state: state)
            }.store(in: &subscriptions)
        viewModel.$passwordCountSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] state in
                self?.countConditionCheckView.setState(state: state)
            }.store(in: &subscriptions)
        viewModel.$passwordMatchSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] success in
                switch success {
                case .common:
                    self?.repeatPasswordCheckTextFieldView.setState(state: .normal)
                case .success:
                    self?.repeatPasswordCheckTextFieldView.setState(state: .success)
                    self?.repeatPasswordCheckTextFieldView.setCaptionText(text: "비밀번호가 일치합니다.")
                case .fail:
                    self?.repeatPasswordCheckTextFieldView.setState(state: .error)
                    self?.repeatPasswordCheckTextFieldView.setCaptionText(text: "비밀번호가 일치하지 않습니다.")
                }
            }.store(in: &subscriptions)
        viewModel.$isSignUpEnabled
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] isEnabled in
                self?.nextButton.setupButtonStatus(isSelected: isEnabled)
            }
            .store(in: &subscriptions)
        viewModel.$signUpSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] isEnabled in
                let viewController = WelcomeViewController()
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .store(in: &subscriptions)

    }
    
}

extension SetPasswordViewController {
    @objc private func nextButtonTapped() {
        navigationController?.pushViewController(SetSourceViewController(viewModel: viewModel), animated: true)
    }
    
    
}

extension SetPasswordViewController {
    
    private func setupLayOuts() {
        [passwordLabel, mainPasswordTextFieldView, letterConditionCheckView, passwordConditionLabel, countConditionCheckView, repeatPasswordCheckTextFieldView, nextButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(63)
        }
        mainPasswordTextFieldView.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        letterConditionCheckView.snp.makeConstraints {
            $0.top.equalTo(mainPasswordTextFieldView.snp.bottom).offset(8)
            $0.leading.equalTo(mainPasswordTextFieldView)
            $0.height.equalTo(14)
            $0.width.equalTo(267)
        }
        passwordConditionLabel.snp.makeConstraints {
            $0.top.equalTo(letterConditionCheckView.snp.bottom).offset(4)
            $0.leading.equalTo(mainPasswordTextFieldView).offset(20)
            $0.height.equalTo(12)
        }
        countConditionCheckView.snp.makeConstraints {
            $0.top.equalTo(passwordConditionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(mainPasswordTextFieldView)
            $0.height.equalTo(14)
            $0.width.equalTo(267)
        }
        repeatPasswordCheckTextFieldView.snp.makeConstraints {
            $0.top.equalTo(countConditionCheckView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
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
