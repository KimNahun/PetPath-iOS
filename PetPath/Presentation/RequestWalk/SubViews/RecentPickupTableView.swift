//
//  RecentPickupTableView.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Combine
import UIKit

final class RecentPickupTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, GetRecentPickupPositionDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetRecentPickupPositionDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    private let viewModel: RequestWalkViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()
    let selectCellPublisher = PassthroughSubject<Void, Never>()

    // MARK: - Init
    init(viewModel: RequestWalkViewModel) {
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
        viewModel.getRecentPickupPosition()
        sectionHeaderTopPadding = 0
        register(RecentPickupCell.self, forCellReuseIdentifier: RecentPickupCell.identifier)
        delegate = self
        separatorInset = .zero
        separatorColor = .neutral5
        tableHeaderView = makeTableHeaderView()
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 60
        setupDataSource()
        bind()
    }

    private func makeTableHeaderView() -> UIView {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 27.5)
        let label = UILabel()
        label.text = "최근 픽업 위치"
        label.textColor = .dark
        label.font = FontSet.pretendardBold(size: 14)

        let separator = UIView()
        separator.backgroundColor = .neutral5

        headerView.addSubview(label)
        headerView.addSubview(separator)
        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }
        return headerView
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { tableView, _, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RecentPickupCell.identifier
            ) as? RecentPickupCell else {
                return UITableViewCell()
            }
            cell.configure(with: "\(item.pickupAddress) \(item.pickupDetail)")
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.recentPickupPositionList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$recentPickupPositionList
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension RecentPickupTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        let request = viewModel.finalRequest
        viewModel.finalRequest = RequestWalkRequest(
            dogs: request.dogs,
            startAt: request.startAt,
            endAt: request.endAt,
            requestPath: request.requestPath,
            address: item.pickupAddress,
            pickupX: item.pickupX,
            pickupY: item.pickupY,
            pickupDetail: item.pickupDetail,
            require: request.require
        )
        selectCellPublisher.send()
    }
}
