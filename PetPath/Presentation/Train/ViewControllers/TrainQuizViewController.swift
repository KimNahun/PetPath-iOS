//
//  TrainQuizViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class TrainQuizViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private lazy var agreementList = [agreementViewA, agreementViewB, agreementViewC, agreementViewD]
    
    private let questionLabel = UILabel()
    
    private let progressLabel = UILabel().then {
        $0.text = "완료 현황"
    }
    
    private let progressView = UIProgressView()
    
    private let agreementViewA = AgreementView(showDetailButton: false)
    
    private let agreementViewB = AgreementView(showDetailButton: false)
    
    private let agreementViewC = AgreementView(showDetailButton: false)
    
    private let agreementViewD = AgreementView(showDetailButton: false)
    
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
        viewModel.getWalkerTrainQuiz()
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("워커 교육 이수")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$selectedQuizIndex.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] index in
            guard let self = self else { return }
            guard index >= 0, index < viewModel.quizList.count else { return }
            let quiz = viewModel.quizList[index]
            questionLabel.text = "\(index + 1)) \(quiz.question)"
            agreementViewA.setupText(text: quiz.A)
            agreementViewB.setupText(text: quiz.B)
            agreementViewC.setupText(text: quiz.C)
            agreementViewD.setupText(text: quiz.D)
            prevButton.setupButtonStatus(isSelected: index > 0)
            progressView.progress = Float(index + 1) / Float(viewModel.quizList.count)
            
            let isLast = index == viewModel.quizList.count - 1
            nextButton.setTitle(isLast ? "완료" : "다음", for: .normal)
            nextButton.setupButtonStatus(isSelected: false)
            agreementList.forEach {
                $0.setButtonStatus(isSelected: false)
            }
        }.store(in: &subscriptions)
        
        for (index, view) in agreementList.enumerated() {
            view.agreementPublisher
                .sink { [weak self] isSelected in
                    guard let self = self else { return }
                    if isSelected {
                        nextButton.setupButtonStatus(isSelected: true)
                        for (i, otherView) in self.agreementList.enumerated() {
                            otherView.setButtonStatus(isSelected: i == index)
                        }
                    } else {
                        nextButton.setupButtonStatus(isSelected: false)
                    }
                }.store(in: &subscriptions)
        }
    }
}

extension TrainQuizViewController {
    @objc private func prevButtonTapped() {
        let newIndex = viewModel.selectedQuizIndex - 1
        if newIndex >= 0 {
            viewModel.selectedQuizIndex = newIndex
        }
    }
    
    @objc private func nextButtonTapped() {
        let currentIndex = viewModel.selectedQuizIndex
        let isLast = currentIndex == viewModel.quizList.count - 1
        if let selectedIndex = agreementList.firstIndex(where: { $0.getStatus() }) {
               let selectedAnswer = ["A", "B", "C", "D"][selectedIndex]
               viewModel.submitQuizList[currentIndex].answer = selectedAnswer
           }
        if isLast {
            navigationController?.pushViewController(TrainQuizResultViewController(viewModel: viewModel), animated: true)
        } else {
            viewModel.selectedQuizIndex = currentIndex + 1
        }
    }
}

extension TrainQuizViewController {
    
    private func setupLayOuts() {
        [questionLabel, progressLabel, progressView, agreementViewA, agreementViewB, agreementViewC, agreementViewD, prevButton, nextButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(28)
            $0.leading.equalTo(questionLabel)
        }
        progressView.snp.makeConstraints {
            $0.top.equalTo(progressLabel.snp.bottom).offset(8)
            $0.leading.equalTo(questionLabel)
            $0.width.equalTo(243)
            $0.height.equalTo(10)
        }
        agreementViewA.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(28)
            $0.leading.equalTo(questionLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        agreementViewB.snp.makeConstraints {
            $0.top.equalTo(agreementViewA.snp.bottom).offset(20)
            $0.leading.equalTo(questionLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        agreementViewC.snp.makeConstraints {
            $0.top.equalTo(agreementViewB.snp.bottom).offset(20)
            $0.leading.equalTo(questionLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        agreementViewD.snp.makeConstraints {
            $0.top.equalTo(agreementViewC.snp.bottom).offset(20)
            $0.leading.equalTo(questionLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
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
        questionLabel.textColor = .dark
        questionLabel.font = FontSet.pretendardBold(size: 16)
        questionLabel.numberOfLines = 0
        progressLabel.textColor = .neutral8
        progressLabel.font = FontSet.pretendardBold(size: 14)
        progressView.trackTintColor = ColorSet.fromHex("D9D9D9")
        progressView.progressTintColor = ColorSet.fromHex("FEE254")
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

