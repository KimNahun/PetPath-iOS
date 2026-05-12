//
//  WalkerMainPageViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Combine
import UIKit

final class WalkerMainPageViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: MainPageViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.clipsToBounds = false
    }
    
    private lazy var noticeCollectionView: NoticeCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let collectionView = NoticeCollectionView(frame: .zero, collectionViewLayout: flowLayout, viewModel: viewModel)
        return collectionView
    }()
    
    private let walkerRequireView = WalkerRequireView().then {
        $0.isHidden = true
    }
    
    private let noticePageControl = UIPageControl(frame: .zero).then {
        $0.currentPageIndicatorTintColor = ColorSet.fromHex("D8C047")
        $0.pageIndicatorTintColor = ColorSet.fromHex("E5E1E1")
        $0.currentPage = 0
    }
    
    private let walkLabel = UILabel().then {
        $0.setTitle(text: "현재 진행 중인 산책")
    }
    private let progressingWalkLabel = UILabel().then {
        $0.text = "진행중인 산책이 없습니다"
    }
    
    private lazy var currentWalkCollectionView: CurrentWalkCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        let collectionView = CurrentWalkCollectionView(frame: .zero, collectionViewLayout: flowLayout, viewModel: viewModel)
        return collectionView
    }()
    
    private let showWalkButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("주변 산책요청 보기", for: .normal)
    }
    private let paymentLabel = UILabel().then {
        $0.setTitle(text: "정산 현황")
    }
    private let paymentView = UIView().then {
        $0.clipsToBounds = false
    }
    private let paymentPossibleLabel = UILabel().then {
        $0.setTitle(text: "현재 정산 가능 금액")
    }
    private let paymentMoneyLabel = UILabel().then { _ in
    }
    private let paymentStandardLabel = UILabel().then {
        $0.text = "정산 기준액: 30,000원"
    }
    private let paymentPercentLabel = UILabel().then { _ in
    }
    private let progressView = UIProgressView().then { _ in
    }
    private let payoutButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("정산하기", for: .normal)
    }
    private let newWalkPushModalViewController = NewWalkPushModalViewController()
    
    private let mainPageFooterView = MainPageFooterView()
    
    private let mainPageFooterButtonView = MainPageFooterButtonView()
    
    init(viewModel: MainPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        showWalkButton.addTarget(self, action: #selector(showWalkButtonTapped), for: .touchUpInside)
        payoutButton.addTarget(self, action: #selector(payoutButtonTapped), for: .touchUpInside)
        viewModel.getMainNotice(type: .walker)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserInfo()
        viewModel.getAvailablePayoutAmount()
        viewModel.getCurrentWalks()
        viewModel.getCardList()
        viewModel.getTrainStatus()
        setNavigationTitle(imageName: "mainPageLogo")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.getPushSetting()
    }
    
    // MARK: - Bind
    
    private func bind() {
        
        newWalkPushModalViewController.moveButtonPublisher.sink { [weak self] in
            self?.navigationController?.pushViewController(WalkerPushViewController(viewModel: .init()), animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$isNewWalk.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isNewWalk in
            guard let self = self else { return }
            if isNewWalk == true { return }
            let showModal = !UserDefaultManager.shared.read(.walkPushModal)
            if showModal, presentedViewController == nil {
                present(newWalkPushModalViewController, animated: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.$userType.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] type in
            if type == .owner {
                self?.navigationController?.setViewControllers([OwnerMainPageViewController(viewModel: .init())], animated: false)
            }
        }.store(in: &subscriptions)
        
        walkerRequireView.trainTapPublisher.sink { [weak self] in
            self?.navigationController?.pushViewController(TrainListViewController(viewModel: .init()), animated: true)
        }.store(in: &subscriptions)
        
        walkerRequireView.newWalkTapPublisher.sink { [weak self] in
            self?.navigationController?.pushViewController(WalkerPushViewController(viewModel: .init()), animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$walkerRequireList.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let trainSuccess = response.trainSuccess, let newWalkSuccess = response.newWalkSuccess, let self = self else { return }
            walkerRequireView.setup(trainSuccess: trainSuccess, newWalkSuccess: newWalkSuccess)
            if trainSuccess && newWalkSuccess {
                walkerRequireView.isHidden = true
                walkLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.noticeCollectionView.snp.bottom).offset(12)
                    $0.horizontalEdges.equalToSuperview()
                    $0.width.equalTo(self.scrollView.snp.width)
                    $0.height.equalTo(17)
                }
            }
            else {
                walkerRequireView.isHidden = false
                walkerRequireView.snp.remakeConstraints {
                    $0.top.equalTo(self.noticeCollectionView.snp.bottom).offset(12)
                    $0.horizontalEdges.equalToSuperview()
                    $0.width.equalTo(self.scrollView.snp.width)
                }
                walkLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.walkerRequireView.snp.bottom).offset(12)
                    $0.horizontalEdges.equalToSuperview()
                    $0.width.equalTo(self.scrollView.snp.width)
                    $0.height.equalTo(17)
                }
            }
        }.store(in: &subscriptions)
        
        currentWalkCollectionView.currentWalkTabPublisher.sink { [weak self] id in
            self?.navigationController?.pushViewController(WalkerWalkDetailViewController(viewModel: .init(id: id)), animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$currentWalks.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] walks in
            guard let self = self else { return }
            progressingWalkLabel.isHidden = !walks.isEmpty
            currentWalkCollectionView.isHidden = walks.isEmpty
            currentWalkCollectionView.currentWalks = walks
            DispatchQueue.main.async {
                self.currentWalkCollectionView.snp.updateConstraints {
                    $0.height.equalTo(self.currentWalkCollectionView.calculateDynamicHeight())
                }
                self.showWalkButton.snp.remakeConstraints {
                    let topAnchorView = walks.isEmpty ? self.progressingWalkLabel : self.currentWalkCollectionView
                    $0.top.equalTo(topAnchorView.snp.bottom).offset(16)
                    $0.horizontalEdges.equalToSuperview()
                    $0.height.equalTo(40)
                }
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }.store(in: &subscriptions)
        
        noticeCollectionView.tapPublisher
            .sink { item in
                switch item.linkType {
                case .web:
                    guard let urlString = item.url,
                          let url = URL(string: urlString),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)

                case .app:
                    guard let schema = item.appSchema else { return }
                    AppRouter.shared.setAccountAndNavigate(screen: schema.screen, id: schema.id, accountType: schema.accountType)
                default: return
                }
            }.store(in: &subscriptions)
        mainPageFooterButtonView.chatButtonPublisher.sink { [weak self] in
            let viewController = ChatListViewController(viewModel: ChatViewModel())
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        mainPageFooterButtonView.walkHistoryButtonPublisher.sink { [weak self] in
            let viewController = WalkHistoryViewController(viewModel: WalkHistoryViewModel())
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        mainPageFooterButtonView.settingButtonPublisher.sink { [weak self] in
            let viewController = SettingViewController(viewModel: SettingViewModel())
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$payoutAmount.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] amount in
            guard let self = self, let amount = amount else { return }
            paymentMoneyLabel.text = "\(amount.formattedWithComma)원"
            let percent = Float(amount) * 100 / 30000
            let flooredPercent = floor(percent * 10) / 10
            paymentPercentLabel.text = "\(flooredPercent)%"
            progressView.progress = Float(amount) / 30000
        }.store(in: &subscriptions)
        
        viewModel.$noticeList.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] list in
            self?.noticePageControl.numberOfPages = list.count
        }.store(in: &subscriptions)
        
        noticeCollectionView.scrollPublisher.sink { [weak self] item in
            self?.noticePageControl.currentPage = item.0
        }.store(in: &subscriptions)
        
        mainPageFooterView.agreementPublisher.sink {
            if let url = UrlManager.service.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
        
        mainPageFooterView.personalityInfoPublisher.sink {
            if let url = UrlManager.privacy.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
    }
}

extension WalkerMainPageViewController {
    @objc private func showWalkButtonTapped() {
        requestPermissionsIfNeeded([.location]) { [weak self] isPermit in
            guard let self = self else { return }
            if isPermit {
                let viewController = FindWalkViewController(viewModel: FindWalkViewModel())
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                present(PermissionBlockModalViewController(message: "지도에서 위치를 보기 위해서는 권한이 필요합니다.\n설정으로 이동해서 위치 권한을 활성화 해주세요."), animated: true)
            }
        }
    }
    @objc private func payoutButtonTapped() {
        let viewController = PayoutHistoryViewController(viewModel: PayoutViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension WalkerMainPageViewController {
    
    private func setupLayOuts() {
        [scrollView, mainPageFooterButtonView].forEach {
            view.addSubview($0)
        }
        
        [noticeCollectionView, noticePageControl, walkLabel, progressingWalkLabel, currentWalkCollectionView, showWalkButton, paymentLabel, paymentView, mainPageFooterView, walkerRequireView].forEach {
            scrollView.addSubview($0)
        }
        [paymentPossibleLabel, paymentMoneyLabel, paymentStandardLabel, paymentPercentLabel, progressView, payoutButton].forEach {
            paymentView.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(mainPageFooterButtonView.snp.top)
        }
        noticeCollectionView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(223)
        }
        noticePageControl.snp.makeConstraints {
            $0.height.equalTo(6)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(noticeCollectionView).offset(-10)
        }
        walkerRequireView.snp.makeConstraints {
            $0.top.equalTo(noticeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        walkLabel.snp.makeConstraints {
            $0.top.equalTo(noticeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(17)
        }
        progressingWalkLabel.snp.makeConstraints {
            $0.top.equalTo(walkLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(46)
        }
        currentWalkCollectionView.snp.makeConstraints {
            $0.top.equalTo(walkLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }
        showWalkButton.snp.makeConstraints {
            $0.top.equalTo(progressingWalkLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
        paymentLabel.snp.makeConstraints {
            $0.top.equalTo(showWalkButton.snp.bottom).offset(16)
            $0.leading.equalTo(noticeCollectionView)
            $0.height.equalTo(17)
        }
        paymentView.snp.makeConstraints {
            $0.top.equalTo(paymentLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(142)
        }
        mainPageFooterView.snp.makeConstraints {
            $0.top.equalTo(paymentView.snp.bottom).offset(29)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        mainPageFooterButtonView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56)
            $0.bottom.equalTo(view.snp.bottom)
        }
        paymentPossibleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        paymentMoneyLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(17)
        }
        paymentStandardLabel.snp.makeConstraints {
            $0.top.equalTo(paymentPossibleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        paymentPercentLabel.snp.makeConstraints {
            $0.top.equalTo(paymentPossibleLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(14)
        }
        progressView.snp.makeConstraints {
            $0.top.equalTo(paymentStandardLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(10)
        }
        payoutButton.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(33)
        }
    }
    private func setupComponents() {
        progressingWalkLabel.textAlignment = .center
        progressingWalkLabel.textColor = .neutral8
        progressingWalkLabel.backgroundColor = .neutral3
        progressingWalkLabel.font = FontSet.pretendardMedium(size: 12)
        
        [paymentPossibleLabel].forEach {
            $0.font = FontSet.pretendardBold(size: 14)
            $0.textColor = .dark
        }
        paymentMoneyLabel.font = FontSet.pretendardMedium(size: 14)
        paymentMoneyLabel.textColor = .dark
        [paymentStandardLabel, paymentPercentLabel].forEach {
            $0.font = FontSet.pretendardRegular(size: 14)
            $0.textColor = .dark
        }
        progressView.trackTintColor = .neutral6
        progressView.progressTintColor = .primary500
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        paymentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        paymentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        paymentView.layer.shadowRadius = 4
        paymentView.layer.shadowOpacity = 0.8
        paymentView.layer.masksToBounds = false
        paymentView.backgroundColor = .white
        paymentView.layer.cornerRadius = 16
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
