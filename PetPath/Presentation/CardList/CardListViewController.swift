//
//  CardListViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit


final class CardListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CardListViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let cardListCollectionView: CardCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        let collectionView = CardCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let nonCardView = NonItemView(message: "펫패스에 등록된 결제수단이 없어요", buttonText: "결제수단 등록하기")
    
    private let addButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("추가하기", for: .normal)
        $0.isHidden = true
    }
    
    private let deleteCardCheckModalViewController = ActionCheckModalViewController(message: "해당 카드를 삭제하시겠어요?")
    
    init(viewModel: CardListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "내 결제수단"
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
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getCardList()
        setNavigationTitle("내 결제수단")
    }
    
    // MARK: - Bind
    // TODO: 이거 마지막 카드 되는지 테스트해보기. 모달 잘뜨는지
    private func bind() {
        deleteCardCheckModalViewController.processPublisher.sink { [weak self] id in
            guard let id = id else { return }
            self?.viewModel.deleteCard(id: id)
        }.store(in: &subscriptions)
        viewModel.lastCardFailPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            let viewController = LastCardDeleteFailModalViewController()
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            self?.present(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$cardList.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] cardList in
                self?.cardListCollectionView.setcardList(item: cardList)
                self?.nonCardView.isHidden = !cardList.isEmpty
                self?.cardListCollectionView.isHidden = cardList.isEmpty
                self?.addButton.isHidden = cardList.isEmpty
            }.store(in: &subscriptions)
        
        cardListCollectionView.deletePublisher.sink { [weak self] cardId in
            guard let self = self else { return }
            deleteCardCheckModalViewController.setActionId(id: cardId)
            present(deleteCardCheckModalViewController, animated: true)
        }.store(in: &subscriptions)
        
        nonCardView.registPublisher.sink { [weak self] in
            let viewController = AddCardViewController(viewModel: AddCardViewModel())
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension CardListViewController {
    @objc private func addButtonTapped() {
        let viewController = AddCardViewController(viewModel: AddCardViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension CardListViewController {
    
    private func setupLayOuts() {
        [cardListCollectionView, nonCardView, addButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        cardListCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(addButton.snp.top)
        }
        nonCardView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(241)
            $0.height.equalTo(88)
        }
        addButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
