//
//  WalkHistoryViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class WalkHistoryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: WalkHistoryViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private let nonItemView: NonItemView = .init(message: "펫패스에서 진행된 산책이 없어요", buttonText: "산책하러 가기")
    
    private lazy var walkHistoryTableView = WalkHistoryTableView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    // MARK: - UI Components
  
    init(viewModel: WalkHistoryViewModel) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserInfo()
        setNavigationTitle("산책 내역")
    }
    
    // MARK: - Bind
    
    private func bind() {
        
        nonItemView.registPublisher.sink { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewModel.userType == .walker {
                let viewController = FindWalkViewController(viewModel: FindWalkViewModel())
                self?.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let viewController = SelectDogViewController(viewModel: RequestWalkViewModel())
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.$completedWalks.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] _ in
            guard let strongSelf = self else { return }
            let count = strongSelf.viewModel.activeWalks.count + strongSelf.viewModel.completedWalks.count
            self?.nonItemView.isHidden = count != 0
            self?.walkHistoryTableView.isHidden = count == 0
        }.store(in: &subscriptions)
        
        walkHistoryTableView.cellTapPublisher.receive(on: DispatchQueue.main).sink { [weak self] id in
            if self?.viewModel.userType == .walker {
                let viewController = WalkerWalkDetailViewController(viewModel: WalkerWalkDetailViewModel(id: id))
                self?.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let viewController = OwnerWalkDetailViewController(viewModel: OwnerWalkDetailViewModel(id: id))
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }.store(in: &subscriptions)
    }
}

extension WalkHistoryViewController {
   
}

extension WalkHistoryViewController {
    
    private func setupLayOuts() {
        [nonItemView, walkHistoryTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        nonItemView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(225)
            $0.height.equalTo(88)
        }
        walkHistoryTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
