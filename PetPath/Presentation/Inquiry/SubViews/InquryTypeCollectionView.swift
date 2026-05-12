//
//  InquryTypeCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import Combine
import UIKit

final class InquryTypeCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, FAQSection>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FAQSection>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: InquiryViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions: Set<AnyCancellable> = []

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: InquiryViewModel) {
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
        register(InquryTypeCollectionViewCell.self, forCellWithReuseIdentifier: InquryTypeCollectionViewCell.identifier)
        delegate = self
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { [weak self] collectionView, indexPath, item in
            guard let self,
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: InquryTypeCollectionViewCell.identifier,
                    for: indexPath
                  ) as? InquryTypeCollectionViewCell else {
                return UICollectionViewCell()
            }
            let isSelected = self.viewModel.selectedSection?.title == item.title
            cell.configure(text: item.title, isSelected: isSelected)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.faqSections, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$selectedSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)

        applySnapshot()
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension InquryTypeCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let dummyCell = InquryTypeCollectionViewCell()
        dummyCell.configure(text: viewModel.faqSections[indexPath.row].title, isSelected: false)
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return dummyCell.contentView.systemLayoutSizeFitting(targetSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        if item == viewModel.selectedSection { return }
        viewModel.selectedSection = item
    }
}
