//
//  PayoutHistoryViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Combine
import UIKit

final class PayoutHistoryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PayoutViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
  
    private let payoutCheckModalViewController = ActionCheckModalViewController(message: "수익금 정산을 신청하시겠어요?")
    
    private let containerView = UIView()
    private let possibleAmountLabel = UILabel().then {
        $0.text = "현재 정산 가능 금액"
    }
    private let amountLabel = UILabel()
    
    private let standardLabel = UILabel().then {
        $0.text = "정산 기준액: 30,000원"
    }
    private let percentLabel = UILabel()
    
    private let progressView = UIProgressView()
    
    private let payoutButton = BottomPlacedButton()
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("FFF8D6")
    }
    private let noticeLabel = UILabel().then {
        $0.text = """
정산 정책 안내\n\n누적 수익이 3만원 이상이 되면 정산 신청이 가능합니다.\n계좌 설정에 등록된 계좌로 입금되며 정산은 신청 후 5-7 영업일이 소요됩니다.
"""
    }
    private let historyLabel = UILabel().then {
        $0.text = "최근 정산 내역"
    }
    private lazy var payoutHistoryTableView = PayoutHistoryTableView(viewModel: viewModel)
    
    private let noHistoryLabel = UILabel().then {
        $0.text = "최근 정산 내역이 없습니다"
    }
    
    init(viewModel: PayoutViewModel) {
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
        payoutButton.addTarget(self, action: #selector(payoutButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAvailablePayoutAmount()
        viewModel.getPayoutHistory()
        setNavigationTitle("정산하기")
    }
    
    // MARK: - Bind
    
    private func bind() {
        payoutCheckModalViewController.processPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            viewModel.requestPayout()
        }.store(in: &subscriptions)
        
        viewModel.$payoutHistoryList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.noHistoryLabel.isHidden = !list.isEmpty
            }.store(in: &subscriptions)
        
        viewModel.successPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.viewModel.getAvailablePayoutAmount()
            self?.viewModel.getPayoutHistory()
        }.store(in: &subscriptions)
        
        viewModel.$payoutAmount.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] amount in
            guard let self = self, let amount = amount else { return }
            amountLabel.text = "\(amount.formattedWithComma)원"
            let percent = Float(amount) * 100 / 30000
            let flooredPercent = floor(percent * 10) / 10  
            percentLabel.text = "\(flooredPercent)%"
            progressView.progress = Float(amount) / 30000
            if amount >= 30000 {
                payoutButton.setTitle("정산하기", for: .normal)
                payoutButton.setupButtonStatus(isSelected: true)
            } else {
                payoutButton.setTitle("정산 가능액에 도달하지 않았습니다", for: .normal)
                payoutButton.setupButtonStatus(isSelected: false)
            }
        }.store(in: &subscriptions)
        
        payoutHistoryTableView.cellTapPublisher.sink { [weak self] pk in
            guard let self = self else { return }
            viewModel.selectedPk = pk
            let viewController = PayoutDetailViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension PayoutHistoryViewController {
    @objc private func payoutButtonTapped() {
        present(payoutCheckModalViewController, animated: true)
    }
}

extension PayoutHistoryViewController {
    
    private func setupLayOuts() {
        [containerView, historyLabel, payoutHistoryTableView, noHistoryLabel].forEach {
            view.addSubview($0)
        }
        [possibleAmountLabel, amountLabel, standardLabel, percentLabel, progressView, payoutButton, backgroundView].forEach {
            containerView.addSubview($0)
        }
        backgroundView.addSubview(noticeLabel)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        possibleAmountLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
        }
        amountLabel.snp.makeConstraints {
            $0.top.equalTo(possibleAmountLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(16)
        }
        standardLabel.snp.makeConstraints {
            $0.top.equalTo(amountLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(16)
        }
        percentLabel.snp.makeConstraints {
            $0.top.equalTo(amountLabel.snp.bottom).offset(24)
            $0.trailing.equalToSuperview().inset(16)
        }
        progressView.snp.makeConstraints {
            $0.top.equalTo(percentLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(10)
        }
        payoutButton.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.height.equalTo(33)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(payoutButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        noticeLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        historyLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        noHistoryLabel.snp.makeConstraints { 
            $0.top.equalTo(historyLabel.snp.bottom).offset(80)
            $0.centerX.equalToSuperview()
        }
        payoutHistoryTableView.snp.makeConstraints {
            $0.top.equalTo(historyLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupComponents() {
        possibleAmountLabel.textColor = .dark
        possibleAmountLabel.font = FontSet.pretendardBold(size: 16)
        amountLabel.textColor = .dark
        amountLabel.font = FontSet.pretendardBold(size: 24)
        [standardLabel, percentLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardRegular(size: 12)
        }
        noHistoryLabel.textColor = .neutral6
        noHistoryLabel.font = FontSet.pretendardSemiBold(size: 14)
        noticeLabel.textColor = ColorSet.fromHex("918130")
        noticeLabel.font = FontSet.pretendardMedium(size: 12)
        noticeLabel.numberOfLines = 0
        historyLabel.textColor = .dark
        historyLabel.font = FontSet.pretendardBold(size: 16)
        progressView.trackTintColor = .neutral6
        progressView.progressTintColor = .primary500
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.8
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

