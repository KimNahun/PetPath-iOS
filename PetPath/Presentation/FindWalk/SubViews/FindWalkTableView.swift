//
//  FindWalkTableView.swift
//  PetPath
//
//  Created by 김나훈 on 3/27/25.
//

import Combine
import UIKit

// ???: 이쪽 api 2번씩 호출되는것같다.
final class FindWalkTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, GetWalkRequestListDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetWalkRequestListDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: FindWalkViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()
    let walkIdPublisher = PassthroughSubject<Int, Never>()

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
        register(FindWalkTableViewCell.self, forCellReuseIdentifier: FindWalkTableViewCell.identifier)
        delegate = self
        separatorColor = .neutral5
        tableHeaderView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 10))
            view.backgroundColor = .white
            return view
        }()
        contentInset = .zero
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { tableView, _, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FindWalkTableViewCell.identifier
            ) as? FindWalkTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.getWalkRequestListResponse, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$getWalkRequestListResponse
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension FindWalkTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        walkIdPublisher.send(item.pk)
    }
}
