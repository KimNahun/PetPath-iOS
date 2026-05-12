//
//  WalkDogInfoCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/29/25.
//

import Combine
import UIKit

final class WalkDogInfoCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DogDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DogDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private(set) var dogList: [DogDTO] = []
    private var diffableDataSource: DataSource?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(WalkDogInfoCollectionViewCell.self, forCellWithReuseIdentifier: WalkDogInfoCollectionViewCell.identifier)
        delegate = self
        layer.masksToBounds = false
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WalkDogInfoCollectionViewCell.identifier,
                for: indexPath
            ) as? WalkDogInfoCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: item, index: indexPath.row)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(dogList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    func setDogList(item: [DogDTO]) {
        dogList = item
        applySnapshot()
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension WalkDogInfoCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let estimatedHeight: CGFloat = 1000
        let dummyCell = WalkDogInfoCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(item: dogList[indexPath.row], index: indexPath.row)
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: estimatedSize.height)
    }
}
