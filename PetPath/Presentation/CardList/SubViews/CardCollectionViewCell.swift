//
//  CardCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let deletePublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private let cardInfoLabel = UILabel()
    private let registGuideLabel = UILabel().then {
        $0.text = "등록일"
    }
    private let registLabel = UILabel()
    private let recentPayGuideLabel = UILabel().then {
        $0.text = "최근 결제"
    }
    private let recentPayLabel = UILabel()
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "trashcan"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func configure(item: CardData) {
        cardInfoLabel.text = "\(item.cardVendor) \(item.firstNum)"
        registLabel.text = item.createAt.extractDateUsingFormatter()
        if let recentPay = item.recentPay {
            recentPayLabel.text = "\(recentPay.extractDateUsingFormatter()) 결제 성공"
            recentPayLabel.textColor = .tertiary
        } else {
            recentPayLabel.text = "없음"
            recentPayLabel.textColor = .neutral7
        }
    }
    
    @objc private func deleteButtonTapped() {
        deletePublisher.send()
    }
}

extension CardCollectionViewCell {
    private func setupLayouts() {
        [cardInfoLabel, registGuideLabel, registLabel, recentPayGuideLabel, recentPayLabel, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        cardInfoLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        registGuideLabel.snp.makeConstraints {
            $0.top.equalTo(cardInfoLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(52)
        }
        registLabel.snp.makeConstraints {
            $0.top.equalTo(cardInfoLabel.snp.bottom).offset(16)
            $0.leading.equalTo(registGuideLabel.snp.trailing).offset(8)
        }
        recentPayGuideLabel.snp.makeConstraints {
            $0.top.equalTo(registGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(52)
        }
        recentPayLabel.snp.makeConstraints {
            $0.top.equalTo(registGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(registGuideLabel.snp.trailing).offset(8)
        }
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(cardInfoLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(16)
        }
    }
    private func setupComponents() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        self.backgroundColor = .neutral4
        cardInfoLabel.textColor = .dark
        cardInfoLabel.font = FontSet.pretendardBold(size: 16)
        [registGuideLabel, registLabel, recentPayGuideLabel, recentPayLabel].forEach {
            $0.textColor = .neutral7
            $0.font = FontSet.pretendardSemiBold(size: 12)
        }
        
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}

