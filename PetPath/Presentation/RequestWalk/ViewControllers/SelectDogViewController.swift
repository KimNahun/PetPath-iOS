//
//  SelectDogViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Combine
import UIKit

final class SelectDogViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RequestWalkViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let messageLabel = UILabel().then {
        $0.setTitleBold(text: "산책 보낼 강아지를\n선택해주세요")
        $0.numberOfLines = 2
    }
    private let subMessageLabel = UILabel().then {
        $0.text = "최대 1마리까지 가능합니다"
        $0.textColor = .dark
        $0.font = FontSet.pretendardMedium(size: 16)
    }
    private let countLabel = UILabel().then {
        $0.text = "(0 / 1)"
        $0.textColor = .dark
        $0.font = FontSet.pretendardMedium(size: 16)
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
    
    private let noDogView = NonItemView(message: "펫패스에 등록된 강아지가 없어요", buttonText: "강아지 등록하기")
    
    private let requestButton = BottomPlacedButton().then {
        $0.setTitle("산책하기", for: .normal)
    }
    private let emptyView1 = UIView().then {
        $0.backgroundColor = .systemBackground
    }
    private let emptyView2 = UIView().then {
        $0.backgroundColor = .systemBackground
    }
    
    init(viewModel: RequestWalkViewModel) {
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
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getMyDogList()
        setNavigationTitle("산책 요청")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$dogList.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] dogList in
                self?.registeredDogCollectionView.setDogList(item: dogList)
                self?.noDogView.isHidden = !dogList.isEmpty
                self?.registeredDogCollectionView.isHidden = dogList.isEmpty
                self?.countLabel.text = "(0 / 1)"
            }.store(in: &subscriptions)
        
        viewModel.$walkButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isEnable in
            self?.requestButton.setupButtonStatus(isSelected: isEnable)
        }.store(in: &subscriptions)
        
        registeredDogCollectionView.dogIdPublisher.sink { [weak self] dogId in
            guard let strongSelf = self else { return }
            let response = strongSelf.viewModel.toggleDogSelection(dogId: dogId)
            self?.countLabel.text = "(\(response.count) / 1)"
            self?.registeredDogCollectionView.changeSelected(index: response.index, selected: response.selcted)
        }.store(in: &subscriptions)
        
        noDogView.registPublisher.sink { [weak self] in
            let viewController = RegistNumberViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
    }
}

extension SelectDogViewController {
    @objc private func requestButtonTapped() {
        viewModel.finalRequest.dogs = {
            zip(viewModel.dogList, viewModel.selectedList)
                .compactMap { dog, isSelected in
                    isSelected ? dog.did : nil
                }
        }()
        
        let viewController = SelectWalkConditionViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension SelectDogViewController {
    
    private func setupLayOuts() {
        [registeredDogCollectionView, emptyView1, emptyView2, messageLabel, subMessageLabel, countLabel, noDogView, requestButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(63)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(12)
            $0.leading.equalTo(subMessageLabel.snp.trailing).offset(4)
            $0.height.equalTo(19)
        }
        noDogView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(225)
            $0.height.equalTo(88)
        }
        registeredDogCollectionView.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(requestButton.snp.top).inset(16)
        }
        requestButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        emptyView1.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(registeredDogCollectionView.snp.top)
        }
        emptyView2.snp.makeConstraints {
            $0.top.equalTo(requestButton.snp.top).offset(-4)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

