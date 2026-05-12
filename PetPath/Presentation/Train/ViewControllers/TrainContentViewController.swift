//
//  TrainContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Combine
import UIKit

final class TrainContentViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let messageLabel = UILabel()
    
    private let imageView = AspectFitImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel()
    
    private let contentLabel = UILabel()
    
    private let prevButton = BottomPlacedButton().then {
        $0.setTitle("이전", for: .normal)
    }
    private let nextButton = BottomPlacedButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    init(viewModel: TrainViewModel) {
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
        viewModel.getWalkerTrainContent()
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("워커 교육 이수")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$trainContent.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let self = self, let response = response else { return }
            messageLabel.setTitleBold(text: response.chapterTitle)
            if let item = response.pages.first {
                imageView.loadImage(url: item.image)
                titleLabel.text = item.title
                contentLabel.text = "\(item.content) \(item.content)"
            }
            if response.pages.count >= 2 {
                nextButton.setupButtonStatus(isSelected: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.$selectedContentIndex.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] index in
            guard let self = self else { return }
            guard let pages = viewModel.trainContent?.pages,
                  index >= 0, index < pages.count else { return }
            
            let page = pages[index]
            titleLabel.text = page.title
            contentLabel.text = page.content
            imageView.loadImage(url: page.image)

            prevButton.setupButtonStatus(isSelected: index > 0)

            let isLast = index == pages.count - 1
            let nextButtonTitle = isLast ? "완료하고 교육 홈으로" : "다음"
            nextButton.setTitle(nextButtonTitle, for: .normal)

            if isLast {
                nextButton.setupButtonStatus(isSelected: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.successPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            ToastMessenger.shared.showToast(message: "수료가 완료되었습니다.")
        }.store(in: &subscriptions)
    }
}

extension TrainContentViewController {
    @objc private func prevButtonTapped() {
        guard let _ = viewModel.trainContent?.pages.count else { return }
        let newIndex = viewModel.selectedContentIndex - 1
        if newIndex >= 0 {
            viewModel.selectedContentIndex = newIndex
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let _ = viewModel.trainContent?.pages else { return }
        let currentIndex = viewModel.selectedContentIndex
        viewModel.selectedContentIndex = currentIndex + 1
        viewModel.setWalkerTrainProgress()
    }
}

extension TrainContentViewController {
    
    private func setupLayOuts() {
        [scrollView, prevButton, nextButton].forEach {
            view.addSubview($0)
        }
        [messageLabel, imageView, titleLabel, contentLabel].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(37)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(view.snp.width)
            $0.bottom.equalTo(prevButton.snp.top).offset(-10)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.horizontalEdges.equalTo(view).inset(20)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.horizontalEdges.equalTo(view).inset(20)
            $0.height.equalTo(imageView.snp.width)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.horizontalEdges.equalTo(view).inset(20)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.horizontalEdges.equalTo(view).inset(20)
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        prevButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(view.snp.centerX).offset(-4)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        messageLabel.font = FontSet.pretendardBold(size: 24)
        messageLabel.textColor = .dark
        titleLabel.font = FontSet.pretendardBold(size: 18)
        titleLabel.textColor = .dark
        contentLabel.font = FontSet.pretendardMedium(size: 14)
        contentLabel.textColor = .dark
        [messageLabel, titleLabel, contentLabel].forEach {
            $0.numberOfLines = 0
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
