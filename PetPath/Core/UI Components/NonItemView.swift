//
//  NonItemView.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit


final class NonItemView: UIView {
    
    // MARK: - Properties
    let registPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let messageLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 16)
        $0.textColor = .neutral7
        $0.textAlignment = .center
    }
    
    private let registButton = BottomPlacedButton(isSelected: true)
    
    init(frame: CGRect = .zero, message: String, buttonText: String) {
        super.init(frame: frame)
        messageLabel.text = message
        registButton.setTitle(buttonText, for: .normal)
        registButton.addTarget(self, action: #selector(registButtonTapped), for: .touchUpInside)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    @objc private func registButtonTapped() {
        registPublisher.send()
    }
}
extension NonItemView {
    private func setupLayouts() {
        [messageLabel, registButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(23)
        }
        registButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(133)
            $0.height.equalTo(33)
            $0.bottom.equalToSuperview()
        }
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
    }
}
