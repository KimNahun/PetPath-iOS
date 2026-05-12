//
//  ShowPayoutContractViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/3/25.
//

import Combine
import UIKit

final class ShowPayoutContractViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PayoutContractViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private lazy var payoutContractTableView = PayoutContractTableView(viewModel: viewModel)
    
    private let modifyButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("정보 수정", for: .normal)
    }
    
    init(viewModel: PayoutContractViewModel) {
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
        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("입금 계좌 정보")
        viewModel.getPayoutContract()
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension ShowPayoutContractViewController {
    @objc private func modifyButtonTapped() {
        let viewController = ModifyPayoutContractViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ShowPayoutContractViewController {
    
    private func setupLayOuts() {
        [payoutContractTableView, modifyButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        payoutContractTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(modifyButton.snp.top)
        }
        modifyButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

