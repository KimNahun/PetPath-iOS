//
//  FontSet.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import UIKit.UIFont

enum FontSet {
    static func pretendardBlack(size: CGFloat) -> UIFont { UIFont.named("Pretendard-Black", size: size) }
    static func pretendardBold(size: CGFloat) -> UIFont { UIFont.named("Pretendard-Bold", size: size) }
    static func pretendardExtraBold(size: CGFloat) -> UIFont { UIFont.named("Pretendard-ExtraBold", size: size) }
    static func pretendardExtraLight(size: CGFloat) -> UIFont { UIFont.named("Pretendard-ExtraLight", size: size) }
    static func pretendardLight(size: CGFloat) -> UIFont { UIFont.named("Pretendard-Light", size: size) }
    static func pretendardMedium(size: CGFloat) -> UIFont { UIFont.named("Pretendard-Medium", size: size) }
    static func pretendardRegular(size: CGFloat) -> UIFont { UIFont.named("Pretendard-Regular", size: size) }
    static func pretendardSemiBold(size: CGFloat) -> UIFont { UIFont.named("Pretendard-SemiBold", size: size) }
    static func pretendardThin(size: CGFloat) -> UIFont { UIFont.named("Pretendard-Thin", size: size) }
}

extension UIFont {
    static func named(_ name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
