//
//  DogDetailCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import UIKit

final class DogDetailCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let textLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 12)
        $0.textAlignment = .center
        $0.textColor = .dark
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: (text: String, color: UIColor)) {
        textLabel.text = item.text
        self.backgroundColor = item.color
    }
}

extension DogDetailCollectionViewCell {
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

