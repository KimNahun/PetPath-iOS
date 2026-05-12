//
//  SettingCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import UIKit

final class SettingCell: UITableViewCell {
    
    private let titleLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 14)
    }
    private let separator = UIView().then {
        $0.backgroundColor = .neutral3
    }
    private let chevronImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String, textColor: UIColor, showSeparator: Bool) {
        titleLabel.text = text
        titleLabel.textColor = textColor
        separator.isHidden = !showSeparator
    }
    
    private func setupUI() {
        [titleLabel, separator, chevronImageView].forEach {
            contentView.addSubview($0)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        separator.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(24)
        }
    }
}
