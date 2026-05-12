//
//  WalkDogInfoCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 3/29/25.
//

// TODO: 강아지 인증했으면 이미지뷰 추가
import Combine
import UIKit

final class WalkDogInfoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
//    private let numberLabel = UILabel()
    
    private let dogCardView = DogCardView().then {
        $0.layer.masksToBounds = false
    }
    
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
    
    private let guideLabel = UILabel().then {
        $0.text = "부가 정보"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: DogDTO, index: Int) {
   //     numberLabel.text = "\(index + 1)."
        dogCardView.configure(name: item.dogName, species: item.species, birthday: item.birthday, gender: item.gender, isNeuter: item.isNeuter, imageUrl: item.profileImg)
        let mappedInfoList: [(text: String, color: UIColor)] = [
            (text: item.size.koreanDescription, color: ColorSet.fromHex("AFF4C6"))
        ] + item.char.map { (text: $0, color: .primary300) }
        + item.require.map { (text: $0, color: .secondary100) }
        dogDetailCollectionView.setKeywordList(item: mappedInfoList)
        descriptionLabel.text = item.description
        
        dogDetailCollectionView.snp.updateConstraints {
            $0.height.equalTo(dogDetailCollectionView.calculateDynamicHeight())
        }
    }
}

extension WalkDogInfoCollectionViewCell {
    private func setupLayouts() {
        [/*numberLabel, */dogCardView, dogDetailCollectionView, guideLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
//        numberLabel.snp.makeConstraints {
//            $0.top.equalTo(contentView.snp.top).offset(16)
//            $0.leading.equalToSuperview()
//            $0.height.equalTo(19)
//        }
        dogCardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(159)
        }
        dogDetailCollectionView.snp.makeConstraints {
            $0.top.equalTo(dogCardView.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(dogDetailCollectionView.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.bottom).offset(-8)
        }
    }
    private func setupComponents() {
//        numberLabel.textColor = .neutral11
//        numberLabel.font = FontSet.pretendardBold(size: 16)
        guideLabel.textColor = .neutral6
        guideLabel.font = FontSet.pretendardSemiBold(size: 12)
        descriptionLabel.textColor = .neutral11
        descriptionLabel.font = FontSet.pretendardMedium(size: 12)
    }
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        self.layer.masksToBounds = false
    }
}
