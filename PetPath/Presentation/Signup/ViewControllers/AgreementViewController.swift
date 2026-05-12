//
//  AgreementViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Combine
import UIKit

final class AgreementViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private let inputSubject: PassthroughSubject<SignUpViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let agreementLabel = UILabel().then {
        $0.setTitleBold(text: "원활한 산책 환경 조성을 위해\n서비스 이용에 동의해주세요!")
        $0.numberOfLines = 2
    }
    private let allAgreementView = UIView().then {
        $0.backgroundColor = ColorSet.neutral4
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = ColorSet.dark.cgColor
    }
    
    private let allAgreementButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox"), for: .normal)
        $0.setImage(UIImage(named: "checkboxFill"), for: .selected)
    }
    
    private let allAgreementTitleLabel = UILabel().then {
        $0.text = "약관 전체 동의"
        $0.font = FontSet.pretendardSemiBold(size: 12)
        $0.textColor = ColorSet.dark
        $0.isUserInteractionEnabled = true
    }
    private let allAgreementContentLabel = UILabel().then {
        $0.text = "전체 약관에 동의합니다."
        $0.font = FontSet.pretendardSemiBold(size: 10)
        $0.textColor = ColorSet.gray500
        $0.isUserInteractionEnabled = true
    }
    
    private let locationAgreementView = AgreementView(text: "위치기반 서비스 이용약관(필수)").then { _ in }
    
    private let serviceAgreementView = AgreementView(text: "서비스 이용약관(필수)").then { _ in }
    
    private let personalInformationAgreementView = AgreementView(text: "개인정보 처리 방침(필수)").then { _ in }
    
    private let marketingAgreementView = AgreementView(text: "마케팅 정보 이용 동의(선택)").then { _ in }
    
    private let nextButton = BottomPlacedButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    init(viewModel: SignUpViewModel) {
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
        setNavigationRightButtons(keys: ["cancel"])
        bind()
        allAgreementButton.addTarget(self, action: #selector(allAgreementButtonTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(allAgreementButtonTapped))
        allAgreementTitleLabel.addGestureRecognizer(tap)
        allAgreementContentLabel.addGestureRecognizer(tap)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("회원가입")
    }
    
    // MARK: - Bind
    
    private func bind() {
        navigationButtonPublisher(for: "cancel")
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([SignInViewController(viewModel: .init())], animated: false)
            }.store(in: &subscriptions)
        
        let outputPublisher = viewModel.agreementTransform(with: inputSubject.eraseToAnyPublisher())
        
        outputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case let .toggleNextButton(isEnabled):
                    self.nextButton.setupButtonStatus(isSelected: isEnabled)
                case let .updateAllAgreementButton(isSelected):
                    self.allAgreementButton.isSelected = isSelected
                    self.updateAllAgreementViewStyle(isSelected: isSelected)
                case let .updateAgreementStates(states):
                    self.updateAgreementButtons(states: states)
                }
            }.store(in: &subscriptions)
        
        bindAgreementView(locationAgreementView, index: 0)
        bindAgreementView(serviceAgreementView, index: 1)
        bindAgreementView(personalInformationAgreementView, index: 2)
        bindAgreementView(marketingAgreementView, index: 3)
        
        locationAgreementView.detailButtonPublisher.sink {
            if let url = UrlManager.location.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
        
        serviceAgreementView.detailButtonPublisher.sink {
            if let url = UrlManager.service.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
        
        personalInformationAgreementView.detailButtonPublisher.sink {
            if let url = UrlManager.privacy.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
        
        marketingAgreementView.detailButtonPublisher.sink {
            if let url = UrlManager.marketing.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
    }
    
}

extension AgreementViewController {
    @objc private func nextButtonTapped() {
        let viewController = SignupCertificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func bindAgreementView(_ agreementView: AgreementView, index: Int) {
        agreementView.agreementPublisher
            .sink { [weak self] isSelected in
                self?.inputSubject.send(.toggleAgreement(index: index, isSelected: isSelected))
            }
            .store(in: &subscriptions)
    }
    
    private func updateAgreementButtons(states: [Bool]) {
        locationAgreementView.setButtonStatus(isSelected: states[0])
        serviceAgreementView.setButtonStatus(isSelected: states[1])
        personalInformationAgreementView.setButtonStatus(isSelected: states[2])
        marketingAgreementView.setButtonStatus(isSelected: states[3])
    }
    
    private func updateAllAgreementViewStyle(isSelected: Bool) {
        allAgreementView.backgroundColor = isSelected ? ColorSet.primary100 : ColorSet.neutral4
        allAgreementView.layer.borderWidth = isSelected ? 0 : 1.0
    }
    @objc private func allAgreementButtonTapped() {
        let isSelected = !allAgreementButton.isSelected
        inputSubject.send(.toggleAllAgreements(isSelected))
    }
}

extension AgreementViewController {
    
    private func setupLayOuts() {
        [agreementLabel, allAgreementView, locationAgreementView, serviceAgreementView, personalInformationAgreementView, marketingAgreementView, nextButton].forEach {
            view.addSubview($0)
        }
        [allAgreementButton, allAgreementTitleLabel, allAgreementContentLabel].forEach {
            allAgreementView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        agreementLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(63)
        }
        allAgreementView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(locationAgreementView.snp.top).offset(-24)
            $0.height.equalTo(48)
        }
        allAgreementButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(24)
        }
        allAgreementTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(allAgreementButton.snp.trailing).offset(4)
        }
        allAgreementContentLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(allAgreementTitleLabel.snp.trailing).offset(4)
        }
        locationAgreementView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(serviceAgreementView.snp.top).offset(-24)
            $0.height.equalTo(24)
        }
        serviceAgreementView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(personalInformationAgreementView.snp.top).offset(-24)
            $0.height.equalTo(24)
        }
        personalInformationAgreementView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(marketingAgreementView.snp.top).offset(-24)
            $0.height.equalTo(24)
        }
        marketingAgreementView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(nextButton.snp.top).offset(-24)
            $0.height.equalTo(24)
        }
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
