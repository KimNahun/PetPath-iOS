//
//  DeleteAccountCheckViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/21/25.
//

import Combine
import UIKit

final class DeleteAccountCheckViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: DeleteAccountViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let messageLabel = UILabel()
    
    private let profileImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 45
        $0.layer.masksToBounds = true
        $0.backgroundColor = ColorSet.fromHex("D9D9D9")
    }
    
    private let nameLabel = UILabel()
    
    private let checkLabel = UILabel().then {
        $0.text = "탈퇴를 계속하기 위해서는\n아래 내용을 확인해 주세요."
    }
    
    private let checkView1 = AgreementView(text: "워커님은 아직 출금하지 않은 산책 대금이 있다면\n대금을 모두 출금하기 전까지 탈퇴가 어려워요.", showDetailButton: false)
    
    private let checkView2 = AgreementView(text: "매칭이 완료되어 진행 예정인 산책이나,\n현재 진행 중인 산책이 있으면 탈퇴가 어려워요.", showDetailButton: false)
    
    private let checkView3 = AgreementView(text: "커뮤니티 정책에 따라 미결제된 페널티가 있거나\n아직 진행 중인 분쟁이 있는 경우 탈퇴가 어려워요.", showDetailButton: false)
    
    private let checkView4 = AgreementView(text: "앱 부정 사용 또는 비매너 행위로 인해 재제된 경우\n고객센터에 연락하여 탈퇴를 진행해 주세요.", showDetailButton: false)
    
    
    private let nextButton = BottomPlacedButton().then {
        $0.setTitle("계속", for: .normal)
    }
    
    init(viewModel: DeleteAccountViewModel) {
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
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        viewModel.getUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("회원탈퇴")
    }
    
    // MARK: - Bind
    
    private func bind() {
        checkView1.agreementPublisher.sink { [weak self] isSelected in
            self?.viewModel.checkList[0] = isSelected
        }.store(in: &subscriptions)
        
        checkView2.agreementPublisher.sink { [weak self] isSelected in
            self?.viewModel.checkList[1] = isSelected
        }.store(in: &subscriptions)
        
        checkView3.agreementPublisher.sink { [weak self] isSelected in
            self?.viewModel.checkList[2] = isSelected
        }.store(in: &subscriptions)
        
        checkView4.agreementPublisher.sink { [weak self] isSelected in
            self?.viewModel.checkList[3] = isSelected
        }.store(in: &subscriptions)
        
 
        viewModel.$checkList
            .receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] list in
                guard let self = self else { return }
                let isAllChecked = list.allSatisfy { $0 }
                self.nextButton.setupButtonStatus(isSelected: isAllChecked)
            }.store(in: &subscriptions)
        
        viewModel.$userDTO.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] userData in
            guard let self = self, let userData = userData else { return }
            messageLabel.setTitleBold(text: "\(userData.name) 회원님,\n떠나신다니 너무 아쉬워요.")
            nameLabel.text = userData.name
            profileImageView.loadImage(url: userData.profileImg)
        }.store(in: &subscriptions)
    }
}

extension DeleteAccountCheckViewController {
    @objc private func nextButtonTapped() {
        let viewController = DeleteReasonViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DeleteAccountCheckViewController {
    
    private func setupLayOuts() {
        [messageLabel, profileImageView, nameLabel, checkLabel, checkView1, checkView2, checkView3, checkView4, nextButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(63)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(30)
            $0.size.equalTo(90)
            $0.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        checkLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(19)
            $0.bottom.equalTo(checkView1.snp.top).offset(-29)
        }
        checkView1.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(checkView2.snp.top).offset(-24)
            $0.height.equalTo(28)
        }
        checkView2.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(checkView3.snp.top).offset(-24)
            $0.height.equalTo(28)
        }
        checkView3.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(checkView4.snp.top).offset(-24)
            $0.height.equalTo(28)
        }
        checkView4.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(nextButton.snp.top).offset(-24)
            $0.height.equalTo(28)
        }
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        messageLabel.numberOfLines = 2
        messageLabel.textColor = .dark
        nameLabel.textColor = .dark
        nameLabel.font = FontSet.pretendardBold(size: 16)
        checkLabel.numberOfLines = 2
        checkLabel.textColor = .dark
        checkLabel.font = FontSet.pretendardBold(size: 18)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

