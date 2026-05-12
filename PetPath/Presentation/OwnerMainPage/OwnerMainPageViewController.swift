//
//  OwnerMainPageViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//


import Combine
import UIKit

final class OwnerMainPageViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: MainPageViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.clipsToBounds = false
    }
    
    private let contentView = UIView().then {
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
    
    private let requestWalkButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("산책 요청하기", for: .normal)
    }
    private let myDogLabel = UILabel().then {
        $0.setTitle(text: "내 강아지")
    }
    private let manageDogButton = UIButton().then {
        $0.setTitle("강아지 관리", for: .normal)
        $0.setTitleColor(.secondary400, for: .normal)
        $0.titleLabel?.font = FontSet.pretendardSemiBold(size: 12)
    }
    private let noDogView = AspectFitImageView().then {
        $0.image = UIImage(named: "noDogView")
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }
    private let myDogCollectionView: MyDogCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        let collectionView = MyDogCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let mainPageFooterView = MainPageFooterView()
    
    private let mainPageFooterButtonView = MainPageFooterButtonView()
    
    private let ownerRequireView = OwnerRequireView().then {
        $0.isHidden = true
    }
    
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
        manageDogButton.addTarget(self, action: #selector(manageDogButtonTapped), for: .touchUpInside)
        requestWalkButton.addTarget(self, action: #selector(requestWalkButtonTapped), for: .touchUpInside)
        viewModel.getMainNotice(type: .owner)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(noDogViewTapped))
        noDogView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserInfo()
        viewModel.getMyDogList()
        viewModel.getCurrentWalks()
        viewModel.getCardList()
        setNavigationTitle(imageName: "mainPageLogo")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$userType.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] type in
            if type == .walker {
                self?.navigationController?.setViewControllers([WalkerMainPageViewController(viewModel: .init())], animated: false)
            }
        }.store(in: &subscriptions)
        
        ownerRequireView.cardTapPublisher.sink { [weak self] in
            self?.navigationController?.pushViewController(CardListViewController(viewModel: .init()), animated: true)
        }.store(in: &subscriptions)
        
        ownerRequireView.dogTapPublisher.sink { [weak self] in
            self?.navigationController?.pushViewController(RegistNumberViewController(), animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$ownerRequireList.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let cardSuccess = response.cardSuccess, let dogSuccess = response.dogSuccess, let self = self else { return }
            ownerRequireView.setup(dogSuccess: dogSuccess, cardSuccess: cardSuccess)
            if cardSuccess && dogSuccess {
                ownerRequireView.isHidden = true
                walkLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.noticeCollectionView.snp.bottom).offset(12)
                    $0.horizontalEdges.equalToSuperview().inset(16)
                    $0.width.equalTo(self.noticeCollectionView.snp.width)
                    $0.height.equalTo(17)
                }
            }
            else {
                ownerRequireView.isHidden = false
                ownerRequireView.snp.remakeConstraints {
                    $0.top.equalTo(self.noticeCollectionView.snp.bottom).offset(12)
                    $0.horizontalEdges.equalToSuperview().inset(16)
                    $0.width.equalTo(self.noticeCollectionView.snp.width)
                }
                walkLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.ownerRequireView.snp.bottom).offset(12)
                    $0.horizontalEdges.equalToSuperview().inset(16)
                    $0.height.equalTo(17)
                }
            }
        }.store(in: &subscriptions)
        
        currentWalkCollectionView.currentWalkTabPublisher.sink { [weak self] id in
            self?.navigationController?.pushViewController(OwnerWalkDetailViewController(viewModel: .init(id: id)), animated: true)
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
                self.requestWalkButton.snp.remakeConstraints {
                    let topAnchorView = walks.isEmpty ? self.progressingWalkLabel : self.currentWalkCollectionView
                    $0.top.equalTo(topAnchorView.snp.bottom).offset(16)
                    $0.horizontalEdges.equalToSuperview().inset(16)
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
        
        myDogCollectionView.selectDogPublisher.sink { [weak self] did in
            let viewController = DogDetailViewController(viewModel: DogDetailViewModel(dogId: did))
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        myDogCollectionView.addDogPublisher.sink { [weak self] did in
            let viewController = RegistNumberViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$dogList.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] dogList in
            guard let self = self else { return }
            myDogCollectionView.setDogList(item: dogList)
            myDogCollectionView.isHidden = dogList.isEmpty
            noDogView.isHidden = !dogList.isEmpty
            if dogList.isEmpty {
                mainPageFooterView.snp.remakeConstraints { [weak self] in
                    guard let self = self else { return }
                    $0.top.equalTo(noDogView.snp.bottom).offset(29)
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalTo(contentView.snp.bottom)
                }
            } else {
                mainPageFooterView.snp.remakeConstraints { [weak self] in
                    guard let self = self else { return }
                    $0.top.equalTo(myDogCollectionView.snp.bottom).offset(29)
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalTo(contentView.snp.bottom)
                }
            }
            if dogList.isEmpty { return }
            myDogCollectionView.snp.updateConstraints { [weak self] in
                guard let self = self else { return }
                $0.height.equalTo(myDogCollectionView.calculateDynamicHeight() + 100)
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

extension OwnerMainPageViewController {
    @objc private func noDogViewTapped() {
        let viewController = RegistNumberViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func requestWalkButtonTapped() {
        let viewController = SelectDogViewController(viewModel: RequestWalkViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func manageDogButtonTapped() {
        let viewController = ManageDogViewController(viewModel: ManageDogViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension OwnerMainPageViewController {
    
    private func setupLayOuts() {
        [scrollView, mainPageFooterButtonView].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        
        [noticeCollectionView, noticePageControl, walkLabel, progressingWalkLabel, currentWalkCollectionView, requestWalkButton, myDogLabel, manageDogButton, myDogCollectionView, noDogView, mainPageFooterView, ownerRequireView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(mainPageFooterButtonView.snp.top)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        noticeCollectionView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(223)
        }
        noticePageControl.snp.makeConstraints {
            $0.height.equalTo(6)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(noticeCollectionView).offset(-10)
        }
        ownerRequireView.snp.makeConstraints {
            $0.top.equalTo(noticeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        walkLabel.snp.makeConstraints {
            $0.top.equalTo(noticeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(17)
        }
        progressingWalkLabel.snp.makeConstraints {
            $0.top.equalTo(walkLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(46)
        }
        currentWalkCollectionView.snp.makeConstraints {
            $0.top.equalTo(walkLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }
        requestWalkButton.snp.makeConstraints {
            $0.top.equalTo(progressingWalkLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        myDogLabel.snp.makeConstraints {
            $0.top.equalTo(requestWalkButton.snp.bottom).offset(16)
            $0.leading.equalTo(noticeCollectionView)
            $0.height.equalTo(17)
        }
        manageDogButton.snp.makeConstraints {
            $0.centerY.equalTo(myDogLabel)
            $0.trailing.equalTo(requestWalkButton)
            $0.width.equalTo(60)
            $0.height.equalTo(14)
        }
        myDogCollectionView.snp.makeConstraints {
            $0.top.equalTo(manageDogButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        noDogView.snp.makeConstraints {
            $0.top.equalTo(manageDogButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(noDogView.snp.width).multipliedBy(0.5)
        }
        mainPageFooterView.snp.makeConstraints {
            $0.top.equalTo(myDogCollectionView.snp.bottom).offset(29)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.bottom)
        }
        mainPageFooterButtonView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56)
            $0.bottom.equalTo(view.snp.bottom)
        }
    }
    private func setupComponents() {
        progressingWalkLabel.textAlignment = .center
        progressingWalkLabel.textColor = .neutral8
        progressingWalkLabel.backgroundColor = .neutral3
        progressingWalkLabel.font = FontSet.pretendardMedium(size: 12)
        noDogView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        noDogView.layer.shadowOffset = CGSize(width: 0, height: 2)
        noDogView.layer.shadowRadius = 4
        noDogView.layer.shadowOpacity = 0.8
        noDogView.layer.masksToBounds = false
        noDogView.backgroundColor = .neutral4
        noDogView.layer.cornerRadius = 15
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
