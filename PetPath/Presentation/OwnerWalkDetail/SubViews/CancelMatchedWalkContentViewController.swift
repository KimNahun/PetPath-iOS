//
//  CancelMatchedWalkContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class CancelMatchedWalkContentViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: OwnerWalkDetailViewModel
    
    private let messageLabel = UILabel().then {
        $0.text = "산책 취소"
    }
    private let subMessageLabel = UILabel().then {
        $0.text = "산책을 취소하시겠습니까?\n취소시 수수료가 발생할 수 있습니다."
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let containerView = UIView()
    
    private let amountGuideLabel = UILabel().then {
        $0.text = "결제 금액"
    }
    
    private let amountLabel = UILabel()
    
    private let timeGuideLabel = UILabel().then {
        $0.text = "산책 예정 시각"
    }
    
    private let timeLabel = UILabel()
    
    private let penaltyGuideLabel = UILabel().then {
        $0.text = "취소 페널티"
    }
    
    private let penaltyLabel = UILabel()
    
    private let separator = UIView()
    
    private let refundGuideLabel = UILabel().then {
        $0.text = "환불 금액"
    }
    
    private let refundLabel = UILabel()
    
    private let reasonLabel = UILabel().then {
        $0.text = "워커에게 정중한 사과와 함께 매칭 취소 사유를 알려주세요"
    }
    
    private let textField = CustomTextField(placeholder: "매칭 취소 사유")
    
    private let cancelWalkButton = DangerButton(isSelected: false).then {
        $0.setTitle("매칭 취소하기", for: .normal)
    }
    
    init(viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelWalkButton.addTarget(self, action: #selector(cancelWalkButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        viewModel.$walkPaymentInfo.receive(on: DispatchQueue.main).sink { [weak self] item in
            guard let self = self, let item = item else { return }
            amountLabel.text = "\(item.totalPrice.formattedWithComma)원"
            if let penalty = viewModel.penaltyResponse {
                let price = max(0, item.totalPrice - penalty.penalty)
                refundLabel.text = "\(price.formattedWithComma)원"
            }
        }.store(in: &subscriptions)
        viewModel.$walkDetailResponse.receive(on: DispatchQueue.main).sink { [weak self] item in
            guard let self = self, let item = item else { return }
            let date = item.startAt.extractDateComponentsFromISO()
            timeLabel.text = "\(date.year)-\(date.month)-\(date.day) \(date.hour):\(date.minute)"
        }.store(in: &subscriptions)
        viewModel.$penaltyResponse.receive(on: DispatchQueue.main).sink { [weak self] item in
            guard let self = self, let item = item else { return }
            penaltyLabel.text = "\(item.penalty.formattedWithComma)원"
            if let payment = viewModel.walkPaymentInfo {
                let price = max(0, payment.totalPrice - item.penalty)
                refundLabel.text = "\(price.formattedWithComma)원"
            }
        }.store(in: &subscriptions)
        textField.textPublisher.sink { [weak self] text in
            self?.viewModel.cancelWalkRequest.reason = text
            self?.cancelWalkButton.setupButtonStatus(isSelected: !text.isEmpty)
        }.store(in: &subscriptions)
    }
}
extension CancelMatchedWalkContentViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func cancelWalkButtonTapped() {
        viewModel.cancelWalk()
        dismiss(animated: true)
    }
    
}

extension CancelMatchedWalkContentViewController {
    private func setupLayOuts() {
        [messageLabel, subMessageLabel, containerView, reasonLabel, textField, cancelButton, cancelWalkButton].forEach {
            view.addSubview($0)
        }
        [amountGuideLabel, amountLabel, timeGuideLabel, timeLabel, penaltyGuideLabel, penaltyLabel, separator, refundGuideLabel, refundLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(messageLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        reasonLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(16)
        }
        textField.snp.makeConstraints {
            $0.top.equalTo(reasonLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(34)
        }
        cancelWalkButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        amountGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        amountLabel.snp.makeConstraints {
            $0.centerY.equalTo(amountGuideLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
        timeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(amountGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(amountGuideLabel)
        }
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeGuideLabel)
            $0.trailing.equalTo(amountLabel)
        }
        penaltyGuideLabel.snp.makeConstraints {
            $0.top.equalTo(timeGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(amountGuideLabel)
        }
        penaltyLabel.snp.makeConstraints {
            $0.centerY.equalTo(penaltyGuideLabel)
            $0.trailing.equalTo(amountLabel)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(penaltyLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        refundGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(8)
            $0.leading.equalTo(amountGuideLabel)
        }
        refundLabel.snp.makeConstraints {
            $0.centerY.equalTo(refundGuideLabel)
            $0.trailing.equalTo(amountLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 20)
        subMessageLabel.textColor = .neutral11
        subMessageLabel.font = FontSet.pretendardMedium(size: 14)
        [amountGuideLabel, amountLabel, timeGuideLabel, timeLabel, penaltyGuideLabel, penaltyLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [refundGuideLabel, refundLabel].forEach {
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardSemiBold(size: 12)
        }
        separator.backgroundColor = .dark
        penaltyLabel.textColor = .error1
        reasonLabel.textColor = .dark
        reasonLabel.font = FontSet.pretendardMedium(size: 12)
        containerView.backgroundColor = .neutral3
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
