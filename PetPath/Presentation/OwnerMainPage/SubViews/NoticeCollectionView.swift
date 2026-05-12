//
//  NoticeCollectionView.swift
//  PetPath
//
//  Created by 김나훈 on 4/22/25.
//

import Combine
import UIKit

final class NoticeCollectionView: UICollectionView {

    // MARK: - Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, GetMainNoticeDTO>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GetMainNoticeDTO>

    private enum Section {
        case main
    }

    // MARK: - Properties
    let scrollPublisher = PassthroughSubject<(Int, Int), Never>()
    let tapPublisher = PassthroughSubject<GetMainNoticeDTO, Never>()

    private var timer: Timer?
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: MainPageViewModel
    private var diffableDataSource: DataSource?

    private var currentIdx = 0

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: MainPageViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        register(NoticeCollectionViewCell.self, forCellWithReuseIdentifier: NoticeCollectionViewCell.identifier)
        delegate = self
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
        isPagingEnabled = true
        layer.masksToBounds = true
        layer.cornerRadius = 10
        setupDataSource()
        bind()
    }

    private func setupDataSource() {
        diffableDataSource = DataSource(collectionView: self) { [weak self] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NoticeCollectionViewCell.identifier,
                for: indexPath
            ) as? NoticeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(item)
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.noticeList, toSection: .main)
        diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Combine Binding
    private func bind() {
        viewModel.$noticeList
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.applySnapshot()
                self?.startAutoScroll()
            }.store(in: &subscriptions)
    }
}

// MARK: - UICollectionViewDelegate + DelegateFlowLayout
extension NoticeCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        tapPublisher.send(item)
    }
}

// MARK: - Auto Scroll Logic
extension NoticeCollectionView {

    func startAutoScroll() {
        stopAutoScroll()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }

    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func scrollToNextItem() {
        guard !viewModel.noticeList.isEmpty else { return }
        let nextIdx = (currentIdx + 1) % viewModel.noticeList.count
        isPagingEnabled = false
        scrollToItem(at: IndexPath(item: nextIdx, section: 0), at: .centeredHorizontally, animated: true)
        isPagingEnabled = true
        currentIdx = nextIdx
        scrollPublisher.send((nextIdx, viewModel.noticeList.count))
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { resetAutoScrollTimer() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetAutoScrollTimer()
        let visibleIndex = Int(round(scrollView.contentOffset.x / bounds.width))
        currentIdx = visibleIndex
        scrollPublisher.send((visibleIndex, viewModel.noticeList.count))
    }

    private func resetAutoScrollTimer() {
        stopAutoScroll()
        startAutoScroll()
    }
}
