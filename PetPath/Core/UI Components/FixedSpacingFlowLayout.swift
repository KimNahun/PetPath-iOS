//
//  FixedSpacingFlowLayout.swift
//  PetPath
//
//  Created by 김나훈 on 6/20/25.
//

import UIKit

final class FixedSpacingFlowLayout: UICollectionViewFlowLayout {

    let fixedSpacing: CGFloat

    init(spacing: CGFloat) {
        self.fixedSpacing = spacing
        super.init()
        self.minimumLineSpacing = spacing
        self.minimumInteritemSpacing = spacing
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        let attributesCopy = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        for attr in attributesCopy {
            if attr.representedElementCategory == .cell {
                if attr.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }

                attr.frame.origin.x = leftMargin
                leftMargin += attr.frame.width + fixedSpacing
                maxY = max(maxY, attr.frame.maxY)
            }
        }

        return attributesCopy
    }
}
