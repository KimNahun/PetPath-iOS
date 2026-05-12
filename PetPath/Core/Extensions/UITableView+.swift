//
//  UITableView+.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import UIKit

extension UITableView {
    func reloadWithFade(duration: TimeInterval = 0.3) {
        UIView.transition(with: self,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            self.reloadData()
        })
    }
    func calculateDynamicHeight() -> CGFloat {
            self.layoutIfNeeded()
            let contentHeight = self.contentSize.height
            let headerHeight: CGFloat = self.delegate?.tableView?(self, heightForHeaderInSection: 0) ?? 0
            return contentHeight + headerHeight
        }
}
