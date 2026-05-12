//
//  CommonButton.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import UIKit.UIButton

final class CommonButton: UIButton {
    
    // MARK: - Init
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        self.layer.cornerRadius = 8
        self.titleLabel?.font = FontSet.pretendardBold(size: 14)
        self.setTitleColor(ColorSet.neutral1, for: .normal)
        self.backgroundColor = ColorSet.secondary300
    }
    
}
