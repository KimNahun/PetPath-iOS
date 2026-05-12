//
//  SearchedResultTableView.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

// ???: 이쪽 api 2번씩 호출되는것같다.
final class SearchedResultTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, SearchAddressByKeywordDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchAddressByKeywordDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: FindWalkViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()
    let cellIndexPublisher = PassthroughSubject<Int, Never>()

    // MARK: - Init
    init(viewModel: FindWalkViewModel) {
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
        register(SearchedAddressCell.self, forCellReuseIdentifier: SearchedAddressCell.identifier)
        delegate = self
        separatorInset = .zero
        separatorColor = .neutral5
        tableHeaderView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
            view.backgroundColor = .neutral5
            return view
        }()
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { tableView, _, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchedAddressCell.identifier
            ) as? SearchedAddressCell else {
                return UITableViewCell()
            }
            cell.configure(title: item.roadAddress, sub: item.address)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.searchedResponse, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$searchedResponse
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension SearchedResultTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        viewModel.tappedResult = item
    }
}
