//
//  UIView+.swift
//  PetPath
//
//  Created by 김나훈 on 3/26/25.
//

import UIKit

extension UIView {
    func setupShadow() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        self.backgroundColor = .neutral4
        self.layer.cornerRadius = 15
    }
}
