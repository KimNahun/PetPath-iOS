//
//  RecentPickupCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import UIKit

final class RecentPickupCell: UITableViewCell {
    private let addressLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.textColor = .neutral10
        $0.numberOfLines = 0
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        addressLabel.text = text
    }
}
