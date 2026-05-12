//
//  BottomPlacedButton.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import UIKit

/// 상태 변화를 감지하는 UIButton
final class BottomPlacedButton: UIButton {
    
    // MARK: - Init
    private let backColor: UIColor
    
    init(frame: CGRect = .zero, isSelected: Bool = false, backColor: UIColor = .primary500) {
        self.backColor = backColor
        super.init(frame: frame)
        setupUI()
        setupButtonStatus(isSelected: isSelected) 
    }
    
    required init?(coder: NSCoder) {
        self.backColor = .primary500
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        self.layer.cornerRadius = 8
        self.titleLabel?.font = FontSet.pretendardBold(size: 14)
        self.setTitleColor(ColorSet.neutral6, for: .normal)
        self.setTitleColor(ColorSet.neutral11, for: .selected)
        self.backgroundColor = ColorSet.neutral3
    }
    
    // MARK: - 버튼 상태 설정
    func setupButtonStatus(isSelected: Bool) {
        self.isSelected = isSelected
        self.backgroundColor = isSelected ? backColor : ColorSet.neutral3
        self.isEnabled = isSelected
    }
}
