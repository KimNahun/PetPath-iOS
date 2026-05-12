//
//  Component+Identifier.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import UIKit


extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}
extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
extension UITableViewHeaderFooterView {
    static var identifier: String {
        return String(describing: self)
    }
}
