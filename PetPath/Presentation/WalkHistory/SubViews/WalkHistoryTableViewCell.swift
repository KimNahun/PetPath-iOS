//
//  WalkHistoryTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class WalkHistoryTableViewCell: UITableViewCell {
    
    private let dogImageView = AspectFitImageView()
    
    private let statusLabel = UILabel()
    
    private let dogNameLabel = UILabel()
    
    private let dateLabel = UILabel()
    
    private let locationLabel = UILabel()
    
    private let walkerNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(item: GetWalkHistoryListDTO) {
        let startDate = item.startAt.extractDateComponentsFromISO()
        let endDate = item.endAt.extractDateComponentsFromISO()
        dogImageView.loadImage(url: item.profileImage.first ?? "")
        dogNameLabel.text = item.title
        dateLabel.text = "\(startDate.month).\(startDate.day) (\(startDate.weekday)) \(startDate.hour):\(startDate.minute) ~ \(endDate.hour):\(endDate.minute)"
        locationLabel.text = item.pickup
        walkerNameLabel.text = item.walkerName
        statusLabel.text = item.status.koreanDescription
        statusLabel.setBackgroundColor(with: item.status)
        
        statusLabel.snp.updateConstraints {
            $0.width.equalTo(statusLabel.intrinsicContentSize.width + 12)
        }
        
    }
    
}

extension WalkHistoryTableViewCell {
   
}

extension WalkHistoryTableViewCell {
    private func setupLayouts() {
        [dogImageView, statusLabel, dogNameLabel, dateLabel, locationLabel, walkerNameLabel].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        dogImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(72)
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(dogImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(dogImageView)
            $0.height.equalTo(16)
            $0.width.equalTo(20)
        }
        dogNameLabel.snp.makeConstraints {
            $0.top.equalTo(dogImageView.snp.top).offset(4)
            $0.leading.equalTo(dogImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(19)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(dogNameLabel.snp.bottom).offset(7)
            $0.leading.equalTo(dogNameLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(14)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.equalTo(dogNameLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(17)
        }
        walkerNameLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(3)
            $0.leading.equalTo(dogNameLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(17)
        }
    }
    private func setupComponents() {
        dogImageView.layer.masksToBounds = true
        dogImageView.layer.cornerRadius = 20
        dogImageView.backgroundColor = ColorSet.fromHex("D9D9D9")
        
        dogNameLabel.textColor = .dark
        dogNameLabel.font = FontSet.pretendardBold(size: 16)
        dateLabel.textColor =  ColorSet.fromHex("9C9C9C")
        dateLabel.font = FontSet.pretendardRegular(size: 12)
        locationLabel.textColor = ColorSet.fromHex("6F6F6F")
        locationLabel.font = FontSet.pretendardMedium(size: 14)
        walkerNameLabel.textColor = ColorSet.fromHex("6F6F6F")
        walkerNameLabel.font = FontSet.pretendardMedium(size: 14)
        statusLabel.textColor = .dark
        statusLabel.font = FontSet.pretendardSemiBold(size: 10)
        statusLabel.textAlignment = .center
        statusLabel.layer.masksToBounds = true
        statusLabel.layer.cornerRadius = 7
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
