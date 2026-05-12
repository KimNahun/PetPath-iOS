//
//  AddInfoCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import UIKit

final class AddInfoCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, KeywordTag>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, KeywordTag>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private(set) var requireList: [KeywordTag] = []
    let requirePublisher = PassthroughSubject<Int, Never>()
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
        register(AddInfoCollectionViewCell.self, forCellWithReuseIdentifier: AddInfoCollectionViewCell.identifier)
        delegate = self
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddInfoCollectionViewCell.identifier,
                for: indexPath
            ) as? AddInfoCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: item)
            return cell
        }
    }

    private func applySnapshot(animating: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(requireList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: animating)
    }

    func setKeywordList(item: [KeywordTag]) {
        requireList = item
        applySnapshot()
    }

    func setSelectedKeyword(item: [String]) {
        requireList = requireList.map { tag in
            var updatedTag = tag
            updatedTag.isSelected = item.contains(tag.name)
            return updatedTag
        }
        applySnapshot(animating: false)
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension AddInfoCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let dummyCell = AddInfoCollectionViewCell()
        dummyCell.configure(item: requireList[indexPath.row])
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return dummyCell.contentView.systemLayoutSizeFitting(targetSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        requirePublisher.send(indexPath.row)
    }
}
