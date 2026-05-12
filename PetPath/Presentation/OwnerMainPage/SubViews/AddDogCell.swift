//
//  AddDogCell.swift
//  PetPath
//
//  Created by 김나훈 on 6/20/25.
//


import Combine
import UIKit

final class AddDogCell: UICollectionViewCell, UITextFieldDelegate {
    
    // MARK: - UI Components
    
    private let plusImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "plus")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddDogCell {
    private func setupLayouts() {
        [plusImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        plusImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
    private func setupComponents() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        self.backgroundColor = .neutral4
        self.layer.cornerRadius = 15
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
