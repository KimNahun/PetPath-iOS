//
//  ConditionCheckView.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Combine
import UIKit

/// 동의 항목을 나타내는 뷰
final class ConditionCheckView: UIView {
    
    // MARK: - UI Components
    
    private let stateLabel = UILabel().then {
        $0.backgroundColor = .dangerSecondary
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 6
    }
    private let textLabel = UILabel().then {
        $0.textColor = .gray500
        $0.font = FontSet.pretendardRegular(size: 12)
    }
    // MARK: - 초기화
    init(text: String) {
        super.init(frame: .zero)
        textLabel.text = text
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func setState(state: ProcessState) {
        switch state {
        case .common: stateLabel.backgroundColor = .dangerSecondary
        case .success: stateLabel.backgroundColor = .tertiary
        case .fail: stateLabel.backgroundColor = .dangerTertiary
        }
    }
}

extension ConditionCheckView {
    private func setupLayOuts() {
        [stateLabel, textLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        stateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(1)
            $0.leading.equalToSuperview()
            $0.size.equalTo(12)
        }
        textLabel.snp.makeConstraints {
            $0.centerY.height.equalToSuperview()
            $0.leading.equalTo(stateLabel.snp.trailing).offset(8)
        }
    }
    
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
    }
}
