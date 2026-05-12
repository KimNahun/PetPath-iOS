//
//  RegisteredDogCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class RegisteredDogCollectionView: UICollectionView {

    // MARK: - Types
    private struct SelectableDog: Hashable {
        let dog: DogData
        let isSelected: Bool
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SelectableDog>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SelectableDog>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private var items: [SelectableDog] = []
    let dogIdPublisher = PassthroughSubject<Int, Never>()
    private var diffableDataSource: DataSource?

    override var intrinsicContentSize: CGSize {
        let height = calculateDynamicHeight()
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

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
        register(RegisteredDogCollectionViewCell.self, forCellWithReuseIdentifier: RegisteredDogCollectionViewCell.identifier)
        delegate = self
        layer.masksToBounds = false
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RegisteredDogCollectionViewCell.identifier,
                for: indexPath
            ) as? RegisteredDogCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(data: item.dog, selected: item.isSelected)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    func setDogList(item: [DogData]) {
        items = item.map { SelectableDog(dog: $0, isSelected: false) }
        applySnapshot()
    }

    func changeSelected(index: Int, selected: Bool) {
        guard index < items.count else { return }
        items[index] = SelectableDog(dog: items[index].dog, isSelected: selected)
        applySnapshot()
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension RegisteredDogCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 159)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        dogIdPublisher.send(item.dog.did)
    }
}
