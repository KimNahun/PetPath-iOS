//
//  SetSourceViewController.swift
//  PetPath
//
//  Created by 김나훈 on 8/1/25.
//

import Combine
import UIKit

final class SetSourceViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let messageLabel = UILabel().then {
        $0.text = "어떻게 펫패스를 알게 됐나요?"
        $0.textColor = .dark
        $0.font = FontSet.pretendardSemiBold(size: 22)
    }
    
    private lazy var sourceTypeCollectionView: SourceTypeCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = SourceTypeCollectionView(frame: .zero, collectionViewLayout: flowLayout, viewModel: viewModel)
        return collectionView
    }()
    
    private let signupButton = BottomPlacedButton().then {
        $0.setTitle("회원가입 완료", for: .normal)
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
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("회원가입")
    }
    private func bind() {
        viewModel.$isSourceValid.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isValid in
            self?.signupButton.setupButtonStatus(isSelected: isValid)
        }.store(in: &subscriptions)
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
        }.store(in: &subscriptions)
    }
    
}

extension SetSourceViewController {
    @objc private func signupButtonTapped() {
        viewModel.signUp()
    }
    
    
}

extension SetSourceViewController {
    
    private func setupLayOuts() {
        [scrollView, signupButton].forEach {
            view.addSubview($0)
        }
        [messageLabel, sourceTypeCollectionView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(signupButton.snp.top).offset(-10)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(78)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        sourceTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(500)
            $0.width.equalTo(view.snp.width)
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        signupButton.snp.makeConstraints { 
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
