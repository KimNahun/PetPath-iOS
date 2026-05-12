//
//  NoticeCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 4/22/25.
//

import UIKit

final class NoticeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let imageView = AspectFitImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(_ item: GetMainNoticeDTO) {
        imageView.loadImage(url: item.image)
    }
    
}

extension NoticeCollectionViewCell {
    private func setUpLayouts() {
        [imageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }


    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

