//
//  UINavigationController+.swift
//  PetPath
//
//  Created by 김나훈 on 3/4/25.
//

import UIKit

extension UINavigationController {
    /// 특정 ViewController로 이동 (없으면 새로 생성, 생성 시 의존성 주입 가능)
    func popToViewControllerOrReplace<T: UIViewController>(ofType type: T.Type, createNew: () -> T) {
        if let targetVC = viewControllers.first(where: { $0 is T }) {
            popToViewController(targetVC, animated: true)
        } else {
            let newVC = createNew()
            setViewControllers([newVC], animated: true)
        }
    }
}
