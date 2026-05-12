//
//  AspectFitImageView.swift
//  PetPath
//
//  Created by 김나훈 on 7/7/25.
//

import UIKit

final class AspectFitImageView: UIImageView {

    // 기본 생성자 추가
    convenience init() {
        self.init(frame: .zero)
        configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
