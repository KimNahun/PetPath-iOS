//
//  FindWalkTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/27/25.
//

import Combine
import UIKit

final class FindWalkTableViewCell: UITableViewCell {

    var subscriptions = Set<AnyCancellable>()
    
    private lazy var dogDetailCollectionView: DogDetailCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = DogDetailCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()
    
    private let dogImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.backgroundColor = ColorSet.fromHex("D9D9D9")
    }
    
    private let titleLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    private let locationLabel = UILabel()
    
    private let priceLabel = UILabel()
    
    private let showDetailButton = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    func configure(item: GetWalkRequestListDTO) {
        let mappedInfoList: [(text: String, color: UIColor)] = [
            (text: item.size.koreanDescription, color: ColorSet.fromHex("AFF4C6"))
        ] + item.char.map { (text: $0, color: .primary300) }
        + item.require.map { (text: $0, color: .secondary100) }
        showDetailButton.setTitle(item.isApplied ? "지원완료" : "상세보기", for: .normal)
        showDetailButton.backgroundColor = item.isApplied ? ColorSet.fromHex("AFF4C6") : ColorSet.fromHex("FEED93")
        dogDetailCollectionView.setKeywordList(item: mappedInfoList)
        titleLabel.text = item.title
        let startData = item.startAt.extractDateComponentsFromISO()
        let endData = item.endAt.extractDateComponentsFromISO()
        timeLabel.text = "\(startData.month)/\(startData.day)(\(startData.weekday)) \(startData.hour):\(startData.minute) ~ \(endData.hour):\(endData.minute)"
        locationLabel.text = item.shortAddress
        priceLabel.text = "최소 \(item.minPrice.formattedWithComma)원"
        dogImageView.loadImage(url: item.profileImg)
        
    }
    
}

extension FindWalkTableViewCell {
}

extension FindWalkTableViewCell {
    private func setupLayouts() {
        
        [dogDetailCollectionView, dogImageView, titleLabel, timeLabel, locationLabel, priceLabel, showDetailButton].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        
        dogDetailCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(25)
        }
        dogImageView.snp.makeConstraints {
            $0.top.equalTo(dogDetailCollectionView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(50)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dogImageView)
            $0.leading.equalTo(dogImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(showDetailButton.snp.leading)
            $0.height.equalTo(19)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(dogImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(showDetailButton.snp.leading)
            $0.height.equalTo(14)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(dogImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(showDetailButton.snp.leading)
            $0.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints {
            $0.centerX.equalTo(showDetailButton)
            $0.centerY.equalTo(timeLabel)
        }
        showDetailButton.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(4)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-16)
            $0.width.equalTo(76)
            $0.height.equalTo(25)
            $0.bottom.equalTo(contentView.snp.bottom).inset(12)
        }
    }
    private func setupComponents() {
        titleLabel.textColor = .dark
        titleLabel.font = FontSet.pretendardBold(size: 16)
        timeLabel.textColor = .dark
        timeLabel.font = FontSet.pretendardMedium(size: 12)
        locationLabel.textColor = .neutral7
        locationLabel.font = FontSet.pretendardMedium(size: 12)
        priceLabel.textColor = .neutral9
        priceLabel.font = FontSet.pretendardSemiBold(size: 10)
        showDetailButton.titleLabel?.font = FontSet.pretendardMedium(size: 12)
        showDetailButton.setTitleColor(.dark, for: .normal)
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
