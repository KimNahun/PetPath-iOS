//
//  SignupCertificationViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class SignupCertificationViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let certificationLabel = UILabel().then {
        $0.setTitleBold(text: "안전한 펫워킹을 위해\n본인인증을 진행해주세요!")
        $0.numberOfLines = 2
    }
    
    private let certificationButton = BottomPlacedButton().then {
        $0.setTitle("본인인증 하러가기", for: .normal)
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
        certificationButton.setupButtonStatus(isSelected: true)
        certificationButton.addTarget(self, action: #selector(certificationButtonTapped), for: .touchUpInside)
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
    }
}

extension SignupCertificationViewController {
    @objc private func certificationButtonTapped() {
        let certificationViewController = CertificationViewController(viewModel: CertificationViewModel())
        certificationViewController.modalPresentationStyle = .fullScreen
        certificationViewController.resultPublisher.sink { [weak self] response in
            guard let strongself = self else { return }
            self?.dismiss(animated: true)
            if response.success {
                self?.navigationController?.pushViewController(SetEmailViewController(viewModel: strongself.viewModel), animated: true)
            } else {
                if let reason = response.reason {
                    switch reason {
                    case .impUidRequired: ToastMessenger.shared.showToast(message: "imp_uid는 필수 입력")
                    case .CertInfoNotFound: ToastMessenger.shared.showToast(message: "인증결과가 존재하지 않습니다")
                    case .notAdult: let viewController = AgeRejectionViewController(viewModel: SignUpViewModel())
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    case .alreadyInUse: let viewController = ExistingUserViewController(viewModel: SignUpViewModel())
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                } else {
                    let viewController = CertificationFailureViewController()
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }.store(in: &subscriptions)
        
        present(certificationViewController, animated: true)
    }
}

extension SignupCertificationViewController {
    
    private func setupLayOuts() {
        [certificationLabel, certificationButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        certificationLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(86)
            $0.leading.equalTo(view.snp.leading).offset(16)
        }
        certificationButton.snp.makeConstraints {
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
