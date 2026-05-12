//
//  SignInViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Combine
import SnapKit
import Then
import UIKit

final class SignInViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignInViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let logoImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "loginLogo")
    }
    private let appNameLabel = UILabel().then {
        $0.text = "펫패스"
        $0.font = FontSet.pretendardBold(size: 32)
        $0.textColor = ColorSet.neutral10
    }
    private let appDescriptionLabel = UILabel().then {
        $0.text = "Pets & People"
        $0.font = FontSet.pretendardBold(size: 20)
        $0.textColor = ColorSet.neutral7
    }
    private let idTextFieldView = BindableTextFieldView(title: "이메일").then {
        $0.setPlaceHolder(text: "이메일")
    }
    
    private let passwordTextFieldView = BindableTextFieldView(title: "비밀번호", mode: .secure).then {
        $0.setPlaceHolder(text: "비밀번호")
    }
    
    private let findIdButton = UIButton().then {
        $0.setTitle("계정 찾기", for: .normal)
    }
    private let separatorLabel1 = UILabel().then {
        $0.text = "|"
    }
    private let findpasswordButton = UIButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
    }
    private let separatorLabel2 = UILabel().then {
        $0.text = "|"
    }
    private let signupButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
    }
    private let signInButton = BottomPlacedButton().then {
        $0.setTitle("로그인하기", for: .normal)
    }
    private let errorMessageLabel = UILabel().then {
        $0.textColor = .dangerTertiary
        $0.font = FontSet.pretendardMedium(size: 14)
    }
    
    init(viewModel: SignInViewModel) {
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
        bind()
        hideKeyboardWhenTappedAround()
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        findpasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("")
        }
    // MARK: - Bind
    
    private func bind() {
        
        idTextFieldView.textPublisher
            .assign(to: \.id, on: viewModel)
            .store(in: &subscriptions)
        passwordTextFieldView.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &subscriptions)
        [idTextFieldView, passwordTextFieldView].forEach {
            $0.textPublisher.sink { [weak self] _ in
                self?.errorMessageLabel.isHidden = true
            }.store(in: &subscriptions)
        }
        
        viewModel.$issignInButtonEnabled
            .receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] isEnabled in
                self?.signInButton.setupButtonStatus(isSelected: isEnabled)
            }.store(in: &subscriptions)
        
        viewModel.$signInErrorResponse.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] message in
                self?.errorMessageLabel.text = message
                self?.errorMessageLabel.isHidden = message.isEmpty
            }.store(in: &subscriptions)
        
        viewModel.$userType.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] userType in
                let viewController: UIViewController
                switch userType {
                case .owner: viewController = OwnerMainPageViewController(viewModel: MainPageViewModel())
                case .walker: viewController = WalkerMainPageViewController(viewModel: MainPageViewModel())
                case .unknown, nil: viewController = SetTypeViewController(viewModel: SetTypeViewModel())
                }
                self?.navigationController?.setViewControllers([viewController], animated: true)
            }.store(in: &subscriptions)
    }
}

extension SignInViewController {
    @objc private func findIdButtonTapped() {
        let viewController = CertificationAgreementViewController(type: .findId, viewModel: CertificationAgreeementViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func findPasswordButtonTapped() {
        let viewController = CertificationAgreementViewController(type: .findPassword, viewModel: CertificationAgreeementViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func signupButtonTapped() {
        let viewController = AgreementViewController(viewModel: SignUpViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func signInButtonTapped() {
        viewModel.signIn()
    }
    
}

extension SignInViewController {
    
    private func setupLayOuts() {
        [logoImageView, appNameLabel, appDescriptionLabel, idTextFieldView, passwordTextFieldView, findIdButton, separatorLabel1, findpasswordButton, separatorLabel2, signupButton, signInButton, errorMessageLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(29)
            $0.leading.equalTo(view.snp.leading)
            $0.width.equalTo(165)
            $0.height.equalTo(113)
        }
        appNameLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(38)
        }
        appDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(appNameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(appNameLabel)
            $0.height.equalTo(24)
        }
        errorMessageLabel.snp.makeConstraints {
            $0.top.equalTo(appDescriptionLabel.snp.bottom).offset(40)
            $0.leading.equalTo(appNameLabel)
            $0.height.equalTo(17)
        }
        idTextFieldView.snp.makeConstraints {
            $0.top.equalTo(appDescriptionLabel.snp.bottom).offset(65)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        passwordTextFieldView.snp.makeConstraints {
            $0.top.equalTo(idTextFieldView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        findIdButton.snp.makeConstraints {
            $0.centerY.equalTo(findpasswordButton)
            $0.trailing.equalTo(separatorLabel1.snp.leading).offset(-10)
            $0.width.equalTo(55)
            $0.height.equalTo(14)
        }
        separatorLabel1.snp.makeConstraints {
            $0.centerY.equalTo(findpasswordButton)
            $0.trailing.equalTo(findpasswordButton.snp.leading).offset(-10)
        }
        findpasswordButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextFieldView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(66)
            $0.height.equalTo(14)
        }
        separatorLabel2.snp.makeConstraints {
            $0.centerY.equalTo(findpasswordButton)
            $0.leading.equalTo(findpasswordButton.snp.trailing).offset(10)
        }
        signupButton.snp.makeConstraints {
            $0.centerY.equalTo(findpasswordButton)
            $0.leading.equalTo(separatorLabel2.snp.trailing).offset(10)
            $0.width.equalTo(42)
            $0.height.equalTo(14)
        }
        signInButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        [findIdButton, findpasswordButton, signupButton].forEach {
            $0.titleLabel?.font = FontSet.pretendardRegular(size: 12)
            $0.setTitleColor(ColorSet.neutral6, for: .normal)
        }
        [separatorLabel1, separatorLabel2].forEach {
            $0.font = FontSet.pretendardRegular(size: 12)
            $0.textColor = ColorSet.neutral6
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
