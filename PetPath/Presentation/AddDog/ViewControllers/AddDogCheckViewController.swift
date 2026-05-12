//
//  AddDogCheckViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class AddDogCheckViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: AddDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let messageLabel = UILabel().then {
        $0.setTitleBold(text: "강아지가 등록되었어요")
    }
    
    private let dogCardView = DogCardView()
    
    private let dogDetailCollectionView: DogDetailCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = DogDetailCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()
    
    private let guideLabel = UILabel().then {
        $0.text = "부가 정보"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    private let goMainPageButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("돌아가기", for: .normal)
    }
    
    init(viewModel: AddDogViewModel) {
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
        showDogData()
        goMainPageButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("강아지 등록")
    }
    
    // MARK: - Bind
    
    private func bind() {
    }
}

extension AddDogCheckViewController {
    
    private func showDogData() {
        guard let response = viewModel.registMyDogResponse else { return }
        dogCardView.configure(name: response.dogName, species: response.species, birthday: response.birthday, gender: response.gender, isNeuter: response.isNeuter, imageUrl: response.profileImg)
        descriptionLabel.text = response.description
        let mappedInfoList: [(text: String, color: UIColor)] = [
            (text: (response.size).koreanDescription, color: ColorSet.fromHex("AFF4C6"))
        ] + response.char.map { (text: $0, color: .primary300) }
        + response.require.map { (text: $0, color: .secondary100) }
        dogDetailCollectionView.setKeywordList(item: mappedInfoList)
        
        dogDetailCollectionView.snp.updateConstraints {
            $0.height.equalTo(dogDetailCollectionView.calculateDynamicHeight())
        }
    }
    
    @objc private func registerButtonTapped() {
        ToastMessenger.shared.showToast(message: "등록이 완료되었습니다.")
        let viewControllers = [OwnerMainPageViewController(viewModel: .init())]
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
}

extension AddDogCheckViewController {
    
    private func setupLayOuts() {
        [scrollView, goMainPageButton].forEach {
            view.addSubview($0)
        }
        [messageLabel, dogCardView, dogDetailCollectionView, guideLabel, descriptionLabel].forEach {
            scrollView.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        // TODO: 여기 텍스트 길어지면 좀 이상함. 스크롤뷰
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(goMainPageButton.snp.top).offset(30)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(80)
            $0.leading.equalToSuperview()
            $0.height.equalTo(63)
        }
        dogCardView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(159)
        }
        dogDetailCollectionView.snp.makeConstraints {
            $0.top.equalTo(dogCardView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(dogDetailCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(14)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        goMainPageButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        guideLabel.font = FontSet.pretendardSemiBold(size: 12)
        guideLabel.textColor = .neutral6
        descriptionLabel.font = FontSet.pretendardMedium(size: 12)
        descriptionLabel.textColor = .neutral11
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
