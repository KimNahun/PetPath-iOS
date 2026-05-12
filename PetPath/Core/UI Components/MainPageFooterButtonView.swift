//
//  MainPageFooterButtonView.swift
//  PetPath
//
//  Created by 김나훈 on 3/26/25.
//

import Combine
import UIKit

final class MainPageFooterButtonView: UIView {
    
    let chatButtonPublisher = PassthroughSubject<Void, Never>()
    let walkHistoryButtonPublisher = PassthroughSubject<Void, Never>()
    let settingButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let separatorView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.shadowColor = ColorSet.fromHex("#0C0C0D").cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 0, height: -3)
        $0.layer.shadowRadius = 3
        $0.layer.masksToBounds = false
    }
    private let chatButton = UIButton().then { _ in
    }
    private let walkHistoryButton = UIButton().then { _ in
    }
    private let settingButton = UIButton().then { _ in
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        walkHistoryButton.addTarget(self, action: #selector(walkHistoryButtonTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}

extension MainPageFooterButtonView {
    @objc private func chatButtonTapped() {
        chatButtonPublisher.send()
    }
    @objc private func walkHistoryButtonTapped() {
        walkHistoryButtonPublisher.send()
    }
    @objc private func settingButtonTapped() {
        settingButtonPublisher.send()
    }
    
}
extension MainPageFooterButtonView {
    private func setupLayouts() {
        [separatorView, chatButton, walkHistoryButton, settingButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        chatButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(48)
            $0.width.equalTo(50)
            $0.height.equalTo(40)
        }
        walkHistoryButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(40)
        }
        settingButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-48)
            $0.width.equalTo(50)
            $0.height.equalTo(40)
        }
        
    }
    private func setupComponents() {
        let buttonData: [(image: String, text: String)] = [
            ("chat", "채팅"),
            ("calendar", "산책내역"),
            ("setting", "설정")
        ]
        
        let buttons = [chatButton, walkHistoryButton, settingButton]
        zip(buttons, buttonData).forEach { (button, data) in
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage(named: data.image)
            var text = AttributedString(data.text)
            text.font = FontSet.pretendardMedium(size: 12)
            configuration.attributedTitle = text
            configuration.imagePadding = 1
            configuration.imagePlacement = .top
            configuration.baseBackgroundColor = .clear
            configuration.baseForegroundColor = .neutral9
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4)
            
            button.configuration = configuration
        }
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        self.backgroundColor = .systemBackground
    }
}
