//
//  PersonalityCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class PersonalityCollectionViewCell: UICollectionViewCell {
    
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
    
    func configure(item: KeywordTag) {
        textLabel.text = item.name
        if item.isSelected {
            textLabel.textColor = .neutral11
            self.backgroundColor = .primary400
        } else {
            textLabel.textColor = .neutral7
            self.backgroundColor = .neutral4
        }
    }
}

extension PersonalityCollectionViewCell {
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

