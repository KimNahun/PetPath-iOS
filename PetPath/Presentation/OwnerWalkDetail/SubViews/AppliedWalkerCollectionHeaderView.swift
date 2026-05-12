//
//  AppliedWalkerCollectionHeaderView.swift
//  PetPath
//
//  Created by 김나훈 on 4/11/25.
//

import UIKit

final class AppliedWalkerCollectionHeaderView: UICollectionReusableView {

    private let titleLabel = UILabel().then {
        $0.text = "워커 지원"
        $0.font = FontSet.pretendardBold(size: 18)
        $0.textColor = .neutral11
    }

    let countLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 12)
        $0.textColor = .neutral11
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(countLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCount(_ count: Int) {
        countLabel.text = "\(count)개의 지원"
    }
}
