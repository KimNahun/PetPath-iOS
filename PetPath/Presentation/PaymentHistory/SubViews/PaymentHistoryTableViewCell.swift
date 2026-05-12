//
//  PaymentHistoryTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Combine
import UIKit

final class PaymentHistoryTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    
    private let cardNumberLabel = UILabel()
    
    private let priceLabel = UILabel()
    
    private let chevronImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    private let pidLabel = UILabel()
    
    private let separator = UIView().then {
        $0.backgroundColor = .neutral7
    }
    
    private let statusLabel = UILabel()
    
    private let clockImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "clock")
    }
    
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(item: PaymentHistoryData) {
        cardNumberLabel.text = item.payMethod
        priceLabel.text = "\(item.amount.formattedWithComma)원"
        pidLabel.text = item.pid
        
        statusLabel.textColor = item.success ? .secondary400 : .error1
        statusLabel.text = "\(item.type.koreanDescription) \(item.success ? "성공" : "실패")"
        let date = item.createAt.extractDateComponentsFromISO()
        timeLabel.text = "\(date.year)-\(date.month)-\(date.day) \(date.hour):\(date.minute):\(date.second)"
    
    }
    
}

extension PaymentHistoryTableViewCell {
   
}

extension PaymentHistoryTableViewCell {
    private func setupLayouts() {
        contentView.addSubview(containerView)
        [cardNumberLabel, priceLabel, chevronImageView, pidLabel, separator, statusLabel, clockImageView, timeLabel].forEach {
            containerView.addSubview($0)
        }
    }
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(83)
        }
        cardNumberLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8)
            $0.height.equalTo(17)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(17)
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }
        chevronImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.size.equalTo(16)
            $0.trailing.equalToSuperview().offset(-8)
        }
        pidLabel.snp.makeConstraints {
            $0.top.equalTo(cardNumberLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(12)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(pidLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(1)
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(14)
        }
        clockImageView.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(8)
            $0.size.equalTo(12)
            $0.trailing.equalTo(timeLabel.snp.leading).offset(-4)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(14)
        }
    }
    private func setupComponents() {
        cardNumberLabel.textColor = .dark
        cardNumberLabel.font = FontSet.pretendardSemiBold(size: 14)
        priceLabel.textColor = .dark
        priceLabel.font = FontSet.pretendardSemiBold(size: 14)
        pidLabel.textColor = .neutral7
        pidLabel.font = FontSet.pretendardSemiBold(size: 10)
        timeLabel.textColor = .neutral9
        timeLabel.font = FontSet.pretendardMedium(size: 12)
        statusLabel.font = FontSet.pretendardSemiBold(size: 12)
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = false

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 2
        contentView.backgroundColor = .systemBackground
    }
}
