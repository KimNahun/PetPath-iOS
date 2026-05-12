//
//  CertificationAgreementViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class CertificationAgreementViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: CertificationAgreeementViewModel
    private let type: CertificationType
    
    enum CertificationType {
        case findId
        case findPassword
    }
    
    // MARK: - UI Components
    private let certificationLabel = UILabel().then {
        $0.setTitleBold(text: "본인인증을 통해서\n해당 명의로 가입된 계정을\n찾아볼게요")
        $0.numberOfLines = 3
    }
    private let personalInformationAgreementView = AgreementView(text: "개인정보 처리 방침(필수)").then { _ in }
    
    private let certificationButton = BottomPlacedButton().then {
        $0.setTitle("본인인증 하러가기", for: .normal)
    }
    
    init(type: CertificationType, viewModel: CertificationAgreeementViewModel) {
        self.type = type
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        switch type {
        case .findId: navigationItem.title = "계정 찾기"
        case .findPassword: navigationItem.title = "비밀번호 찾기"
        }
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
        certificationButton.addTarget(self, action: #selector(certificationButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        
        personalInformationAgreementView.agreementPublisher.sink { [weak self] isSelected in
            self?.certificationButton.setupButtonStatus(isSelected: isSelected)
        }.store(in: &subscriptions)
        
        viewModel.resultPublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            switch response.type {
            case .findId:
                if let data = response.data {
                    let viewController = FoundIdViewController(viewModel: FindIdViewModel(userId: data))
                    self?.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    let viewController = NotSignupViewController(viewModel: FindIdViewModel(userId: nil))
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            case .findPassword:
                if let data = response.data {
                    let viewController = ChangePasswordViewController(viewModel: FindPasswordViewModel(userId: data))
                    self?.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    let viewController = NotSignupViewController(viewModel: FindIdViewModel(userId: nil))
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            self?.dismiss(animated: true)
        }.store(in: &subscriptions)
    }
    
}

extension CertificationAgreementViewController {
    @objc private func certificationButtonTapped() {
        let certificationViewController = CertificationViewController(viewModel: CertificationViewModel())
        certificationViewController.modalPresentationStyle = .fullScreen
        certificationViewController.resultPublisher.sink { [weak self] result in
            guard let strongSelf = self else { return }
            self?.dismiss(animated: true)
            if result.success || result.reason != nil {
                strongSelf.viewModel.findUserId(type: strongSelf.type)
            } else {
                    let viewController = CertificationFailureViewController()
                    self?.navigationController?.pushViewController(viewController, animated: true)
                self?.dismiss(animated: true)
            }
        }.store(in: &subscriptions)
        
        present(certificationViewController, animated: true)
    }
    
    
}

extension CertificationAgreementViewController {
    
    private func setupLayOuts() {
        [certificationLabel, personalInformationAgreementView, certificationButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        certificationLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalTo(view.snp.leading).offset(16)
            $0.height.equalTo(97)
        }
        personalInformationAgreementView.snp.makeConstraints {
            $0.bottom.equalTo(certificationButton.snp.top).offset(-24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        certificationButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
