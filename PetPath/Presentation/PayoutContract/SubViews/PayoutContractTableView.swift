//
//  PayoutContractTableView.swift
//  PetPath
//
//  Created by 김나훈 on 5/3/25.
//

import Combine
import UIKit

final class PayoutContractTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, PayoutContractViewModel.PayoutItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PayoutContractViewModel.PayoutItem>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: PayoutContractViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: PayoutContractViewModel) {
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
        register(PayoutContractTableViewCell.self, forCellReuseIdentifier: PayoutContractTableViewCell.identifier)
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
                withIdentifier: PayoutContractTableViewCell.identifier
            ) as? PayoutContractTableViewCell else {
                return UITableViewCell()
            }
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
            cell.contentView.backgroundColor = .clear
            cell.configure(item: item, identify: item.message == "주민등록번호")
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.payoutInfoList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$payoutInfoList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension PayoutContractTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
