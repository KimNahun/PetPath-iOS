//
//  CurrentWalkCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 5/18/25.
//

import Combine
import UIKit

final class CurrentWalkCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, GetMainCurrentWalkListDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetMainCurrentWalkListDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    let currentWalkTabPublisher = PassthroughSubject<Int, Never>()
    private let viewModel: MainPageViewModel
    @Published var currentWalks: [GetMainCurrentWalkListDTO] = []
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: MainPageViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        delegate = self
        isScrollEnabled = false
        register(CurrentWalkCollectionViewCell.self, forCellWithReuseIdentifier: CurrentWalkCollectionViewCell.identifier)
        backgroundColor = .clear
        contentInset = .init(top: 0, left: 0, bottom: 8, right: 0)
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CurrentWalkCollectionViewCell.identifier,
                for: indexPath
            ) as? CurrentWalkCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: item)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(currentWalks, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        $currentWalks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension CurrentWalkCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 82)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        currentWalkTabPublisher.send(item.pk)
    }
}
