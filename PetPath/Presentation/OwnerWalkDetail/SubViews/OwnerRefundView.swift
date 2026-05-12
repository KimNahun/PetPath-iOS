//
//  OwnerRefundView.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class OwnerRefundView: UIView {

    let showMessageButtonPublisher = PassthroughSubject<String, Never>()
    private let viewModel: OwnerWalkDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var paymentView = OwnerPaymentView(viewModel: viewModel)
    
    private let contentView = UIView()
    
    private let refundAtGuideLabel = UILabel().then {
        $0.text = "환불 일시"
    }
    
    private let refundAtLabel = UILabel()
    
    private let messageGuideLabel = UILabel().then {
        $0.text = "환불 사유"
    }
    
    private let messageLabel = UILabel()
    
    private let penaltyGuideLabel = UILabel().then {
        $0.text = "페널티"
    }
    
    private let penaltyLabel = UILabel()
    
    private let separator1 = UIView()
    
    private let refundPriceGuideLabel = UILabel().then {
        $0.text = "환불 금액"
    }
    
    private let refundPriceLabel = UILabel()
    
    private let separator2 = UIView()
    
    private let showMessageButton = UIButton().then {
        $0.setTitle("(메시지 보기)", for: .normal)
        $0.setTitleColor(.neutral7, for: .normal)
        $0.titleLabel?.font = FontSet.pretendardMedium(size: 12)
        $0.isHidden = true
    }
    
    init(viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bind()
        showMessageButton.addTarget(self, action: #selector(showMessageButtonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.$walkPaymentInfo.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] item in
            guard let item = item else { return }
            let date = item.payAt.extractDateComponentsFromISO()
            self?.refundAtLabel.text = "\(date.year)-\(date.month)-\(date.day) \(date.hour):\(date.minute):\(date.second)"
            self?.penaltyLabel.text = "\(item.penalty?.formattedWithComma ?? "-")원"
            self?.refundPriceLabel.text = "\(item.refundPrice?.formattedWithComma ?? "-")원"
            if let message = item.message, !message.isEmpty {
                self?.showMessageButton.isHidden = false
            } else {
                self?.showMessageButton.isHidden = true
            }
        }.store(in: &subscriptions)
        
        viewModel.$walkDetailResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] item in
            self?.messageLabel.text = item?.status.koreanDetailDescription ?? ""
        }.store(in: &subscriptions)
    }
    @objc private func showMessageButtonTapped() {
        showMessageButtonPublisher.send(viewModel.walkPaymentInfo?.message ?? "")
    }
}

extension OwnerRefundView {
    private func setupLayouts() {
        [paymentView, contentView, separator2].forEach {
            self.addSubview($0)
        }
        [refundAtGuideLabel, refundAtLabel, messageGuideLabel, messageLabel, penaltyGuideLabel, penaltyLabel, separator1, refundPriceGuideLabel, refundPriceLabel, showMessageButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        paymentView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(paymentView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(112)
        }
        separator2.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(7)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(8)
            $0.horizontalEdges.equalToSuperview()
        }
        refundAtGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        refundAtLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        messageGuideLabel.snp.makeConstraints {
            $0.top.equalTo(refundAtGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(refundAtGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        showMessageButton.snp.makeConstraints {
            $0.centerY.equalTo(messageGuideLabel)
            $0.trailing.equalTo(messageLabel.snp.leading).offset(-4)
            $0.width.equalTo(67)
            $0.height.equalTo(14)
        }
        penaltyGuideLabel.snp.makeConstraints {
            $0.top.equalTo(messageGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        penaltyLabel.snp.makeConstraints {
            $0.top.equalTo(messageGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        separator1.snp.makeConstraints {
            $0.top.equalTo(penaltyGuideLabel.snp.bottom).offset(8)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        refundPriceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separator1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        refundPriceLabel.snp.makeConstraints {
            $0.top.equalTo(separator1.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
    }
    private func setupComponents() {
        [refundAtGuideLabel, messageGuideLabel, penaltyGuideLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [refundAtLabel].forEach {
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [messageLabel, penaltyLabel].forEach {
            $0.textColor = .error1
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [refundPriceGuideLabel, refundPriceLabel].forEach {
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardSemiBold(size: 12)
        }
        separator1.backgroundColor = .dark
        separator2.backgroundColor = .neutral3
        contentView.backgroundColor = .neutral3
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
