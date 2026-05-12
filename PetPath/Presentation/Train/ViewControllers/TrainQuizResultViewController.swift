//
//  TrainQuizResultViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class TrainQuizResultViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let messageLabel = UILabel()
    
    private let scoreLabel = UILabel()
    
    private let imageView = AspectFitImageView()
    
    private let contentLabel = UILabel()
    
    private let walkButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("내 주변 산책 알아보러 가기", for: .normal)
        $0.isHidden = true
    }
    private let goHomeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("홈으로 이동", for: .normal)
        $0.isHidden = true
    }
    private let tryAgainButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("다시 시도하기", for: .normal)
        $0.isHidden = true
    }
    
    private let goTrainHomeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("교육 홈으로", for: .normal)
        $0.isHidden = true
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
        viewModel.submitWalkerTrainQuiz()
        walkButton.addTarget(self, action: #selector(walkButtonTapped), for: .touchUpInside)
        goHomeButton.addTarget(self, action: #selector(goHomeButtonTapped), for: .touchUpInside)
        tryAgainButton.addTarget(self, action: #selector(tryAgainButtonTapped), for: .touchUpInside)
        goTrainHomeButton.addTarget(self, action: #selector(goTrainHomeButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("워커 교육 이수")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$quizResult.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] result in
            guard let self = self, let result = result else { return }
            walkButton.isHidden = !result.isPass
            goHomeButton.isHidden = !result.isPass
            tryAgainButton.isHidden = result.isPass
            goTrainHomeButton.isHidden = result.isPass
            messageLabel.text = result.isPass ? "합격을 축하드려요!" : "아쉽지만 다시 시도해 주세요"
            scoreLabel.text = "점수 \(result.correct)/\(viewModel.quizList.count)"
            contentLabel.text = result.isPass ? "이제 인증된 펫 워커로\n정식 활동을 시작할 수 있어요!" : "인증된 펫 워커로 활동을 시작하기 위해\n평가를 다시 진행해 주세요"
            imageView.image = UIImage(named: result.isPass ? "quizComplete" : "quizFail")
        }.store(in: &subscriptions)
    }
}

extension TrainQuizResultViewController {
    @objc private func walkButtonTapped() {
        let viewControllers = [WalkerMainPageViewController(viewModel: MainPageViewModel()), FindWalkViewController(viewModel: FindWalkViewModel())]
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    @objc private func goHomeButtonTapped() {
        navigationController?.setViewControllers([WalkerMainPageViewController(viewModel: MainPageViewModel())], animated: true)
    }
    
    @objc private func tryAgainButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: TrainMessageViewController.self, createNew: {
            TrainMessageViewController(viewModel: TrainViewModel())
        })
    }
    
    @objc private func goTrainHomeButtonTapped() {
        navigationController?.popToViewControllerOrReplace(ofType: TrainListViewController.self, createNew: {
            TrainListViewController(viewModel: TrainViewModel())
        })
    }
}

extension TrainQuizResultViewController {
    
    private func setupLayOuts() {
        [messageLabel, scoreLabel, imageView, contentLabel, walkButton, goHomeButton, tryAgainButton, goTrainHomeButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(67)
            $0.centerX.equalToSuperview()
        }
        scoreLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(scoreLabel.snp.bottom).offset(33.5)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(122)
            $0.height.equalTo(195)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(33.5)
            $0.centerX.equalToSuperview()
        }
        walkButton.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(223)
            $0.height.equalTo(41)
        }
        goHomeButton.snp.makeConstraints {
            $0.top.equalTo(walkButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(223)
            $0.height.equalTo(41)
        }
        tryAgainButton.snp.makeConstraints {
            $0.edges.equalTo(walkButton)
        }
        goTrainHomeButton.snp.makeConstraints {
            $0.edges.equalTo(goHomeButton)
        }
    }
    
    private func setupComponents() {
        messageLabel.font = FontSet.pretendardBold(size: 24)
        messageLabel.textColor = .dark
        scoreLabel.font = FontSet.pretendardBold(size: 16)
        scoreLabel.textColor = .neutral7
        contentLabel.numberOfLines = 2
        contentLabel.font = FontSet.pretendardBold(size: 16)
        contentLabel.textColor = .neutral9
        contentLabel.textAlignment = .center
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

