//
//  UIImageView+.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Kingfisher
import UIKit

extension UIImageView {
    func loadImage(url: String) {
        guard let url = URL(string: url) else { return }
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage      
            ]
        )
    }
}
