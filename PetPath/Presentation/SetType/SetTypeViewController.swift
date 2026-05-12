//
//  SetTypeViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Combine
import UIKit

final class SetTypeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SetTypeViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let ownerButton = UIButton().then {
        $0.setImage(UIImage(named: "owner"), for: .normal)
    }
    private let ownerLabel = UILabel().then {
        $0.text = "견주"
    }
    private let walkerButton = UIButton().then {
        $0.setImage(UIImage(named: "walker"), for: .normal)
    }
    private let walkerLabel = UILabel().then {
        $0.text = "워커"
    }
    private let selectButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("역할 설정하기", for: .normal)
    }
    init(viewModel: SetTypeViewModel) {
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
        ownerButton.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        walkerButton.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("역할 설정")
    }
    // MARK: - Bind
    
    private func bind() {
        viewModel.$accountType.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] accountType in
                let viewController: UIViewController
                if accountType == .owner { viewController = OwnerMainPageViewController(viewModel: MainPageViewModel()) }
                else { viewController = WalkerMainPageViewController(viewModel: MainPageViewModel()) }
                self?.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscriptions)
    }
}

extension SetTypeViewController {
    @objc private func selectButtonTapped() {
        if ownerButton.isSelected { viewModel.setAccountType(type: .owner) }
        else { viewModel.setAccountType(type: .walker) }
    }
    
    @objc private func typeButtonTapped(sender: UIButton) {
        switch sender {
        case ownerButton:
            ownerButton.isSelected = true
            walkerButton.isSelected = false
            ownerButton.backgroundColor = .dark.withAlphaComponent(0.4)
            walkerButton.backgroundColor = .clear
            ownerLabel.textColor = .neutral11
            walkerLabel.textColor = .neutral7
        case walkerButton:
            walkerButton.isSelected = true
            ownerButton.isSelected = false
            walkerButton.backgroundColor = .dark.withAlphaComponent(0.4)
            ownerButton.backgroundColor = .clear
            walkerLabel.textColor = .neutral11
            ownerLabel.textColor = .neutral7
        default: break
        }
    }
    
    
}

extension SetTypeViewController {
    
    private func setupLayOuts() {
        [ownerButton, ownerLabel, walkerButton, walkerLabel, selectButton].forEach {
            view.addSubview($0)
        }
    }
    private func setupConstraints() {
        ownerButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(26)
            $0.trailing.equalTo(view.snp.centerX).offset(-4)
            $0.height.equalTo(walkerButton.snp.width).multipliedBy(1.3333)
        }
        ownerLabel.snp.makeConstraints {
            $0.top.equalTo(ownerButton.snp.bottom).offset(8)
            $0.centerX.equalTo(ownerButton)
            $0.height.equalTo(21)
        }
        walkerButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.trailing.equalToSuperview().offset(-26)
            $0.height.equalTo(walkerButton.snp.width).multipliedBy(1.3333)
        }
        walkerLabel.snp.makeConstraints {
            $0.top.equalTo(walkerButton.snp.bottom).offset(8)
            $0.centerX.equalTo(walkerButton)
            $0.height.equalTo(21)
        }
        selectButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        [ownerButton, walkerButton].forEach {
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
          //  $0.layer.borderWidth = 2
        }
        [ownerLabel, walkerLabel].forEach {
            $0.textColor = .neutral7
            $0.font = FontSet.pretendardBold(size: 18)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
