//
//  UILabel+.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import UIKit.UILabel

extension UILabel {
    // 자주 쓰이는 linespacing이 있는 title
    func setTitleBold(text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontSet.pretendardBold(size: 24),
            .kern: 0.5,
            .paragraphStyle: paragraphStyle
        ]
        self.textColor = ColorSet.dark
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    func setTitle(text: String) {
        self.text = text
        self.font = FontSet.pretendardBold(size: 14)
        self.textColor = ColorSet.dark
    }
    // 이미 문구가 지정된 라벨에 특정 텍스트만 해당 색으로 바꾸는 함수
    func setColor(for substring: String, to color: UIColor) {
        // 현재 라벨에 적용된 attributedText가 없으면 종료
        guard let currentAttributedText = self.attributedText else { return }
        
        // NSMutableAttributedString으로 변환하여 속성 수정 가능하도록 만듦
        let mutableAttributed = NSMutableAttributedString(attributedString: currentAttributedText)
        
        // 찾고자 하는 문자열(substring)의 range를 찾음
        let fullText = currentAttributedText.string as NSString
        let range = fullText.range(of: substring)
        
        // range가 존재할 경우에만 색상 속성 부여
        if range.location != NSNotFound {
            mutableAttributed.addAttribute(.foregroundColor, value: color, range: range)
        }
        
        // 수정된 AttributedString을 다시 라벨에 적용
        self.attributedText = mutableAttributed
    }
    
    func setBackgroundColor(with status: WalkStatus) {
        switch status {
        case .findWalker: self.backgroundColor = .secondary100
        case .tobeWalk: self.backgroundColor = ColorSet.fromHex("FAE1FA")
        case .walking: self.backgroundColor = .primary4
        case .endWalking: self.backgroundColor = ColorSet.fromHex("AFF4C6")
        case .ownerCancel, .ownerNoShow, .walkerCancel, .walkerNoShow: self.backgroundColor = ColorSet.fromHex("D9D9D9")
        case .walkerNotMatch: self.backgroundColor = ColorSet.fromHex("D9D9D9")
        case .unknown: self.backgroundColor = .white
        }
    }
}
