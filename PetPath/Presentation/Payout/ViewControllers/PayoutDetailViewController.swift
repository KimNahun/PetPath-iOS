//
//  PayoutDetailViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class PayoutDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PayoutViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let backgroundView = UIView().then {
        $0.backgroundColor = .neutral4
    }
    
    private let dateLabel = UILabel()
    
    private let priceLabel = UILabel()
    
    private let containerView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("FFFCEE")
    }
    
    private let totalPriceGuideLabel = UILabel().then {
        $0.text = "총액"
    }
    
    private let totalPriceLabel = UILabel()
    
    private let feeGuideLabel = UILabel().then {
        $0.text = "서비스 이용료"
    }
    
    private let feeLabel = UILabel()
    
    private let taxGuideLabel = UILabel().then {
        $0.text = "소득세 (3.3%)"
    }
    
    private let taxLabel = UILabel()
    
    private let createDateGuideLabel = UILabel().then {
        $0.text = "요청일"
    }
    
    private let createDateLabel = UILabel()
    
    private let executeDateGuideLabel = UILabel().then {
        $0.text = "지급일"
    }
    
    private let executeDateLabel = UILabel()
    
    private let bankGuideLabel = UILabel().then {
        $0.text = "지급 계좌"
    }
    
    private let bankLabel = UILabel()
    
    private let statusGuideLabel = UILabel().then {
        $0.text = "상태"
    }
    
    private let statusLabel = UILabel()
    
    private let failGuideLabel = UILabel().then {
        $0.text = "실패 사유 "
        $0.isHidden = true
    }
    
    private let failLabel = UILabel().then {
        $0.isHidden = true
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
        viewModel.getPayoutDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("정산상세")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$payoutDetail.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] data in
            guard let self = self, let data = data else { return }
            let createDate = data.createAt.extractDateComponentsFromISO()
            if let executeAt = data.executeAt {
                let executeDate = executeAt.extractDateComponentsFromISO()
                executeDateLabel.text = "\(executeDate.year)-\(executeDate.month)-\(executeDate.day)"
            } else {
                executeDateLabel.text = "정산 대기중"
            }
            dateLabel.text = "\(createDate.year).\(createDate.month).\(createDate.day) 정산상세"
            priceLabel.text = "\(data.total.formattedWithComma)원"
            totalPriceLabel.text = data.amount.formattedWithComma
            feeLabel.text = "-\(data.fee.formattedWithComma)"
            taxLabel.text = "-\(data.tax.formattedWithComma)"
            createDateLabel.text = "\(createDate.year)-\(createDate.month)-\(createDate.day)"
            bankLabel.text = "\(data.bank) \(data.accountNum.prefix(6))"
            switch data.status {
            case .fail: statusLabel.textColor = .error1
            case .pending, .success, .unknown: statusLabel.textColor = ColorSet.fromHex("918130")
            }
            statusLabel.text = data.status.koreanDescription
            if let failMessage = data.failMessage {
                failLabel.isHidden = false
                failGuideLabel.isHidden = false
                failLabel.text = failMessage
            } 
        }.store(in: &subscriptions)
    }
}

extension PayoutDetailViewController {
   
}

extension PayoutDetailViewController {
    
    private func setupLayOuts() {
        [backgroundView].forEach {
            view.addSubview($0)
        }
        [dateLabel, priceLabel, containerView, createDateGuideLabel, createDateLabel, executeDateGuideLabel, executeDateLabel, bankGuideLabel, bankLabel, statusGuideLabel, statusLabel, failGuideLabel, failLabel].forEach {
            backgroundView.addSubview($0)
        }
        [totalPriceGuideLabel, totalPriceLabel, feeGuideLabel, feeLabel, taxGuideLabel, taxLabel].forEach {
            containerView.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview()
        }
        dateLabel.snp.makeConstraints {
            $0.top.leading.equalTo(backgroundView).offset(16)
            $0.height.equalTo(17)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(24)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        createDateGuideLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        createDateLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
        }
        executeDateGuideLabel.snp.makeConstraints {
            $0.top.equalTo(createDateGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        executeDateLabel.snp.makeConstraints {
            $0.top.equalTo(createDateGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
        }
        bankGuideLabel.snp.makeConstraints {
            $0.top.equalTo(executeDateGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        bankLabel.snp.makeConstraints {
            $0.top.equalTo(executeDateGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
        }
        statusGuideLabel.snp.makeConstraints {
            $0.top.equalTo(bankGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        statusLabel.snp.makeConstraints {
            $0.centerY.equalTo(statusGuideLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
        failGuideLabel.snp.makeConstraints {
            $0.top.equalTo(statusGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        failLabel.snp.makeConstraints {
            $0.top.equalTo(statusGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-10)
        }
        totalPriceGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        totalPriceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        feeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(totalPriceGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        feeLabel.snp.makeConstraints {
            $0.top.equalTo(totalPriceGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        taxGuideLabel.snp.makeConstraints {
            $0.top.equalTo(feeGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        taxLabel.snp.makeConstraints {
            $0.top.equalTo(feeGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    private func setupComponents() {
        dateLabel.textColor = .neutral9
        dateLabel.font = FontSet.pretendardBold(size: 14)
        priceLabel.textColor = .dark
        priceLabel.font = FontSet.pretendardBold(size: 20)
        [totalPriceGuideLabel, totalPriceLabel, feeGuideLabel, feeLabel, taxGuideLabel, taxLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [createDateGuideLabel, createDateLabel, executeDateGuideLabel, executeDateLabel, bankGuideLabel, bankLabel, statusGuideLabel, failGuideLabel, failLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        statusLabel.font = FontSet.pretendardSemiBold(size: 14)
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 5
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
