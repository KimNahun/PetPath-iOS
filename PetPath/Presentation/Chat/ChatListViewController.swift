//
//  ChatListViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class ChatListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ChatViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let nonItemView: NonItemView = .init(message: "펫패스에서 진행된 산책이 없어요", buttonText: "산책하러 가기")
    
    private lazy var chatListTableView = ChatListTableView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    init(viewModel: ChatViewModel) {
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
        SocketService.shared.establishConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getChatRoomList()
        viewModel.getUserInfo()
        setNavigationTitle("채팅 목록")
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
        
        viewModel.$completedWalks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] walk in
                let count = walk.count
                self?.nonItemView.isHidden = count != 0
                self?.chatListTableView.isHidden = count == 0
            }.store(in: &subscriptions)

        chatListTableView.cellTapPublisher.sink { [weak self] item in
            let viewController = ChatWebViewController(id: String(item.roomId), viewModel: .init())
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: .newChatEventReceived)
            .sink { [weak self] notification in
                guard let self = self else { return }
                self.viewModel.getChatRoomList()
            }.store(in: &subscriptions)
        
    }
}

extension ChatListViewController {
    
}

extension ChatListViewController {
    
    private func setupLayOuts() {
        [nonItemView, chatListTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        nonItemView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(225)
            $0.height.equalTo(88)
        }
        chatListTableView.snp.makeConstraints {
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

