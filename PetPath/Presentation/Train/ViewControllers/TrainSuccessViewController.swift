//
//  TrainSuccessViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class TrainSuccessViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let messageLabel = UILabel().then {
        $0.text = "이미 교육을 모두 완료했어요"
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 24)
    }
    private let imageView = AspectFitImageView().then {
        $0.image = UIImage(named: "quizComplete")
        $0.contentMode = .scaleAspectFit
    }
    
    private let findWalkButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("내 주변 산책 찾아보러 가기", for: .normal)
    }
    private let goHomeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("홈으로 이동", for: .normal)
    }
    private let showTrainButton = BottomPlacedButton(isSelected: true, backColor: ColorSet.fromHex("FEED93")).then {
        $0.setTitle("교육 내용 다시보기", for: .normal)
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
        findWalkButton.addTarget(self, action: #selector(findWalkButtonTapped), for: .touchUpInside)
        goHomeButton.addTarget(self, action: #selector(goHomeButtonTapped), for: .touchUpInside)
        showTrainButton.addTarget(self, action: #selector(showTrainButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("워커 교육 이수")
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension TrainSuccessViewController {
    @objc private func findWalkButtonTapped() {
        let viewControllers = [
            WalkerMainPageViewController(viewModel: MainPageViewModel()),
            FindWalkViewController(viewModel: FindWalkViewModel())
        ]
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    @objc private func goHomeButtonTapped() {
        navigationController?.setViewControllers([WalkerMainPageViewController(viewModel: MainPageViewModel())], animated: true)
    }
    
    @objc private func showTrainButtonTapped() {
        navigationController?.pushViewController(TrainListViewController(viewModel: viewModel), animated: true)
    }
}

extension TrainSuccessViewController {
    
    private func setupLayOuts() {
        [messageLabel, imageView, findWalkButton, goHomeButton, showTrainButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(97)
            $0.centerX.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(39)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(122)
            $0.height.equalTo(195)
        }
        findWalkButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(48)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(223)
            $0.height.equalTo(41)
        }
        goHomeButton.snp.makeConstraints {
            $0.top.equalTo(findWalkButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(223)
            $0.height.equalTo(41)
        }
        showTrainButton.snp.makeConstraints {
            $0.top.equalTo(goHomeButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(223)
            $0.height.equalTo(41)
        }
    }
    
    private func setupComponents() {
        
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
