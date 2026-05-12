//
//  UIViewController+NavigationBar.swift
//  PetPath
//
//  Created by 김나훈 on 3/20/25.
//

import UIKit

extension AppDelegate {
    
    func configureNavigationBar() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = nil

            // ✅ 타이틀 스타일 설정
            appearance.titleTextAttributes = [
                .foregroundColor: ColorSet.dark,
                .font: FontSet.pretendardSemiBold(size: 16)
            ]

            // ✅ 백 버튼 텍스트 제거 (타이틀 안 보이게)
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance

            // ✅ 사용자 정의 이미지로 뒤로가기 아이콘 설정
        if let backImage = UIImage(named: "chevronLeft")?.resize(to: CGSize(width: 24, height: 24)).withRenderingMode(UIImage.RenderingMode.alwaysOriginal) {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        }

            // ✅ 백 버튼 전체 색상
            UINavigationBar.appearance().tintColor = .gray

            // ✅ 전체 적용
            let navBar = UINavigationBar.appearance()
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance

            // ✅ leading 여백 조정 (전체 NavigationBar에 8pt 마진 주기)
            navBar.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
}
extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}
