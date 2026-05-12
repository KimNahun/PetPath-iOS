//
//  CardCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class CardCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, CardData>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CardData>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private(set) var cardList: [CardData] = []
    let deletePublisher = PassthroughSubject<String, Never>()
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
        isScrollEnabled = true
        contentInset = .zero
        register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
        delegate = self
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { [weak self] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardCollectionViewCell.identifier,
                for: indexPath
            ) as? CardCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: item)
            cell.deletePublisher.sink { [weak self] in
                self?.deletePublisher.send(item.cardId)
            }.store(in: &cell.cancellables)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    func setcardList(item: [CardData]) {
        cardList = item
        applySnapshot()
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension CardCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 103)
    }
}
