//
//  TrainMessageViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class TrainMessageViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrainViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let messageLabel = UILabel().then {
        $0.text = "교육 내용은 유익하셨나요?"
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "이제 간단한 인증 테스트를 통과하면\n드디어 워커로 활동을 시작할 수 있어요 !"
    }
    
    private let noticeLabel = UILabel().then {
        $0.text = "참고해 주세요!"
    }
    
    private let subNoticeLabel = UILabel().then {
        $0.text = """
워커 인증 테스트는 앞선 교육에서 보신 내용에 대한
15개의 질문으로 이루어져 있어요.

시간 제한은 없으니 천천히 하셔도 괜찮아요.

한 번에 통과하지 못하더라도 재시도할 수 있어요.

인증 테스트 도중에 앱을 종료하시면
성과가 초기화되니 유의해 주세요.

80% 이상의 정답률을 달성해야 인증이 완료돼요.
"""
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("FFF8D6")
    }
    
    private let contentLabel = UILabel().then {
        $0.text = """
부탁의 말씀
번거로우시더라도, 워커님과 강아지의 안전과 행복한 산책을 위한 마지막 관문이니 이해해 주세요.

저희 서비스 품질 향상에 기여해 주셔서 감사해요.

저희 펫패스 커뮤니티에서 앞으로 즐겁고 멋진 활동을 이어나가실 워커님을 응원해요.
"""
    }
    
    private let startButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("시작하기", for: .normal)
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
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("워커 교육 이수")
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension TrainMessageViewController {
    @objc private func startButtonTapped() {
        navigationController?.pushViewController(TrainQuizViewController(viewModel: viewModel), animated: true)
    }
}

extension TrainMessageViewController {
    
    private func setupLayOuts() {
        [messageLabel, subMessageLabel, noticeLabel, subNoticeLabel, contentView, startButton].forEach {
            view.addSubview($0)
        }
        contentView.addSubview(contentLabel)
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.snp.leading).offset(22)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(8)
            $0.leading.equalTo(messageLabel)
        }
        noticeLabel.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(75)
            $0.leading.equalTo(messageLabel)
        }
        subNoticeLabel.snp.makeConstraints {
            $0.top.equalTo(noticeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(messageLabel)
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(subNoticeLabel.snp.bottom).offset(75)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }
        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        [messageLabel, noticeLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardBold(size: 24)
        }
        [subMessageLabel, subNoticeLabel].forEach {
            $0.numberOfLines = 0
            $0.textColor = .dark
            $0.font = FontSet.pretendardMedium(size: 14)
        }
        contentLabel.numberOfLines = 0
        contentLabel.textColor = ColorSet.fromHex("918130")
        contentLabel.font = FontSet.pretendardMedium(size: 12)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
