//
//  AppliedWalkerCollectionFooterView.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import UIKit

final class AppliedWalkerCollectionFooterView: UICollectionReusableView {

    private let separatorView = UIView().then {
        $0.backgroundColor = .neutral3
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
