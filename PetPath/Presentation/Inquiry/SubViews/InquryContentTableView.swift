//
//  InquryContentTableView.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import Combine
import UIKit

final class InquryContentTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, FAQItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FAQItem>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: InquiryViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: InquiryViewModel) {
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
        isScrollEnabled = false
        sectionHeaderTopPadding = 0
        register(InquryContentTableViewCell.self, forCellReuseIdentifier: InquryContentTableViewCell.identifier)
        delegate = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { [weak self] tableView, _, item in
            guard let self,
                  let cell = tableView.dequeueReusableCell(
                    withIdentifier: InquryContentTableViewCell.identifier
                  ) as? InquryContentTableViewCell else {
                return UITableViewCell()
            }
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
            cell.contentView.backgroundColor = .clear
            let isSelected = self.viewModel.selectedItem == item
            cell.configure(text: item.question, isSelected: isSelected, answer: item.answer)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot(animating: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.selectedSection?.items ?? [], toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: animating)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$selectedSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.selectedItem = nil
                self?.applySnapshot(animating: false)
            }.store(in: &subscriptions)

        viewModel.$selectedItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension InquryContentTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel.selectedItem = item
    }
}
