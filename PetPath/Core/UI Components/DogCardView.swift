//
//  DogCardView.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import UIKit

final class DogCardView: UIView {
    private let nameLabel = UILabel()
    
    private let speciesGuideLabel = UILabel().then {
        $0.text = "견종"
    }
    private let ageGuideLabel = UILabel().then {
        $0.text = "나이"
    }
    private let genderGuideLabel = UILabel().then {
        $0.text = "성별"
    }
    private let neuterGuideLabel = UILabel().then {
        $0.text = "중성화"
    }
    private let speciesLabel = UILabel()
    private let ageLabel = UILabel()
    private let genderLabel = UILabel()
    private let neuterLabel = UILabel()
    
    private let imageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        $0.backgroundColor = ColorSet.fromHex("D9D9D9")
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func configure(name: String, species: String, birthday: String, gender: Gender, isNeuter: Bool, imageUrl: String?, selected: Bool = false) {
        let age = birthday.calculateAge()
        nameLabel.text = name
        speciesLabel.text = species
        ageLabel.text = "\(age?.year ?? "")살 \(age?.month ?? "")개월"
        genderLabel.text = gender == .male ? "남" : "여"
        neuterLabel.text = isNeuter ? "수술 완료" : "수술 미진행"
        self.backgroundColor = selected ? .primary300 : .neutral4
        if let imageUrl = imageUrl {
            imageView.loadImage(url: imageUrl)
        }
    }
}

extension DogCardView {
    private func setupLayouts() {
        [nameLabel, speciesGuideLabel, speciesLabel, ageGuideLabel, ageLabel, genderGuideLabel, genderLabel, neuterGuideLabel, neuterLabel, imageView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(16)
            $0.leading.equalTo(self.snp.leading).offset(16)
            $0.height.equalTo(19)
        }
        speciesGuideLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.leading.equalTo(nameLabel)
            $0.height.equalTo(17)
            $0.width.equalTo(52)
        }
        speciesLabel.snp.makeConstraints {
            $0.top.height.equalTo(speciesGuideLabel)
            $0.leading.equalTo(speciesGuideLabel.snp.trailing).offset(8)
        }
        ageGuideLabel.snp.makeConstraints {
            $0.leading.height.equalTo(speciesGuideLabel)
            $0.top.equalTo(speciesGuideLabel.snp.bottom).offset(8)
            $0.width.equalTo(52)
        }
        ageLabel.snp.makeConstraints {
            $0.top.height.equalTo(ageGuideLabel)
            $0.leading.equalTo(speciesGuideLabel.snp.trailing).offset(8)
        }
        genderGuideLabel.snp.makeConstraints {
            $0.leading.height.equalTo(speciesGuideLabel)
            $0.top.equalTo(ageGuideLabel.snp.bottom).offset(8)
            $0.width.equalTo(52)
        }
        genderLabel.snp.makeConstraints {
            $0.top.height.equalTo(genderGuideLabel)
            $0.leading.equalTo(speciesGuideLabel.snp.trailing).offset(8)
        }
        neuterGuideLabel.snp.makeConstraints {
            $0.leading.height.equalTo(speciesGuideLabel)
            $0.top.equalTo(genderGuideLabel.snp.bottom).offset(8)
            $0.width.equalTo(52)
        }
        neuterLabel.snp.makeConstraints {
            $0.top.height.equalTo(neuterGuideLabel)
            $0.leading.equalTo(speciesGuideLabel.snp.trailing).offset(8)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(16)
            $0.trailing.equalTo(self.snp.trailing).offset(-16)
            $0.size.equalTo(80)
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
        
        nameLabel.font = FontSet.pretendardSemiBold(size: 16)
        nameLabel.textColor = .dark
        [speciesGuideLabel, ageGuideLabel, genderGuideLabel, neuterGuideLabel].forEach {
            $0.textColor = .neutral8
            $0.font = FontSet.pretendardSemiBold(size: 14)
        }
        [speciesLabel, ageLabel, genderLabel, neuterLabel].forEach {
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardSemiBold(size: 14)
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
