//
//  UICollectionView+.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import UIKit

extension UICollectionView {
    func calculateDynamicHeight() -> CGFloat {
        self.layoutIfNeeded()
        return self.contentSize.height
    }
    func reloadWithFade(duration: TimeInterval = 0.3) {
        UIView.transition(with: self,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            self.reloadData()
        })
    }
    enum TagAlignment {
        case leading
        case center
    }
    static func createCompositionalLayout(spacing: CGFloat, alignment: TagAlignment) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(24)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(24)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = spacing

        switch alignment {
        case .leading:
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        case .center:
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        }

        return UICollectionViewCompositionalLayout(section: section)
    }
}
