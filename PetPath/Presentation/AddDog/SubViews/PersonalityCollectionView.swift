//
//  PersonalityCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class PersonalityCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, KeywordTag>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, KeywordTag>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private(set) var personalityList: [KeywordTag] = []
    let personalityPublisher = PassthroughSubject<Int, Never>()
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
        register(PersonalityCollectionViewCell.self, forCellWithReuseIdentifier: PersonalityCollectionViewCell.identifier)
        delegate = self
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PersonalityCollectionViewCell.identifier,
                for: indexPath
            ) as? PersonalityCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: item)
            return cell
        }
    }

    private func applySnapshot(animating: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(personalityList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: animating)
    }

    func setKeywordList(item: [KeywordTag]) {
        personalityList = item
        applySnapshot()
    }

    func setSelectedKeyword(item: [String]) {
        personalityList = personalityList.map { tag in
            var updatedTag = tag
            updatedTag.isSelected = item.contains(tag.name)
            return updatedTag
        }
        applySnapshot(animating: false)
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension PersonalityCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let dummyCell = PersonalityCollectionViewCell()
        dummyCell.configure(item: personalityList[indexPath.row])
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return dummyCell.contentView.systemLayoutSizeFitting(targetSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        personalityPublisher.send(indexPath.row)
    }
}
