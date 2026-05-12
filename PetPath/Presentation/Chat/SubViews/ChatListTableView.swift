//
//  ChatListTableView.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class ChatListTableView: UITableView {

    // MARK: - Types
    private typealias DataSource = UITableViewDiffableDataSource<Section, GetChatRoomListDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetChatRoomListDTO>

    private enum Section: CaseIterable {
        case activeWalks
        case completedWalks
    }

    // MARK: - Properties
    let cellTapPublisher = PassthroughSubject<GetChatRoomListDTO, Never>()
    private let viewModel: ChatViewModel
    private var diffableDataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: ChatViewModel) {
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
        register(ChatListTableViewCell.self, forCellReuseIdentifier: ChatListTableViewCell.identifier)
        delegate = self
        separatorStyle = .singleLine
        separatorColor = .neutral7
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: self) { tableView, _, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatListTableViewCell.identifier
            ) as? ChatListTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.activeWalks, toSection: .activeWalks)
        snapshot.appendItems(viewModel.completedWalks, toSection: .completedWalks)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$completedWalks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate
extension ChatListTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let count = section == 0 ? viewModel.activeWalks.count : viewModel.completedWalks.count
        return count == 0 ? 0 : 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let count = section == 0 ? viewModel.activeWalks.count : viewModel.completedWalks.count
        guard count > 0 else { return nil }

        let label = UILabel()
        label.text = section == 0 ? "진행 중인 산책" : "완료된 산책"
        label.font = FontSet.pretendardBold(size: 16)
        label.textColor = .dark

        let container = UIView()
        container.backgroundColor = .white
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        return container
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        cellTapPublisher.send(item)
    }
}
