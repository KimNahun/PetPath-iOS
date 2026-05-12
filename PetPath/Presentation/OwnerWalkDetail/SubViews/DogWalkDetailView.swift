//
//  DogWalkDetailView.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class DogWalkDetailView: UIView {
    
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    
    private let markerImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "marker")
    }
    
    private let locationLabel = UILabel()
    
    private let clockImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "clock")
    }
    
    private let timeLabel = UILabel()
    
    private let timeDiffLabel = UILabel()
    
    private let wonImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "won")
    }
    
    private let priceLabel = UILabel()
    
    private let separator1 = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(title: String, location: String, startAt: String, endAt: String, price: Int, status: WalkStatus) {
        let startData = startAt.extractDateComponentsFromISO()
        let endData = endAt.extractDateComponentsFromISO()
        titleLabel.text = title
        locationLabel.text = location
        if status == .walking {
            timeLabel.text = "\(startData.month)/\(startData.day)(\(startData.weekday)) \(startData.hour):\(startData.minute) ~ 진행 중"
            timeDiffLabel.text = "\(TimeWorker.shared.calculateTimeDiff(from: startAt, to: TimeWorker.shared.getCurrentLocalTime())) 산책중"
        } else {
            timeLabel.text = "\(startData.month)/\(startData.day)(\(startData.weekday)) \(startData.hour):\(startData.minute) ~ \(endData.hour):\(endData.minute)"
            timeDiffLabel.text = TimeWorker.shared.calculateTimeDiff(from: startAt, to: endAt)
        }
        priceLabel.text = "최소 \(price.formattedWithComma)원"
    }
    
}
extension DogWalkDetailView {

    
}
extension DogWalkDetailView {
    private func setupLayouts() {
        [titleLabel, markerImageView, locationLabel, clockImageView, timeLabel, timeDiffLabel, wonImageView, priceLabel, separator1].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        markerImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalTo(titleLabel)
            $0.size.equalTo(16)
        }
        locationLabel.snp.makeConstraints {
            $0.leading.equalTo(markerImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(markerImageView)
        }
        clockImageView.snp.makeConstraints {
            $0.top.equalTo(markerImageView.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.size.equalTo(16)
        }
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(clockImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(clockImageView)
        }
        timeDiffLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(timeLabel)
        }
        wonImageView.snp.makeConstraints {
            $0.top.equalTo(timeDiffLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.size.equalTo(16)
        }
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(wonImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(wonImageView)
        }
        separator1.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(8)
        }
        
    }
    private func setupComponents() {
        [titleLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardBold(size: 18)
        }
        [locationLabel, timeLabel, timeDiffLabel, priceLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardMedium(size: 14)
        }
        
        [separator1].forEach {
            $0.backgroundColor = .neutral3
        }
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        self.backgroundColor = .systemBackground
    }
}
