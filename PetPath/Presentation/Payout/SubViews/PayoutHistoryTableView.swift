//
//  PayoutHistoryTableView.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class PayoutHistoryTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, GetPayoutHistoryDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetPayoutHistoryDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    private let viewModel: PayoutViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: PayoutViewModel) {
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
        register(PayoutHistoryTableViewCell.self, forCellReuseIdentifier: PayoutHistoryTableViewCell.identifier)
        delegate = self
        separatorStyle = .none
        layer.masksToBounds = false
        showsVerticalScrollIndicator = false
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { tableView, _, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PayoutHistoryTableViewCell.identifier
            ) as? PayoutHistoryTableViewCell else {
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
        snapshot.appendItems(viewModel.payoutHistoryList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$payoutHistoryList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension PayoutHistoryTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        cellTapPublisher.send(item.pk)
    }
}
