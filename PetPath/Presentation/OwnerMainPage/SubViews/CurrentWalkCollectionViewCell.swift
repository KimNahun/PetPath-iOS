//
//  CurrentWalkCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 5/18/25.
//

import UIKit

final class CurrentWalkCollectionViewCell: UICollectionViewCell {

    private let profileImageView = AspectFitImageView()
    private let statusLabel = PaddingLabel(padding: .init(top: 2, left: 5, bottom: 2, right: 5))
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let addressLabel = UILabel()
    private let chevronImage = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    private let walkerCountLabel = UILabel().then {
        $0.isHidden = true
    }
    private let separator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: GetMainCurrentWalkListDTO) {
        profileImageView.loadImage(url: item.profileImg)
        titleLabel.text = item.title
        let startData = item.startAt.extractDateComponentsFromISO()
        let endData = item.endAt.extractDateComponentsFromISO()
        dateLabel.text = "\(startData.month).\(startData.day) (\(startData.weekday)) \(startData.hour):\(startData.minute) ~ \(endData.hour):\(endData.minute)"
        addressLabel.text = item.pickupAddress
        statusLabel.text = item.status.koreanDescription
        statusLabel.setBackgroundColor(with: item.status)
        if let count = item.applyWalkerCount {
            walkerCountLabel.isHidden = false
            walkerCountLabel.text = count >= 9 ? "9+" : "\(count)"
        } else {
            walkerCountLabel.isHidden = true
        }
    }
}

private extension CurrentWalkCollectionViewCell {
    func setupLayouts() {
        [profileImageView, statusLabel, titleLabel, dateLabel, addressLabel, chevronImage, walkerCountLabel, separator].forEach {
            contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.size.equalTo(62)
            $0.leading.equalToSuperview().offset(9)
        }
        statusLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView.snp.bottom)
            $0.centerX.equalTo(profileImageView)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(9)
            $0.trailing.equalTo(chevronImage.snp.leading)
        }
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(chevronImage.snp.leading)
        }
        addressLabel.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(chevronImage.snp.leading)
        }
        chevronImage.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-15)
        }
        walkerCountLabel.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(-2.5)
            $0.bottom.equalTo(statusLabel.snp.bottom).offset(-7)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(13)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func setupComponents() {
        profileImageView.layer.cornerRadius = 12
        profileImageView.clipsToBounds = true
        titleLabel.font = FontSet.pretendardBold(size: 16)
        titleLabel.textColor = ColorSet.fromHex("3D3D3D")
        dateLabel.font = FontSet.pretendardRegular(size: 12)
        dateLabel.textColor = ColorSet.fromHex("9C9C9C")
        addressLabel.font = FontSet.pretendardMedium(size: 14)
        addressLabel.textColor = ColorSet.fromHex("6F6F6F")
        statusLabel.font = FontSet.pretendardSemiBold(size: 10)
        statusLabel.textColor = ColorSet.fromHex("3D3D3D")
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        separator.backgroundColor = .neutral6
        walkerCountLabel.font = FontSet.pretendardSemiBold(size: 10)
        walkerCountLabel.backgroundColor = .error1
        walkerCountLabel.textColor = .white
        walkerCountLabel.textAlignment = .center
        walkerCountLabel.layer.cornerRadius = 8
        walkerCountLabel.clipsToBounds = true
    }

    func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
