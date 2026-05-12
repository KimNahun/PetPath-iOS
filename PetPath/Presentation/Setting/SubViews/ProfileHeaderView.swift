//
//  ProfileHeaderView.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Combine
import UIKit

final class ProfileHeaderView: UITableViewHeaderFooterView {
    let buttonTappedPublisher = PassthroughSubject<Void, Never>()
    
    private let profileImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 18
        $0.layer.masksToBounds = true
    }
    private let nameLabel = UILabel().then {
        $0.font = FontSet.pretendardBold(size: 16)
        $0.textColor = .neutral11
    }
    private let changeAccountTypeButton = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = FontSet.pretendardBold(size: 10)
        $0.setTitleColor(.neutral11, for: .normal)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = ColorSet.neutral7.cgColor
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        changeAccountTypeButton.addTarget(self, action: #selector(changeAccountTypeButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func changeAccountTypeButtonTapped() {
        buttonTappedPublisher.send()
    }
    func setUserData(data: GetUserInfoDTO) {
        
        self.profileImageView.loadImage(url: data.profileImg)
        if data.type == .walker {
            changeAccountTypeButton.backgroundColor = .primary200
            changeAccountTypeButton.setTitle("견주로 전환", for: .normal)
            nameLabel.text = "\(data.name) 워커님"
        } else {
            changeAccountTypeButton.backgroundColor = .secondary100
            changeAccountTypeButton.setTitle("워커로 전환", for: .normal)
            nameLabel.text = "\(data.name) 견주님"
        }
    }
}

extension ProfileHeaderView {
    private func setupUI() {
        [profileImageView, nameLabel, changeAccountTypeButton].forEach {
            self.addSubview($0)
        }
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.size.equalTo(36)
        }
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.height.equalTo(19)
        }
        changeAccountTypeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(61)
            $0.height.equalTo(16)
        }
    }
}
