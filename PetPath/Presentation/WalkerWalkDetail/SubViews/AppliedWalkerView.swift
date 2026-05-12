//
//  AppliedWalkerView.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import Combine
import UIKit

final class AppliedWalkerView: UIView {
    
    // MARK: - UI Components
    private let separatorView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.text = "지원한 산책"
    }
    
    private let priceGuideLabel = UILabel().then {
        $0.text = "제시 금액"
    }
    
    private let priceLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(price: Int, description: String) {
        priceLabel.text = "\(price.formattedWithComma)원"
        descriptionLabel.text = description
    }
    
}
extension AppliedWalkerView {

    
}
extension AppliedWalkerView {
    private func setupLayouts() {
        [separatorView, titleLabel, priceGuideLabel, priceLabel, descriptionLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        priceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(priceGuideLabel.snp.trailing).offset(6)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(8)
            $0.bottom.equalToSuperview()
        }
    }
    private func setupComponents() {
        [titleLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardBold(size: 18)
        }
        [priceGuideLabel, descriptionLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        separatorView.backgroundColor = .neutral3
        priceLabel.textColor = .secondary600
        priceLabel.font = FontSet.pretendardSemiBold(size: 12)
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        self.backgroundColor = .systemBackground
    }
}
