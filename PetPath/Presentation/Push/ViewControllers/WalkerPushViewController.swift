//
//  WalkerPushViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class WalkerPushViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PushViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let separator = UIView().then {
        $0.backgroundColor = .neutral3
    }
    private let walkPushSwitchView = PushSwitchView(message: "산책 알림 수신", description: "채팅, 매칭, 산책 관련 알림은 필수입니다.", isRequired: true)
    
    private let findWalkPushSwitchView = PushSwitchView(message: "주변 산책 알림", description: "")
    
    private let optionalPushSwitchView = PushSwitchView(message: "선택 알림 수신", description: "이벤트, 혜택, 기타 소식 받기")
    
    private let contentView = UIView()
    
    private let tipLabel = UILabel().then {
        $0.text = "TIP"
    }
    
    private let contentLabel = UILabel().then {
        $0.text = """
"내 주변 산책 알림 받기” 를 하시면, 따로 앱에 접속해서
번거롭게 확인하지 않으셔도

주변 동네에서 산책 요청이 있을 때 알려드려요 !
"""
    }
    
    private let saveButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("저장", for: .normal)
    }
    
    init(viewModel: PushViewModel) {
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
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("알림 설정")
        viewModel.getPushAlertSetting()
        requestPermissionsIfNeeded([.notification]) { [weak self] isPermit in
            guard let self = self else { return }
            if isPermit {
              
            } else {
                present(PermissionBlockModalViewController(message: "알림을 활성화 하기 위해서는 권한이 필요합니다.\n설정으로 이동해서 알림 권한을 확성화 해주세요"), animated: true)
            }
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$pushAlertSetting.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let self = self, let response = response else { return }
            if let range = response.newWalkRange, let address = response.newWalkAddress, response.newWalk == true {
                findWalkPushSwitchView.setDescription(message: "\(address), \(range.koreanDescription)")
            } else {
                findWalkPushSwitchView.setDescription(message: "[꺼져있음]")
            }
            optionalPushSwitchView.setSwitch(isOn: response.marketing)
            findWalkPushSwitchView.setSwitch(isOn: response.newWalk)
        }.store(in: &subscriptions)
        
        findWalkPushSwitchView.isOnPublisher.sink { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                navigationController?.pushViewController(PushRangeViewController(viewModel: viewModel), animated: true)
            } else {
                viewModel.modifyRequest?.newWalk = false
            }
        }.store(in: &subscriptions)
        
        optionalPushSwitchView.isOnPublisher.sink { [weak self] isOn in
            self?.viewModel.modifyRequest?.marketing = isOn
        }.store(in: &subscriptions)
        
        viewModel.modifySuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            ToastMessenger.shared.showToast(message: "수정이 완료되었습니다.")
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
    }
}

extension WalkerPushViewController {
    @objc private func saveButtonTapped() {
        viewModel.modifyPushAlertSetting()
    }
}

extension WalkerPushViewController {
    
    private func setupLayOuts() {
        [separator, walkPushSwitchView, findWalkPushSwitchView, optionalPushSwitchView, contentView, saveButton].forEach {
            view.addSubview($0)
        }
        [tipLabel, contentLabel].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        separator.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        walkPushSwitchView.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom)
            $0.height.equalTo(48)
            $0.horizontalEdges.equalToSuperview()
        }
        findWalkPushSwitchView.snp.makeConstraints {
            $0.top.equalTo(walkPushSwitchView.snp.bottom)
            $0.height.equalTo(48)
            $0.horizontalEdges.equalToSuperview()
        }
        optionalPushSwitchView.snp.makeConstraints {
            $0.top.equalTo(findWalkPushSwitchView.snp.bottom)
            $0.height.equalTo(48)
            $0.horizontalEdges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(optionalPushSwitchView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        tipLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(tipLabel.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview().inset(16)
        }
        saveButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        contentView.backgroundColor = ColorSet.fromHex("FFF8D6")
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        tipLabel.textColor = ColorSet.fromHex("918130")
        tipLabel.font = FontSet.pretendardBold(size: 14)
        contentLabel.textColor = ColorSet.fromHex("918130")
        contentLabel.font = FontSet.pretendardMedium(size: 12)
        contentLabel.numberOfLines = 0
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

