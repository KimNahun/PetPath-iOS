//
//  PayoutContractTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 5/3/25.
//

import Combine
import UIKit

final class PayoutContractTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    
    private let statusLabel = UILabel()
    
    private let subMessageLabel = UILabel()
    
    private let separator = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("D1D1D1")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(item: PayoutContractViewModel.PayoutItem, identify: Bool) {
        titleLabel.text = item.message
        if let status = item.status {
            switch status {
            case .pending, .denied: statusLabel.textColor = .error1
            case .allow: statusLabel.textColor = .tertiary
            case .unknown: break
            }
        }
        statusLabel.text = "*\(item.status?.koreanDescription ?? "")"
        statusLabel.isHidden = item.status == nil
        if identify && item.title != "주민등록번호" {
            subMessageLabel.text = "\(item.title)-*******"
        } else {
            subMessageLabel.text = item.title
        }
        subMessageLabel.textColor = item.isTitle ? .dark : .neutral6
    }
    
}

extension PayoutContractTableViewCell {
   
}

extension PayoutContractTableViewCell {
    private func setupLayouts() {
        [titleLabel, statusLabel, subMessageLabel, separator].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        statusLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(2)
            $0.centerY.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        separator.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0.3)
            $0.bottom.equalToSuperview()
        }
    }
    private func setupComponents() {
        titleLabel.font = FontSet.pretendardMedium(size: 15)
        titleLabel.textColor = .dark
        statusLabel.font = FontSet.pretendardSemiBold(size: 10)
        subMessageLabel.font = FontSet.pretendardMedium(size: 15)
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
