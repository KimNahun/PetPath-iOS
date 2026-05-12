//
//  InquryTypeCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import Combine
import UIKit

final class InquryTypeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let textLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 12)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, isSelected: Bool) {
        textLabel.text = text
        self.backgroundColor = isSelected ? ColorSet.fromHex("FEE254") : ColorSet.fromHex("FFF8D6")
    }
}

extension InquryTypeCollectionViewCell {
    private func setupLayouts() {
        [textLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        textLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.height.equalTo(14)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
    private func setupComponents() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}

