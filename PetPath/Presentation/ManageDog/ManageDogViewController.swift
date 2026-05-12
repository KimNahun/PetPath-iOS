//
//  ManageDogViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//


import Combine
import UIKit

final class ManageDogViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ManageDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    init(viewModel: ManageDogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let registeredDogCollectionView: RegisteredDogCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        let collectionView = RegisteredDogCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let emptyWhiteView = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    private let noDogView = NonItemView(message: "펫패스에 등록된 강아지가 없어요", buttonText: "강아지 등록하기")
    
    private let addButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("추가하기", for: .normal)
        $0.isHidden = true
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
        viewModel.getMyDogList()
        setNavigationTitle("내 강아지")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$dogList.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] dogList in
                self?.noDogView.isHidden = !dogList.isEmpty
                self?.emptyWhiteView.isHidden = dogList.isEmpty
                self?.registeredDogCollectionView.isHidden = dogList.isEmpty
                self?.addButton.isHidden = dogList.isEmpty
                self?.registeredDogCollectionView.setDogList(item: dogList)
            }.store(in: &subscriptions)
        
        registeredDogCollectionView.dogIdPublisher.sink { [weak self] dogId in
            let viewController = DogDetailViewController(viewModel: DogDetailViewModel(dogId: dogId))
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        noDogView.registPublisher.sink { [weak self] item in
            let viewController = RegistNumberViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension ManageDogViewController {
    @objc private func addButtonTapped() {
        let viewController = RegistNumberViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    
}

extension ManageDogViewController {
    
    private func setupLayOuts() {
        [registeredDogCollectionView, emptyWhiteView, noDogView, addButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        registeredDogCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(addButton.snp.top).offset(-10)
        }
        addButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        noDogView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(225)
            $0.height.equalTo(88)
        }
        emptyWhiteView.snp.makeConstraints {
            $0.top.equalTo(registeredDogCollectionView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
        view.clipsToBounds = true
    }
}
