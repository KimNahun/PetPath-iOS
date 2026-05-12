//
//  WalkerPayoutView.swift
//  PetPath
//
//  Created by 김나훈 on 4/30/25.
//

import Combine
import UIKit

final class WalkerPayoutView: UIView {

    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: WalkerWalkDetailViewModel
    let showMessageButtonPublisher = PassthroughSubject<String, Never>()
    
    private let messageLabel = UILabel().then {
        $0.text = "정산"
        $0.textColor = .neutral11
        $0.font = FontSet.pretendardBold(size: 18)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .neutral3
        $0.layer.cornerRadius = 8
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.isHidden = true
    }

    private let separator = UIView()
    private let totalPriceGuideLabel = UILabel()
    private let totalPriceLabel = UILabel()

    // 라벨 정의
    private let priceGuideLabel = UILabel()
    private let priceLabel = UILabel()

    private let feeGuideLabel = UILabel()
    private let feeLabel = UILabel()

    private let cancelAtGuideLabel = UILabel()
    private let cancelAtLabel = UILabel()

    private let cancelReasonGuideLabel = UILabel()
    private let cancelReasonLabel = UILabel()

    private let penaltyGuideLabel = UILabel()
    private let penaltyLabel = UILabel()

    private let rewardGuideLabel = UILabel()
    private let rewardLabel = UILabel()

    private var rowStacks: [String: UIStackView] = [:]
    
    private let showMessageButton = UIButton(type: .system).then {
        $0.setTitle("(메시지 보기)", for: .normal)
        $0.setTitleColor(.neutral7, for: .normal)
        $0.titleLabel?.font = FontSet.pretendardMedium(size: 12)
        $0.isHidden = true
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .neutral3
    }
    init(viewModel: WalkerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        bind()
        showMessageButton.addTarget(self, action: #selector(showMessageButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func showMessageButtonTapped() {
        showMessageButtonPublisher.send(viewModel.payoutInfoResponse?.cancelMessage ?? "")
    }
    private func bind() {
        viewModel.$payoutInfoResponse.receive(on: DispatchQueue.main).sink { [weak self] data in
            guard let self = self, let data = data else { return }
            stackView.isHidden = false 
            self.priceLabel.text = "\(data.price.formattedWithComma)원"
            if let date = data.cancelAt?.extractDateComponentsFromISO() {
                self.cancelAtLabel.text = "\(date.year)-\(date.month)-\(date.day) \(date.hour):\(date.minute):\(date.second)"
            }
            self.cancelReasonLabel.text = viewModel.walkDetailResponse?.status.koreanDetailDescription ?? ""
            self.feeLabel.text = data.fee.map { "\($0.formattedWithComma)원" }
            self.totalPriceLabel.text = "\(data.totalPrice.formattedWithComma)원"

            // 페널티/보상 둘 중 하나만 보여주기
            if let penalty = data.penalty {
                self.penaltyLabel.text = "\(penalty.formattedWithComma)원"
                self.penaltyLabel.textColor = .error1
                self.rowStacks["페널티"]?.isHidden = false
                self.rowStacks["보상"]?.isHidden = true
            } else if let reward = data.rewardPrice {
                self.rewardLabel.text = "\(reward.formattedWithComma)원"
                self.rewardLabel.textColor = .secondary600
                self.rowStacks["페널티"]?.isHidden = true
                self.rowStacks["보상"]?.isHidden = false
            } else {
                self.rowStacks["페널티"]?.isHidden = true
                self.rowStacks["보상"]?.isHidden = true
            }

            let visibleKeys: [String]
            switch self.viewModel.walkDetailResponse?.status {
            case .tobeWalk, .walking, .endWalking:
                visibleKeys = ["산책료", "서비스 이용료"]
            case .ownerCancel, .ownerNoShow, .walkerCancel, .walkerNoShow:
                visibleKeys = ["산책료", "취소 일시", "취소 사유"]
                // 보상 or 페널티는 위에서 개별적으로 처리하므로 제외
            default:
                visibleKeys = []
            }

            for (key, stack) in self.rowStacks {
                if key == "페널티" || key == "보상" {
                    // 이미 위에서 처리
                    continue
                }
                stack.isHidden = !visibleKeys.contains(key)
            }
            if let message = data.cancelMessage, !message.isEmpty {
                showMessageButton.isHidden = false
            } else {
                showMessageButton.isHidden = true
            }
        }.store(in: &subscriptions)
    }
}

extension WalkerPayoutView {
    private func setupUI() {
        addSubview(messageLabel)
        addSubview(containerView)
        addSubview(separatorView)
        containerView.addSubview(stackView)
        containerView.addSubview(separator)
        containerView.addSubview(totalPriceGuideLabel)
        containerView.addSubview(totalPriceLabel)
        containerView.addSubview(showMessageButton)
        separator.backgroundColor = .dark

        totalPriceGuideLabel.text = "최종 정산금액"
        totalPriceGuideLabel.font = FontSet.pretendardSemiBold(size: 12)
        totalPriceLabel.font = FontSet.pretendardSemiBold(size: 12)
        totalPriceLabel.textColor = .dark

        let entries: [(String, UILabel, UILabel)] = [
            ("산책료", priceGuideLabel, priceLabel),
            ("서비스 이용료", feeGuideLabel, feeLabel),
            ("취소 일시", cancelAtGuideLabel, cancelAtLabel),
            ("취소 사유", cancelReasonGuideLabel, cancelReasonLabel),
            ("페널티", penaltyGuideLabel, penaltyLabel),
            ("보상", rewardGuideLabel, rewardLabel)
        ]

        for (title, guide, value) in entries {
            guide.text = title
            guide.font = FontSet.pretendardMedium(size: 12)
            guide.textColor = .neutral11

            value.font = FontSet.pretendardMedium(size: 12)
            value.textColor = .neutral11

            let rowStack = UIStackView(arrangedSubviews: [guide, value])
            rowStack.axis = .horizontal
            rowStack.distribution = .equalSpacing
            rowStack.alignment = .fill
            stackView.addArrangedSubview(rowStack)

            rowStacks[title] = rowStack
        }
        cancelReasonLabel.textColor = .error1
    }

    private func setupConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(8)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        totalPriceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        totalPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalPriceGuideLabel)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
        showMessageButton.snp.makeConstraints {
            $0.centerY.equalTo(cancelReasonLabel)
            $0.trailing.equalTo(cancelReasonLabel.snp.leading).offset(-4)
            $0.width.equalTo(67)
            $0.height.equalTo(14)
        }
    }
}
