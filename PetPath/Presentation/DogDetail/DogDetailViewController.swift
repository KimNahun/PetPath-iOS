//
//  DogDetailViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import UIKit

// TODO: 여기 라벨 길어질 것을 대비해서 scollview로 덮기

final class DogDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: DogDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    init(viewModel: DogDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let dogCardView = DogCardView()
    
    private lazy var dogDetailCollectionView: DogDetailCollectionView = {
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
    
    private let deleteDogCheckModalViewController = ActionCheckModalViewController(message: "해당 강아지를 삭제하시겠어요?")
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationRightButtons(keys: ["edit", "trashcan"])
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getMyDogDetail()
        setNavigationTitle("")
    }
    
    // MARK: - Bind
    
    private func bind() {
        navigationButtonPublisher(for: "edit")
            .sink { [weak self] in
                guard let self = self else { return }
                let viewController = ModifyDogViewController(viewModel: ModifyDogViewModel(dogId: viewModel.dogId))
                navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscriptions)

        navigationButtonPublisher(for: "trashcan")
            .sink { [weak self] in
                guard let self = self else { return }
                present(deleteDogCheckModalViewController, animated: true)
            }.store(in: &subscriptions)
        
        
        deleteDogCheckModalViewController.processPublisher.sink { [weak self] _ in
            self?.viewModel.deleteMyDog()
        }.store(in: &subscriptions)
        
        viewModel.$dogDetail.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] dogDetail in
                guard let strongSelf = self else { return }
                self?.dogCardView.configure(name: dogDetail.dogName, species: dogDetail.species, birthday: dogDetail.birthday, gender: dogDetail.gender, isNeuter: dogDetail.isNeuter, imageUrl: dogDetail.profileImg)
                self?.descriptionLabel.text = dogDetail.description
                let mappedInfoList: [(text: String, color: UIColor)] = [
                    (text: dogDetail.size.koreanDescription, color: ColorSet.fromHex("AFF4C6"))
                ] + dogDetail.char.map { (text: $0, color: .primary300) }
                + dogDetail.require.map { (text: $0, color: .secondary100) }
                self?.dogDetailCollectionView.setKeywordList(item: mappedInfoList)
                
                strongSelf.dogDetailCollectionView.snp.updateConstraints {
                    $0.height.equalTo(strongSelf.dogDetailCollectionView.calculateDynamicHeight())
                }
            }.store(in: &subscriptions)
        
        viewModel.deleteSuccess.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            ToastMessenger.shared.showToast(message: "강아지를 삭제했습니다.")
        }.store(in: &subscriptions)
    }
}

extension DogDetailViewController {


}

extension DogDetailViewController {
    
    private func setupLayOuts() {
        [dogCardView, dogDetailCollectionView, guideLabel, descriptionLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        dogCardView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(159)
        }
        dogDetailCollectionView.snp.makeConstraints {
            $0.top.equalTo(dogCardView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(dogDetailCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
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
