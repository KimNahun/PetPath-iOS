//
//  OwnerPushViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import UIKit

final class OwnerPushViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PushViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
  
    private let separator = UIView().then {
        $0.backgroundColor = .neutral3
    }
    private let walkPushSwitchView = PushSwitchView(message: "산책 알림 수신", description: "채팅, 매칭, 산책 관련 알림은 필수입니다.", isRequired: true)
    
    private let optionalPushSwitchView = PushSwitchView(message: "선택 알림 수신", description: "이벤트, 혜택, 기타 소식 받기")
    
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
        viewModel.getPushAlertSetting()
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("알림 설정")
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
            optionalPushSwitchView.setSwitch(isOn: response.marketing)
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

extension OwnerPushViewController {
    @objc private func saveButtonTapped() {
        viewModel.modifyPushAlertSetting()
    }
}

extension OwnerPushViewController {
    
    private func setupLayOuts() {
        [separator, walkPushSwitchView, optionalPushSwitchView, saveButton].forEach {
            view.addSubview($0)
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
        optionalPushSwitchView.snp.makeConstraints {
            $0.top.equalTo(walkPushSwitchView.snp.bottom)
            $0.height.equalTo(48)
            $0.horizontalEdges.equalToSuperview()
        }
        saveButton.snp.makeConstraints {
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

