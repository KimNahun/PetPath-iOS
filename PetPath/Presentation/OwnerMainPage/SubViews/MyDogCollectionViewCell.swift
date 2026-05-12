//
//  MyDogCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//


import Combine
import UIKit

final class MyDogCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    // MARK: - UI Components
    
    private let dogImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
    }
    private let dogNameLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 16)
        $0.textColor = .dark
    }
    private let speciesLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 14)
        $0.textColor = .neutral11
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: DogData) {
        dogImageView.loadImage(url: data.profileImg)
        dogNameLabel.text = data.dogName
        speciesLabel.text = data.species
    }
}

extension MyDogCollectionViewCell {
    private func setupLayouts() {
        [dogImageView, dogNameLabel, speciesLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        dogImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        dogNameLabel.snp.makeConstraints {
            $0.top.equalTo(dogImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(19)
        }
        speciesLabel.snp.makeConstraints {
            $0.top.equalTo(dogNameLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(17)
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
