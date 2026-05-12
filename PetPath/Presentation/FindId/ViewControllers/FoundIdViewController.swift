//
//  FoundIdViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

final class FoundIdViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindIdViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let foundIdLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    private let findPasswordButton = CommonButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
    }
    
    private let backSignInButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("로그인으로 돌아가기", for: .normal)
    }
    
    init(viewModel: FindIdViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        if let item = viewModel.userId {
            foundIdLabel.setTitleBold(text: "\(item.name)님은\n\(item.email)\n으로 가입되었습니다")
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
        setNavigationRightButtons(keys: ["cancel"])
        bind()
        findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        backSignInButton.addTarget(self, action: #selector(backSignInButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("계정 찾기")
    }
    
}

extension FoundIdViewController {
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
    }
    @objc private func findPasswordButtonTapped() {
        guard let userId = viewModel.userId else { return }
        let viewController = ChangePasswordViewController(viewModel: FindPasswordViewModel(userId: userId))
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func backSignInButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: SignInViewController.self, createNew: {
               SignInViewController(viewModel: SignInViewModel())
           })
    }
}

extension FoundIdViewController {
    
    private func setupLayOuts() {
        [foundIdLabel, findPasswordButton, backSignInButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        foundIdLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(97)
        }
        findPasswordButton.snp.makeConstraints {
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
