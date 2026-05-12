//
//  DogDetailInfoViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import UIKit

final class DogDetailInfoViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    private let viewModel: AddDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let guideLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.setTitleBold(text: "강아지에 대한 요구사항을\n작성해주세요")
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "특이사항 or 요구사항"
    }
    
    private let addInfoCollectionView: AddInfoCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = AddInfoCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()
    
    private let textViewLabel = UILabel().then {
        $0.text = "부가 정보 입력"
        $0.font = FontSet.pretendardSemiBold(size: 12)
        $0.textColor = .neutral6
    }
    
    private let textView = UITextView().then {
        $0.layer.borderWidth = 2
        $0.layer.borderColor = ColorSet.neutral6.cgColor
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        $0.textColor = .neutral10
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 8)
    }
    
    private let registerButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("강아지 등록", for: .normal)
    }
    
    init(viewModel: AddDogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.registRequest.description = ""
        viewModel.requireTags = viewModel.requireTags.map {
            let tag = KeywordTag(name: $0.name, isSelected: false)
            return tag
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        textView.delegate = self
        hideKeyboardWhenTappedAround()
        addInfoCollectionView.setKeywordList(item: viewModel.requireTags)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        addInfoCollectionView.setKeywordList(item: viewModel.requireTags)
        addInfoCollectionView.snp.updateConstraints {
            $0.height.equalTo(addInfoCollectionView.calculateDynamicHeight())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("강아지 등록")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Bind
    
    private func bind() {
        addInfoCollectionView.requirePublisher.sink { [weak self] index in
            self?.viewModel.requireTags[index].isSelected.toggle()
        }.store(in: &subscriptions)
        
        viewModel.$requireTags.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] items in
                guard let strongSelf = self else { return }
                self?.addInfoCollectionView.setKeywordList(item: items)
                strongSelf.addInfoCollectionView.snp.updateConstraints {
                    $0.height.equalTo(strongSelf.addInfoCollectionView.calculateDynamicHeight())
                }
            }.store(in: &subscriptions)
        
        viewModel.registerSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self = self else { return }
            let mainPageViewController = OwnerMainPageViewController(viewModel: .init())
            let addDogCheckViewController = AddDogCheckViewController(viewModel: viewModel)
            
            navigationController?.setViewControllers([mainPageViewController, addDogCheckViewController], animated: true)
        }.store(in: &subscriptions)
    }
}

extension DogDetailInfoViewController {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.registRequest.description = textView.text
    }
    
    @objc private func registerButtonTapped() {
        viewModel.registMyDog()
    }
    
}

extension DogDetailInfoViewController {
    
    private func setupLayOuts() {
        [guideLabel, messageLabel, addInfoCollectionView, textViewLabel, textView, registerButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(75)
            $0.leading.equalToSuperview().offset(16)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        addInfoCollectionView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        textViewLabel.snp.makeConstraints {
            $0.top.equalTo(addInfoCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        textView.snp.makeConstraints {
            $0.top.equalTo(textViewLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(registerButton.snp.top).offset(-110)
        }
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        textViewLabel.font = FontSet.pretendardSemiBold(size: 12)
        textViewLabel.textColor = .neutral6
        messageLabel.font = FontSet.pretendardBold(size: 16)
        messageLabel.textColor = .neutral9
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

