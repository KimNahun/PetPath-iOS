//
//  SearchedAddressCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import UIKit

final class SearchedAddressCell: UITableViewCell {
    
    private let titleLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.textColor = .neutral10
    }
    
    private let subLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 12)
        $0.textColor = .neutral8
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(title: String, sub: String) {
        titleLabel.text = title
        subLabel.text = sub
    }
    
}

extension SearchedAddressCell {
    private func setupUI() {
        [titleLabel, subLabel].forEach { contentView.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(17)
        }
        subLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(14)
        }
    }
}
