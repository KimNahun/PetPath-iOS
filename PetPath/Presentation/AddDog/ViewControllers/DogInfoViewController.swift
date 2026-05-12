//
//  DogInfoViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class DogInfoViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: AddDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let guideLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.setTitleBold(text: "강아지에 대해\n알려주세요")
    }
    
    private let sizeLabel = UILabel().then {
        $0.text = "크기 설정"
    }
    private let bigSizeButton = UIButton().then {
        $0.setTitle("대형견", for: .normal)
    }
    private let mediumSizeButton = UIButton().then {
        $0.setTitle("중형견", for: .normal)
    }
    private let smallSizeButton = UIButton().then {
        $0.setTitle("소형견", for: .normal)
    }
    private let sizeGuideLabel = UILabel().then {
        $0.text = "대형견 : 20kg 초과\n중형견 : 10kg ~ 20kg\n소형견 : 10kg 미만"
        $0.numberOfLines = 3
    }
    private let personalityLabel = UILabel().then {
        $0.text = "성격 설정 (최소 2개)"
    }
    private let personalityCollectionView: PersonalityCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = PersonalityCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let nextButton = BottomPlacedButton().then {
        $0.setTitle("다음", for: .normal)
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
        viewModel.registRequest.size = nil
        viewModel.registRequest.char = []
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        [bigSizeButton, mediumSizeButton, smallSizeButton].forEach {
            $0.addTarget(self, action: #selector(sizeButtonTapped), for: .touchUpInside)
        }
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        viewModel.getKeywordTagList()
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
        viewModel.$charTags.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] items in
                guard let strongSelf = self else { return }
                self?.personalityCollectionView.setKeywordList(item: items)
                strongSelf.personalityCollectionView.snp.updateConstraints {
                    $0.height.equalTo(strongSelf.personalityCollectionView.calculateDynamicHeight())
                }
            }.store(in: &subscriptions)
        
        personalityCollectionView.personalityPublisher.sink { [weak self] index in
            self?.viewModel.charTags[index].isSelected.toggle()
        }.store(in: &subscriptions)
        
        viewModel.$personalityNextButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isEnabled in
            self?.nextButton.setupButtonStatus(isSelected: isEnabled)
        }.store(in: &subscriptions)
    }
}

extension DogInfoViewController {
    
    @objc private func nextButtonTapped() {
        let viewController = DogDetailInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        let buttons = [bigSizeButton, mediumSizeButton, smallSizeButton]
        if sender.isSelected {
            sender.isSelected = false
            viewModel.registRequest.size = nil
        } else {
            buttons.forEach { $0.isSelected = ($0 == sender) }
            if sender == bigSizeButton {
                viewModel.registRequest.size = .big
            } else if sender == mediumSizeButton {
                viewModel.registRequest.size = .middle
            } else {
                viewModel.registRequest.size = .small
            }
        }
        updateButtonStyles()
    }
    
    private func updateButtonStyles() {
        let allButtons = [bigSizeButton, mediumSizeButton, smallSizeButton]
        
        allButtons.forEach {
            if $0.isSelected {
                $0.setTitleColor(.dark, for: .normal)
                $0.backgroundColor = ColorSet.fromHex("AFF4C6")
            } else {
                $0.setTitleColor(.neutral7, for: .normal)
                $0.backgroundColor = .neutral4
            }
        }
    }
}

extension DogInfoViewController {
    
    private func setupLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(nextButton)
        [guideLabel, sizeLabel, bigSizeButton, mediumSizeButton, smallSizeButton, sizeGuideLabel, personalityLabel, personalityCollectionView].forEach {
            scrollView.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView).offset(75)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(63)
        }
        sizeLabel.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        bigSizeButton.snp.makeConstraints {
            $0.top.equalTo(sizeLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(54)
            $0.height.equalTo(25)
        }
        mediumSizeButton.snp.makeConstraints {
            $0.top.equalTo(sizeLabel.snp.bottom).offset(12)
            $0.leading.equalTo(bigSizeButton.snp.trailing).offset(16)
            $0.width.equalTo(54)
            $0.height.equalTo(25)
        }
        smallSizeButton.snp.makeConstraints {
            $0.top.equalTo(sizeLabel.snp.bottom).offset(12)
            $0.leading.equalTo(mediumSizeButton.snp.trailing).offset(16)
            $0.width.equalTo(54)
            $0.height.equalTo(25)
        }
        sizeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(smallSizeButton.snp.bottom).offset(12)
            $0.leading.equalTo(bigSizeButton.snp.leading).offset(8)
        }
        personalityLabel.snp.makeConstraints {
            $0.top.equalTo(sizeGuideLabel.snp.bottom).offset(60)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        personalityCollectionView.snp.makeConstraints {
            $0.top.equalTo(personalityLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.width.equalTo(nextButton.snp.width)
            $0.height.equalTo(1)
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        [sizeLabel, personalityLabel].forEach {
            $0.font = FontSet.pretendardBold(size: 16)
            $0.textColor = .neutral9
        }
        [bigSizeButton, mediumSizeButton, smallSizeButton].forEach {
            $0.backgroundColor = .neutral4
            $0.titleLabel?.font = FontSet.pretendardSemiBold(size: 14)
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.setTitleColor(.neutral7, for: .normal)
        }
        sizeGuideLabel.font = FontSet.pretendardMedium(size: 12)
        sizeGuideLabel.textColor = .neutral8
        
        personalityLabel.font = FontSet.pretendardBold(size: 16)
        personalityLabel.textColor = .neutral9
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

