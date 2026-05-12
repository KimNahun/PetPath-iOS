//
//  AppliedWalkerCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 4/11/25.
//

import Combine
import UIKit

final class AppliedWalkerCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, GetApplyWalkerListDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetApplyWalkerListDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: OwnerWalkDetailViewModel
    let reloadPublisher = PassthroughSubject<Void, Never>()
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(AppliedWalkerCollectionViewCell.self, forCellWithReuseIdentifier: AppliedWalkerCollectionViewCell.identifier)
        register(AppliedWalkerCollectionHeaderView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: AppliedWalkerCollectionHeaderView.identifier)
        register(AppliedWalkerCollectionFooterView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: AppliedWalkerCollectionFooterView.identifier)
        delegate = self
        layer.masksToBounds = false
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { [weak self] collectionView, indexPath, item in
            guard let self,
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AppliedWalkerCollectionViewCell.identifier,
                    for: indexPath
                  ) as? AppliedWalkerCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item: item)
            cell.selectButtonPublisher.sink { [weak self] in
                self?.viewModel.showingWalker = item
            }.store(in: &cell.subscriptions)
            return cell
        }

        diffableDataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return UICollectionReusableView() }
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: AppliedWalkerCollectionHeaderView.identifier,
                    for: indexPath
                ) as? AppliedWalkerCollectionHeaderView else {
                    return UICollectionReusableView()
                }
                header.updateCount(self.viewModel.appliedWalkerList.count)
                return header
            } else if kind == UICollectionView.elementKindSectionFooter {
                guard let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: AppliedWalkerCollectionFooterView.identifier,
                    for: indexPath
                ) as? AppliedWalkerCollectionFooterView else {
                    return UICollectionReusableView()
                }
                return footer
            }
            return UICollectionReusableView()
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.appliedWalkerList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$appliedWalkerList
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
                self?.reloadPublisher.send()
            }.store(in: &subscriptions)
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension AppliedWalkerCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 23)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 16
        let width = collectionView.frame.width - horizontalInset * 2
        let estimatedHeight: CGFloat = 1000
        let dummyCell = AppliedWalkerCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(item: viewModel.appliedWalkerList[indexPath.row])
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: estimatedSize.height)
    }
}
