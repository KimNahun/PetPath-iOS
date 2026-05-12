//
//  PaymentHistoryViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Combine
import UIKit

final class PaymentHistoryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PaymentHistoryViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private let messageLabel = UILabel().then {
        $0.text = "최근 결제 내역"
        $0.isHidden = true
    }
    private let emptyView = UIView().then {
        $0.backgroundColor = .systemBackground
    }
    private lazy var paymentHistoryTableView = PaymentHistoryTableView(viewModel: viewModel)
  
    
    private let noHistoryLabel = UILabel().then {
        $0.text = "표시할 결제 내역이 없어요."
        $0.isHidden = true
    }
    // MARK: - UI Components
  
    init(viewModel: PaymentHistoryViewModel) {
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
        viewModel.getPaymentHistoryList(isReset: true)
        viewModel.getUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("결제내역")
    }
    
    // MARK: - Bind
    
    private func bind() {
        paymentHistoryTableView.cellTapPublisher.sink { [weak self] walkId in
            guard let self = self else { return }
            let viewController: UIViewController
            switch viewModel.userType {
            case .owner: viewController = OwnerWalkDetailViewController(viewModel: OwnerWalkDetailViewModel(id: walkId))
            case .walker: viewController = WalkerWalkDetailViewController(viewModel: WalkerWalkDetailViewModel(id: walkId))
            case .unknown: return
            }
            navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$paymentHistoryList.receive(on: DispatchQueue.main).sink { [weak self] list in
            self?.noHistoryLabel.isHidden = !list.isEmpty
            self?.messageLabel.isHidden = list.isEmpty
        }.store(in: &subscriptions)
    }
}

extension PaymentHistoryViewController {
   
}

extension PaymentHistoryViewController {
    
    private func setupLayOuts() {
        [paymentHistoryTableView, emptyView, messageLabel, noHistoryLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        emptyView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        noHistoryLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        paymentHistoryTableView.snp.makeConstraints {
            $0.top.equalTo(emptyView.snp.bottom).offset(2)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 16)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
