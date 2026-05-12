//
//  TrainTableView.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Combine
import UIKit

final class TrainTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, GetWalkerTrainListDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetWalkerTrainListDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: TrainViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero, style: .plain)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    private func commonInit() {
        sectionHeaderTopPadding = 0
        register(TrainTableViewCell.self, forCellReuseIdentifier: TrainTableViewCell.identifier)
        delegate = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { tableView, _, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TrainTableViewCell.identifier
            ) as? TrainTableViewCell else {
                return UITableViewCell()
            }
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
            cell.contentView.backgroundColor = .clear
            cell.configure(item: item)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.trainList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$trainList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension TrainTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel.selectedKey = item.key
    }
}
