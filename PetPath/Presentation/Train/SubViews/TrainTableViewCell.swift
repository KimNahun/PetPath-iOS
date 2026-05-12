//
//  TrainTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Combine
import UIKit

final class TrainTableViewCell: UITableViewCell {
    
    private let titleView = UIView().then {
        $0.backgroundColor = .neutral3
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
    }
    
    private let titleLabel = UILabel()
    
    private let progressView = UIProgressView()
    
    private let chevronImage = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    private let percentLabel = UILabel()
    
    private let messageLabel = UILabel().then {
        $0.text = "학습"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(item: GetWalkerTrainListDTO) {
        titleLabel.text = item.title
        
        let progress = Float(item.progress) / Float(item.page)
        progressView.progress = progress
        
        let percent = progress * 100
        percentLabel.text = String(format: "%.1f%%", percent)
    }
    
}

extension TrainTableViewCell {
   
}

extension TrainTableViewCell {
    private func setupLayouts() {
        contentView.addSubview(titleView)
        [titleLabel, progressView, chevronImage, percentLabel, messageLabel].forEach {
            titleView.addSubview($0)
        }
        
    }
    private func setupConstraints() {
        titleView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(80)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(12)
        }
        progressView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.height.equalTo(10)
            $0.trailing.equalTo(chevronImage.snp.leading).offset(-37)
        }
        chevronImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(24)
        }
        percentLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(2)
            $0.leading.equalTo(progressView)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(2)
            $0.leading.equalTo(percentLabel.snp.trailing).offset(2)
        }
    }
    private func setupComponents() {
        titleLabel.font = FontSet.pretendardBold(size: 14)
        titleLabel.textColor = .neutral8
        progressView.trackTintColor = ColorSet.fromHex("D9D9D9")
        progressView.progressTintColor = ColorSet.fromHex("FEE254")
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        percentLabel.font = FontSet.pretendardRegular(size: 12)
        percentLabel.textColor = ColorSet.fromHex("D8C047")
        messageLabel.font = FontSet.pretendardRegular(size: 12)
        messageLabel.textColor = .neutral8
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
