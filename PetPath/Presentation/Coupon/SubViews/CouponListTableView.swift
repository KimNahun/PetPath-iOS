//
//  CouponListTableView.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class CouponListTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, GetCouponListDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetCouponListDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: CouponViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: CouponViewModel) {
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
        register(CouponListTableViewCell.self, forCellReuseIdentifier: CouponListTableViewCell.identifier)
        delegate = self
        contentInset = .init(top: 0, left: 0, bottom: 8, right: 0)
        separatorStyle = .none
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { [weak self] tableView, _, item in
            guard let self,
                  let cell = tableView.dequeueReusableCell(
                    withIdentifier: CouponListTableViewCell.identifier
                  ) as? CouponListTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(item: item, type: self.viewModel.fetchType)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.couponList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$couponList
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension CouponListTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
