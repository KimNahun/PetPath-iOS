//
//  OwnerPaymentView.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class OwnerPaymentView: UIView {

    private let viewModel: OwnerWalkDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .neutral3
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "결제"
    }
    
    private let contentView = UIView()
    
    private let priceGuideLabel = UILabel().then {
        $0.text = "산책료"
    }
    
    private let priceLabel = UILabel()
    
    private let discountGuideLabel = UILabel().then {
        $0.text = "쿠폰/할인"
    }
    
    private let discountLabel = UILabel()
    
    private let payAtGuideLabel = UILabel().then {
        $0.text = "결제 일시"
    }
    
    private let payAtLabel = UILabel()
    
    private let separator1 = UIView()
    
    private let totalPriceGuideLabel = UILabel().then {
        $0.text = "최종 결제금액"
    }
    
    private let totalPriceLabel = UILabel()
    
    private let separator2 = UIView()
    
    init(viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // ???: 이거 할인료 퍼센트로도 오나? 아니면 숫자로만 오나 ?
    private func bind() {
        viewModel.$walkPaymentInfo.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] item in
            guard let item = item else { return }
            let date = item.payAt.extractDateComponentsFromISO()
            self?.priceLabel.text = "\(item.price.formattedWithComma)원"
            self?.discountLabel.text = "\(item.discount.formattedWithComma)원"
            self?.payAtLabel.text = "\(date.year)-\(date.month)-\(date.day) \(date.hour):\(date.minute):\(date.second)"
            self?.totalPriceLabel.text = "\(item.totalPrice.formattedWithComma)원"
            
            self?.separator2.isHidden = item.refundAt == nil
        }.store(in: &subscriptions)
    }

}

extension OwnerPaymentView {
    private func setupLayouts() {
        [separatorView, titleLabel, contentView].forEach {
            self.addSubview($0)
        }
        [priceGuideLabel, priceLabel, discountGuideLabel, discountLabel, payAtGuideLabel, payAtLabel, separator1, totalPriceGuideLabel, totalPriceLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(8)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(22)
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        priceGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        discountGuideLabel.snp.makeConstraints {
            $0.top.equalTo(priceGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        discountLabel.snp.makeConstraints {
            $0.top.equalTo(priceGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        payAtGuideLabel.snp.makeConstraints {
            $0.top.equalTo(discountGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        payAtLabel.snp.makeConstraints {
            $0.top.equalTo(discountGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        separator1.snp.makeConstraints {
            $0.top.equalTo(payAtLabel.snp.bottom).offset(8)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        totalPriceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separator1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        totalPriceLabel.snp.makeConstraints {
            $0.top.equalTo(separator1.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    private func setupComponents() {
        titleLabel.textColor = .neutral11
        titleLabel.font = FontSet.pretendardBold(size: 18)
        [priceGuideLabel, discountGuideLabel, payAtGuideLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [priceLabel, discountLabel, payAtLabel].forEach {
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        [totalPriceGuideLabel, totalPriceLabel].forEach {
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
