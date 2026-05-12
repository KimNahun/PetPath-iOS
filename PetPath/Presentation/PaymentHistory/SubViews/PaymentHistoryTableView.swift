//
//  PaymentHistoryTableView.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Combine
import UIKit

final class PaymentHistoryTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, PaymentHistoryData>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PaymentHistoryData>

    private enum Section {
        case main
    }

    // MARK: - Properties
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    private let viewModel: PaymentHistoryViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()
    private var isLoading = false

    // MARK: - Init
    init(viewModel: PaymentHistoryViewModel) {
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
        register(PaymentHistoryTableViewCell.self, forCellReuseIdentifier: PaymentHistoryTableViewCell.identifier)
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
                withIdentifier: PaymentHistoryTableViewCell.identifier
            ) as? PaymentHistoryTableViewCell else {
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
        snapshot.appendItems(viewModel.paymentHistoryList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$paymentHistoryList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
                self?.isLoading = false
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension PaymentHistoryTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoading else { return }
        let totalCount = viewModel.paymentHistoryList.count
        if indexPath.row >= totalCount - 3 {
            isLoading = true
            viewModel.getPaymentHistoryList(isReset: false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath),
              let walkId = item.walk else { return }
        cellTapPublisher.send(walkId)
    }
}
