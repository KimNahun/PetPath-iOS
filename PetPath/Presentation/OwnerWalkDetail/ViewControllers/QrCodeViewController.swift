//
//  QrCodeViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Combine
import UIKit

final class QrCodeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OwnerWalkDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let qrImageView = AspectFitImageView()
    
    private let messageLabel = UILabel().then {
        $0.text = "워커님의 앱에서 QR을 촬영해주세요."
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "QR코드가 인식되어 화면이 꺼지면 산책을 진행해주세요"
    }
    
    init(viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        SocketService.shared.emitListenWalk(walkId: -1)
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
        qrImageView.loadImage(url: viewModel.walkDetailResponse?.qrUrl ?? "")
        SocketService.shared.establishConnection()
        NotificationCenter.default.publisher(for: .socketConnected)
               .sink { [weak self] _ in
                   guard let self = self,
                         let walkId = self.viewModel.walkDetailResponse?.pk else { return }
                   print("✅ 소켓 연결 후 walkId emit 시작")
                   SocketService.shared.emitListenWalk(walkId: walkId)
                   SocketService.shared.registerWalkStatusEvent { walkId, status in
                       self.handleWalkStatusEvent(walkId: walkId, status: status)
                   }
               }
               .store(in: &subscriptions)
    }
    private func handleWalkStatusEvent(walkId: Int, status: String) {
        switch status {
        case "start":
            ToastMessenger.shared.showToast(message: "산책이 시작되었습니다.")
            navigationController?.popViewController(animated: true)
        case "end":
            ToastMessenger.shared.showToast(message: "산책이 종료되었습니다.")
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(viewModel.walkDetailResponse?.title ?? "", status: viewModel.walkDetailResponse?.status ?? .unknown)
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension QrCodeViewController {
    
}

extension QrCodeViewController {
    
    private func setupLayOuts() {
        [qrImageView, messageLabel, subMessageLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        qrImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(180)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(qrImageView.snp.bottom).offset(36)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 16)
        subMessageLabel.textColor = .dark
        subMessageLabel.font = FontSet.pretendardMedium(size: 12)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
