//
//  PushSwitchView.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class PushSwitchView: UIView {
    
    let isOnPublisher = PassthroughSubject<Bool, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let messageLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    private let pushSwitch = UISwitch()
    
    private let separator = UIView()
    
    init(message: String, description: String, isRequired: Bool = false) {
        super.init(frame: .zero)
        messageLabel.text = message
        descriptionLabel.text = description
        setupUI()
        bind()
        pushSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        if isRequired {
            pushSwitch.isOn = true
            pushSwitch.isUserInteractionEnabled = false
            pushSwitch.onTintColor = .neutral6
        } else {
            pushSwitch.isUserInteractionEnabled = true
            pushSwitch.onTintColor = ColorSet.fromHex("FEE254")
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {

    }
    @objc private func switchChanged(_ sender: UISwitch) {
        isOnPublisher.send(sender.isOn)
    }
}

extension PushSwitchView {
    func setDescription(message: String) {
        descriptionLabel.text = message
    }
    func setSwitch(isOn: Bool) {
        pushSwitch.isOn = isOn
    }
    func getSwitch() -> Bool {
        return pushSwitch.isOn
    }
}

extension PushSwitchView {
    private func setupLayouts() {
        [messageLabel, descriptionLabel, pushSwitch, separator].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(messageLabel.snp.trailing).offset(29)
        }
        pushSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        separator.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    private func setupComponents() {
        messageLabel.font = FontSet.pretendardMedium(size: 14)
        messageLabel.textColor = .dark
        descriptionLabel.font = FontSet.pretendardSemiBold(size: 10)
        descriptionLabel.textColor = ColorSet.fromHex("B4A03C")
        separator.backgroundColor = .neutral3
        pushSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.65)
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
