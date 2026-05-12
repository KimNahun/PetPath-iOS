//
//  CouponListTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class CouponListTableViewCell: UITableViewCell {
    
    private let priceLabel = UILabel()
    
    private let guideLabel = UILabel().then {
        $0.text = "COUPON"
    }
    
    private let separator = UIView()
    
    private let welcomeLabel = UILabel().then {
        $0.text = "펫패스에 오신걸 환영합니다."
    }
    
    private let subImageView = AspectFitImageView().then {
        $0.isHidden = true
    }
    
    private let minimumPriceLabel = UILabel()
    
    private let expireLabel = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // 👇 셀 전체 contentView 안쪽 여백 추가
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
    
    func configure(item: GetCouponListDTO, type: CouponType) {
        
        if item.type == .rate {
            priceLabel.text = "\(item.amount)%"
        } else if item.type == .sub {
            priceLabel.text = "\(item.amount.formattedWithComma)원"
        }
        minimumPriceLabel.text = "최소 산책 금액: \(item.activeMinPrice.formattedWithComma)원"
        let expireDate = item.expireAt.extractDateComponentsFromISO()
        let expireText: String = item.useAt == nil ? "사용기간" : "사용일자"
        let expireDot: String = item.useAt == nil ? "까지" : ""
        expireLabel.text = "\(expireText): \(expireDate.year)년 \(expireDate.month)월 \(expireDate.day)일\(expireDot)"
        if type == .active {
            subImageView.isHidden = true
            self.contentView.backgroundColor = .neutral4
            self.contentView.alpha = 1.0
        } else {
            subImageView.isHidden = false
            if item.useAt == nil {
                subImageView.image = UIImage(named: "expired")
            } else {
                subImageView.image = UIImage(named: "used")
            }
            self.contentView.backgroundColor = .neutral3
            self.contentView.alpha = 0.4
        }
    }
    
}

extension CouponListTableViewCell {
   
}

extension CouponListTableViewCell {
    private func setupLayouts() {
        [priceLabel, guideLabel, separator, welcomeLabel, minimumPriceLabel, expireLabel, subImageView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        priceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(13)
            $0.height.equalTo(29)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(17)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(7)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(15)
            $0.leading.equalTo(priceLabel)
            $0.height.equalTo(14)
        }
        minimumPriceLabel.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(priceLabel)
            $0.height.equalTo(12)
        }
        expireLabel.snp.makeConstraints {
            $0.top.equalTo(minimumPriceLabel.snp.bottom).offset(4)
            $0.leading.equalTo(priceLabel)
            $0.height.equalTo(12)
        }
        subImageView.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(20.28)
            $0.trailing.equalToSuperview().offset(-28.12)
            $0.width.equalTo(72.26)
            $0.height.equalTo(47.08)
        }
        
    }
    private func setupComponents() {
        priceLabel.textColor = .primary10
        priceLabel.font = FontSet.pretendardBold(size: 24)
        guideLabel.textColor = .primary10
        guideLabel.font = FontSet.pretendardMedium(size: 14)
        separator.backgroundColor = .neutral5
        welcomeLabel.textColor = .dark
        welcomeLabel.font = FontSet.pretendardSemiBold(size: 12)
        [minimumPriceLabel, expireLabel].forEach {
            $0.textColor = .neutral7
            $0.font = FontSet.pretendardSemiBold(size: 10)
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
