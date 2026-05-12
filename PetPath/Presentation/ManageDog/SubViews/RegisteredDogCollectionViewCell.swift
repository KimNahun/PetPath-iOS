//
//  RegisteredDogCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class RegisteredDogCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    // MARK: - UI Components
    
    private let dogCardView = DogCardView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: DogData, selected: Bool = false) {
        dogCardView.configure(name: data.dogName, species: data.species, birthday: data.birthday, gender: data.gender, isNeuter: data.isNeuter, imageUrl: data.profileImg, selected: selected)
    }
}

extension RegisteredDogCollectionViewCell {
    private func setupUI() {
        addSubview(dogCardView)
        dogCardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.layer.masksToBounds = false
    }
}
