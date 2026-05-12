//
//  MyDogCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Combine
import UIKit

final class MyDogCollectionView: UICollectionView {

    // MARK: - Types
    private enum Item: Hashable {
        case dog(DogData)
        case addDog
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private enum Section {
        case main
    }

    // MARK: - Properties
    let selectDogPublisher = PassthroughSubject<Int, Never>()
    let addDogPublisher = PassthroughSubject<Void, Never>()
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
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(MyDogCollectionViewCell.self, forCellWithReuseIdentifier: MyDogCollectionViewCell.identifier)
        register(AddDogCell.self, forCellWithReuseIdentifier: AddDogCell.identifier)
        delegate = self
        clipsToBounds = false
        setupDataSource()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            switch item {
            case .dog(let data):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MyDogCollectionViewCell.identifier,
                    for: indexPath
                ) as? MyDogCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(data: data)
                return cell
            case .addDog:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AddDogCell.identifier,
                    for: indexPath
                ) as? AddDogCell else {
                    return UICollectionViewCell()
                }
                return cell
            }
        }
    }

    private func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    func setDogList(item: [DogData]) {
        var items = item.map { Item.dog($0) }
        if item.count == 1 { items.append(.addDog) }
        applySnapshot(items: items)
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension MyDogCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(UIScreen.main.bounds.width / 2 - 30), height: 164)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .dog(let data):
            selectDogPublisher.send(data.did)
        case .addDog:
            addDogPublisher.send()
        }
    }
}
