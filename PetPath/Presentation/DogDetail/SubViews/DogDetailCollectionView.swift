//
//  DogDetailCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import UIKit

// TODO: 컬렉션뷰 살짝 그림자 있으면 짤림.
final class DogDetailCollectionView: UICollectionView {

    // MARK: - Types
    struct DogDetailItem: Hashable {
        let text: String
        let color: UIColor

        static func == (lhs: DogDetailItem, rhs: DogDetailItem) -> Bool {
            lhs.text == rhs.text && lhs.color == rhs.color
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(text)
        }
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DogDetailItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DogDetailItem>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private(set) var infoList: [DogDetailItem] = []
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
        register(DogDetailCollectionViewCell.self, forCellWithReuseIdentifier: DogDetailCollectionViewCell.identifier)
        delegate = self
        isScrollEnabled = false
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DogDetailCollectionViewCell.identifier,
                for: indexPath
            ) as? DogDetailCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: (text: item.text, color: item.color))
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(infoList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    func setKeywordList(item: [(text: String, color: UIColor)]) {
        infoList = item.map { DogDetailItem(text: $0.text, color: $0.color) }
        applySnapshot()
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension DogDetailCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let dummyCell = DogDetailCollectionViewCell()
        dummyCell.configure(item: (text: infoList[indexPath.row].text, color: infoList[indexPath.row].color))
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return dummyCell.contentView.systemLayoutSizeFitting(targetSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        personalityPublisher.send(indexPath.row)
    }
}
