//
//  WalkerCancelWalkModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/30/25.
//

import Combine
import UIKit

final class WalkerCancelWalkModalViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: WalkerWalkDetailViewModel
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "매칭 취소"
    }
    private let subMessageLabel = UILabel().then {
        $0.text = "매칭을 취소하시겠습니까?\n취소시 수수료가 발생할 수 있습니다."
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let containerView = UIView()
    
    
    private let timeGuideLabel = UILabel().then {
        $0.text = "산책 예정 시각"
    }
    
    private let timeLabel = UILabel()
    
    private let penaltyGuideLabel = UILabel().then {
        $0.text = "페널티"
    }
    
    private let penaltyLabel = UILabel()
    
    private let reasonLabel = UILabel().then {
        $0.text = "견주에게 정중한 사과와 함께 매칭 취소 사유를 알려주세요"
    }
    
    private let textField = CustomTextField(placeholder: "매칭 취소 사유")
    
    private let cancelWalkButton = DangerButton(isSelected: false).then {
        $0.setTitle("매칭 취소하기", for: .normal)
    }
    
    init(viewModel: WalkerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelWalkButton.addTarget(self, action: #selector(cancelWalkButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func bind() {
        viewModel.$penaltyResponse.receive(on: DispatchQueue.main).sink { [weak self] info in
            guard let self = self, let info = info else { return }
            let date = info.startAt.extractDateComponentsFromISO()
            timeLabel.text = "\(date.year)-\(date.month)-\(date.day) \(date.hour):\(date.minute)"
            penaltyLabel.text = "\(info.penalty.formattedWithComma)원"
        }.store(in: &subscriptions)
        
        textField.textPublisher.sink { [weak self] text in
            self?.viewModel.cancelWalkRequest.reason = text
            self?.cancelWalkButton.setupButtonStatus(isSelected: !text.isEmpty)
        }.store(in: &subscriptions)
    }
}

extension WalkerCancelWalkModalViewController {
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func cancelWalkButtonTapped() {
        viewModel.cancelWalk()
        dismiss(animated: true)
    }
    
}

extension WalkerCancelWalkModalViewController {
    private func setupLayOuts() {
        view.addSubview(modalView)
        [messageLabel, subMessageLabel, containerView, reasonLabel, textField, cancelButton, cancelWalkButton].forEach {
            modalView.addSubview($0)
        }
        [timeGuideLabel, timeLabel, penaltyGuideLabel, penaltyLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        modalView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(messageLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        reasonLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(16)
        }
        textField.snp.makeConstraints {
            $0.top.equalTo(reasonLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(34)
        }
        cancelWalkButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-16)
        }
        timeGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeGuideLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
        penaltyGuideLabel.snp.makeConstraints {
            $0.top.equalTo(timeGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(timeGuideLabel)
        }
        penaltyLabel.snp.makeConstraints {
            $0.centerY.equalTo(penaltyGuideLabel)
            $0.trailing.equalTo(timeLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 20)
        subMessageLabel.textColor = .neutral11
        subMessageLabel.font = FontSet.pretendardMedium(size: 14)
        [timeGuideLabel, timeLabel, penaltyGuideLabel, penaltyLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 12)
        }
        penaltyLabel.textColor = .error1
        reasonLabel.textColor = .dark
        reasonLabel.font = FontSet.pretendardMedium(size: 12)
        containerView.backgroundColor = .neutral3
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        view.backgroundColor = ColorSet.fromHex("434343").withAlphaComponent(0.7)
    }
}
