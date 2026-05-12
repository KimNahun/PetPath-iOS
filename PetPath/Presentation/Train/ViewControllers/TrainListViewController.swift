//
//  TrainListViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/15/25.
//

import Combine
import UIKit

final class TrainListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.setTitleBold(text: "워커 교육에 오신 것을 환영해요")
    }
    private let subMessageLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 16)
        $0.textColor = .dark
        $0.numberOfLines = 2
    }
    
    private lazy var trainTableView = TrainTableView(viewModel: viewModel)
    
    private let moveTestButton = BottomPlacedButton().then {
        $0.setTitle("워커 인증 테스트로 이동", for: .normal)
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
        moveTestButton.addTarget(self, action: #selector(moveTestButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("워커 교육 이수")
        viewModel.getWalkerTrainList()
        viewModel.getWalkerTrainStatus()
    }
    
    // MARK: - Bind
    
    private func bind() {
        Publishers.CombineLatest(viewModel.$trainList, viewModel.$trainSuccess)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list, isSuccess in
                guard let self = self else { return }
                
                let completedCount = list.filter { $0.page == $0.progress }.count
                let isAllTrained = list.count > 0 && completedCount == list.count
                
                let isEnabled = isAllTrained && !isSuccess
                self.moveTestButton.setupButtonStatus(isSelected: isEnabled)
                
            }.store(in: &subscriptions)
        
        viewModel.$trainSuccess.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isSuccess in
            guard let self = self else { return }
            moveTestButton.setTitle(isSuccess ? "워커 인증 완료" : "워커 인증 테스트로 이동", for: .normal)
        }.store(in: &subscriptions)
        
        viewModel.$trainList.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] list in
            guard let self = self else { return }
            let count = list.filter { $0.page == $0.progress }.count
            subMessageLabel.text = "모든 교육을 이수한 후에 인증 시험을 완료하고 \n워커로 활동을 시작할 수 있어요 ( \(count) / \(list.count) )"
        }.store(in: &subscriptions)
        
        viewModel.$selectedKey.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] key in
            guard let self = self else { return }
            navigationController?.pushViewController(TrainContentViewController(viewModel: viewModel), animated: true)
        }.store(in: &subscriptions)
    }
}

extension TrainListViewController {
    @objc private func moveTestButtonTapped() {
        navigationController?.pushViewController(TrainMessageViewController(viewModel: viewModel), animated: true)
    }
}

extension TrainListViewController {
    
    private func setupLayOuts() {
        [titleLabel, subMessageLabel, trainTableView, moveTestButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        trainTableView.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(31)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(moveTestButton.snp.top).offset(-10)
        }
        moveTestButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
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
