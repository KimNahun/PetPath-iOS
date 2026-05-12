//
//  PayoutHistoryTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class PayoutHistoryTableViewCell: UITableViewCell {
    
    private let dateLabel = UILabel()
    
    private let priceLabel = UILabel()
    
    private let statusLabel = UILabel()
    
    private let chevronImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(item: GetPayoutHistoryDTO) {
        let date = item.createAt.extractDateComponentsFromISO()
        dateLabel.text = "\(date.year).\(date.month).\(date.day)"
        priceLabel.text = "\(item.total.formattedWithComma)원"
        statusLabel.text = item.status.koreanDescription
    }
    
}

extension PayoutHistoryTableViewCell {
   
}

extension PayoutHistoryTableViewCell {
    private func setupLayouts() {
        [dateLabel, priceLabel, statusLabel, chevronImageView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        statusLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-4)
            $0.centerY.equalTo(priceLabel)
        }
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.size.equalTo(16)
            $0.centerY.equalTo(priceLabel)
        }
    }
    private func setupComponents() {
        dateLabel.textColor = .neutral7
        dateLabel.font = FontSet.pretendardMedium(size: 12)
        priceLabel.textColor = .dark
        priceLabel.font = FontSet.pretendardBold(size: 16)
        statusLabel.textColor = .dark
        statusLabel.font = FontSet.pretendardMedium(size: 14)
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
