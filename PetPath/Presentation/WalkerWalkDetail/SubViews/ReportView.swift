//
//  ReportView.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Combine
import UIKit

final class ReportView: UIView {
    
    let tapPublisher = PassthroughSubject<Void, Never>()
    
    private let warningImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "report")
    }
    private let messageLabel = UILabel().then {
        $0.text = "신고"
        $0.textColor = .error1
        $0.font = FontSet.pretendardBold(size: 12)
    }
    
    init() {
        super.init(frame: .zero)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .neutral3
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func handleTap() {
        tapPublisher.send(())
    }
}

extension ReportView {
    private func setupLayouts() {
        [warningImageView, messageLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        warningImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(7)
            $0.size.equalTo(16)
            $0.centerY.equalToSuperview()
        }
        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(warningImageView.snp.trailing).offset(7)
            $0.centerY.equalTo(warningImageView)
        }
    }
    private func setupComponents() {
        
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
