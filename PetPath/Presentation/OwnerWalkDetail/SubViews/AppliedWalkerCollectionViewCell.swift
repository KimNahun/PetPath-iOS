//
//  AppliedWalkerCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 4/11/25.
//

import Combine
import UIKit

final class AppliedWalkerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    var subscriptions = Set<AnyCancellable>()
    let selectButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let profileImageView = AspectFitImageView()
    
    private let walkerInfoLabel = UILabel()
    
    private let priceGuideLabel = UILabel().then {
        $0.text = "제시 금액"
    }
    
    private let priceLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    private let selectWalkerButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("워커 선택하기", for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        selectWalkerButton.addTarget(self, action: #selector(selectWalkerButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
           super.prepareForReuse()
           subscriptions.forEach { $0.cancel() }
           subscriptions.removeAll()
       }
    
    func configure(item: GetApplyWalkerListDTO) {
        profileImageView.loadImage(url: item.profileImage)
        walkerInfoLabel.text = "\(item.walkerName)(\(item.gender.koreanDescription)/\(item.age)세)"
        priceLabel.text = "\(item.price.formattedWithComma)원"
        descriptionLabel.text = item.description
    }
}
extension AppliedWalkerCollectionViewCell {
    @objc private func selectWalkerButtonTapped() {
        selectButtonPublisher.send()
    }
}
extension AppliedWalkerCollectionViewCell {
    private func setupLayouts() {
        [profileImageView, walkerInfoLabel, priceGuideLabel, priceLabel, descriptionLabel, selectWalkerButton].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(50)
        }
        walkerInfoLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.height.equalTo(19)
        }
        priceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(walkerInfoLabel.snp.bottom).offset(4)
            $0.leading.equalTo(walkerInfoLabel)
            $0.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(priceGuideLabel)
            $0.leading.equalTo(priceGuideLabel.snp.trailing).offset(4)
            $0.height.equalTo(14)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        selectWalkerButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(33)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    private func setupComponents() {
        profileImageView.backgroundColor = .neutral6
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 25
        
        walkerInfoLabel.textColor = .neutral11
        walkerInfoLabel.font = FontSet.pretendardBold(size: 16)
        
        priceGuideLabel.textColor = .neutral11
        priceGuideLabel.font = FontSet.pretendardMedium(size: 12)
        
        priceLabel.textColor = .secondary600
        priceLabel.font = FontSet.pretendardSemiBold(size: 12)
        
        descriptionLabel.textColor = .dark
        descriptionLabel.font = FontSet.pretendardMedium(size: 12)
        descriptionLabel.numberOfLines = 0
        
        self.setupShadow()
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
