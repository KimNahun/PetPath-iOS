//
//  MainPageFooterView.swift
//  PetPath
//
//  Created by 김나훈 on 3/26/25.
//

import Combine
import UIKit

final class MainPageFooterView: UIView {
    
    let agreementPublisher = PassthroughSubject<Void, Never>()
    let personalityInfoPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let separatorView = UIView().then {
        $0.backgroundColor = .neutral6
    }
    
    private let logoImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "appLogo")
    }
    
    private let agreementButton = UIButton().then {
        $0.setTitle("이용약관", for: .normal)
    }
    
    private let separatorLabel = UILabel().then {
        $0.text = "|"
    }
    
    private let processPersonalityInfoButton = UIButton().then {
        $0.setTitle("개인정보처리방침", for: .normal)
    }
    
    private let phoneGuideLabel = UILabel().then {
        $0.text = "고객센터"
    }
    
    private let telephoneNumberLabel = UILabel().then {
        $0.text = "전화번호: 070-7954-4965"
    }
    
    private let appInfoLabel = UILabel().then {
        $0.text = "펫패스(PetPath)"
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "대표자: 권인 | 사업자번호: 219-20-72784"
    }
    
    private let numberLabel = UILabel().then {
        $0.text = "통신판매업신고번호: 2025-경기안산-2015"
    }
    
    private let addressLabel = UILabel().then {
        $0.text = "경기도 안산시 상록구 중보로 27, 이동 401-111호"
    }
    
    private let appNameMessageLabel = UILabel().then {
        $0.text = "© Petpath. All rights reserved."
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
        agreementButton.addTarget(self, action: #selector(agreementButtonTapped), for: .touchUpInside)
        processPersonalityInfoButton.addTarget(self, action: #selector(processPersonalityInfoButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    @objc private func agreementButtonTapped() {
        agreementPublisher.send()
    }
    @objc private func processPersonalityInfoButtonTapped() {
        personalityInfoPublisher.send()
    }
}
extension MainPageFooterView {
    private func setupLayouts() {
        [separatorView, logoImageView, agreementButton,separatorLabel,processPersonalityInfoButton, phoneGuideLabel, telephoneNumberLabel, appInfoLabel, nameLabel, numberLabel, addressLabel, appNameMessageLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(11)
            $0.size.equalTo(54)
            $0.centerX.equalToSuperview()
        }
        agreementButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.trailing.equalTo(logoImageView.snp.leading).offset(3.5)
            $0.width.equalTo(37)
            $0.height.equalTo(12)
        }
        separatorLabel.snp.makeConstraints {
            $0.leading.equalTo(agreementButton.snp.trailing).offset(12.5)
            $0.centerY.equalTo(agreementButton)
        }
        processPersonalityInfoButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.leading.equalTo(separatorLabel.snp.trailing).offset(12.5)
            $0.width.equalTo(73)
            $0.height.equalTo(12)
        }
        phoneGuideLabel.snp.makeConstraints {
            $0.top.equalTo(processPersonalityInfoButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        telephoneNumberLabel.snp.makeConstraints {
            $0.top.equalTo(phoneGuideLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        appInfoLabel.snp.makeConstraints {
            $0.top.equalTo(telephoneNumberLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(appInfoLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        appNameMessageLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-29)
        }
    }
    private func setupComponents() {
        [agreementButton, processPersonalityInfoButton].forEach {
            $0.titleLabel?.font = FontSet.pretendardSemiBold(size: 10)
            $0.setTitleColor(.neutral11, for: .normal)
        }
        separatorLabel.font = FontSet.pretendardMedium(size: 14)
        separatorLabel.textColor = .neutral9
        [phoneGuideLabel, appInfoLabel].forEach {
            $0.font = FontSet.pretendardSemiBold(size: 10)
            $0.textColor = .neutral11
        }
        [telephoneNumberLabel, nameLabel, numberLabel, addressLabel].forEach {
            $0.font = FontSet.pretendardSemiBold(size: 10)
            $0.textColor = .neutral9
        }
        appNameMessageLabel.font = FontSet.pretendardMedium(size: 10)
        appNameMessageLabel.textColor = .neutral7
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        self.backgroundColor = .systemBackground
    }
}
