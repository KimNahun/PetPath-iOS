//
//  RegisterNumberView.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import UIKit

final class RegisterNumberView: UIView {
    
    private let imageView = AspectFitImageView().then {
        $0.backgroundColor = .clear
    }
    private let textLabel = UILabel().then {
        $0.font = FontSet.pretendardBold(size: 16)
    }
    init(title: String, imageName: String) {
        super.init(frame: .zero)
        textLabel.text = title
        imageView.image = UIImage(named: imageName)
        setupUI()
        self.backgroundColor = .primary50
        self.layer.borderColor = ColorSet.neutral5.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        [imageView, textLabel].forEach {
            addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(48)
        }
        textLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
}
