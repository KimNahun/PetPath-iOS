//
//  SourceTypeCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 8/1/25.
//

import Combine
import UIKit

final class SourceTypeCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SignupSourceType>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SignupSourceType>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let allSources: [SignupSourceType] = SignupSourceType.allCases
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        contentInset = .zero
        register(SourceTypeCollectionViewCell.self, forCellWithReuseIdentifier: SourceTypeCollectionViewCell.identifier)
        delegate = self
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { [weak self] collectionView, indexPath, item in
            guard let self,
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SourceTypeCollectionViewCell.identifier,
                    for: indexPath
                  ) as? SourceTypeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                text: item.rawValue,
                isSelected: self.viewModel.signupSource == item,
                message: item == .etc ? self.viewModel.signupDetail ?? "" : nil,
                isFocusing: self.viewModel.signupSource == .etc
            )
            cell.agreementPublisher.sink { [weak self] _ in
                guard let self else { return }
                if viewModel.signupSource == item {
                    viewModel.signupSource = nil
                } else {
                    viewModel.signupSource = item
                }
            }.store(in: &cell.subscriptions)
            cell.textPublisher.sink { [weak self] text in
                self?.viewModel.signupDetail = text
            }.store(in: &cell.subscriptions)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(allSources, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$signupSource
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)

        applySnapshot()
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension SourceTypeCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = allSources[indexPath.row]
        return CGSize(width: collectionView.frame.width, height: item == .etc ? 67 : 28)
    }
}
