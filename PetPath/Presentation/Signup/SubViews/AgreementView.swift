//
//  AgreementView.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Combine
import UIKit

/// 동의 항목을 나타내는 뷰
final class AgreementView: UIView {
    
    let agreementPublisher = PassthroughSubject<Bool, Never>()
    let detailButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private let agreementButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox"), for: .normal)
        $0.setImage(UIImage(named: "checkboxFill"), for: .selected)
    }
    
    private let agreementLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 12)
        $0.textColor = ColorSet.dark
        $0.numberOfLines = 0
        $0.isUserInteractionEnabled = true
    }
    
    private let detailButton = UIButton().then {
        $0.titleLabel?.font = FontSet.pretendardSemiBold(size: 10)
        $0.setTitleColor(ColorSet.gray500, for: .normal)
        $0.setTitle("자세히 보기", for: .normal)
    }
    
    
    // MARK: - 초기화
    init(text: String = "", showDetailButton: Bool = true) {
        super.init(frame: .zero)
        agreementLabel.text = text
        detailButton.isHidden = !showDetailButton
        setupUI()
        agreementButton.addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCheck))
        agreementLabel.addGestureRecognizer(tap)
        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    @objc private func toggleCheck() {
        agreementButton.isSelected.toggle()
        agreementPublisher.send(agreementButton.isSelected)
    }
    
    @objc private func detailButtonTapped() {
        detailButtonPublisher.send()
    }
    
    func setButtonStatus(isSelected: Bool) {
        agreementButton.isSelected = isSelected
    }
    
    func getStatus() -> Bool {
        return agreementButton.isSelected
    }
    
    func setupText(text: String) {
        agreementLabel.text = text
    }
    
}

extension AgreementView {
    private func setupLayOuts() {
        [agreementButton, agreementLabel, detailButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        agreementButton.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        agreementLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(agreementButton.snp.trailing).offset(4)
            $0.trailing.equalTo(detailButton.isHidden ? self.snp.trailing : detailButton.snp.trailing).offset(-4)
        }
        detailButton.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
    }
}
