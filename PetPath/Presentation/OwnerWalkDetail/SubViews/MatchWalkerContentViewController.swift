//
//  MatchWalkerContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import DropDown
import UIKit

final class MatchWalkerContentViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private let viewModel: OwnerWalkDetailViewModel
    
    private let messageLabel = UILabel().then {
        $0.text = "매칭하기"
    }
    private let profileImageView = AspectFitImageView()
    
    private let walkerInfoLabel = UILabel()
    
    private let priceGuideLabel = UILabel().then {
        $0.text = "제시 금액"
    }
    
    private let priceLabel = UILabel()
    
    private let feeGuideLabel = UILabel().then {
        $0.text = "제시 금액"
    }
    
    private let feeLabel = UILabel()
    
    private let couponGuideLabel = UILabel().then {
        $0.text = "쿠폰"
    }
    
    private let totalPriceGuideLabel = UILabel().then {
        $0.text = "최종 결제금액"
    }
    
    private let totalPriceLabel = UILabel()
    
    private let paymentLabel = UILabel().then {
        $0.text = "결제수단"
    }
    
    private let payAgreementView = AgreementView(text: "결제약관 동의").then { _ in }
    
    private let serviceAgreementView = AgreementView(text: "서비스 이용약관(필수)").then { _ in }
    
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let matchButton = BottomPlacedButton().then {
        $0.setTitle("결제 및 매칭하기", for: .normal)
    }
    private lazy var cardDropdownButton = DropdownButton(placeholder: "")
    private lazy var couponDropdownButton = DropdownButton(placeholder: "")
    
    init(viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        matchButton.addTarget(self, action: #selector(matchButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getCardList()
        viewModel.getAvailableCouponList()
        viewModel.getActualPayPrice()
    }
    
    private func bind() {
        viewModel.$cardList.receive(on: DispatchQueue.main).sink { [weak self] list in
            guard let self = self else { return }
            cardDropdownButton.setPlaceholder(list.isEmpty ? "결제 가능한 카드가 등록되어 있지 않습니다." : "카드 선택하기")
            cardDropdownButton.setDropdown(items: list.map {
                DropdownItem(id: $0.cardId, title: "\($0.cardVendor) \($0.firstNum)")
            })
        }.store(in: &subscriptions)
        
        viewModel.$couponList.receive(on: DispatchQueue.main).sink { [weak self] list in
            guard let self = self else { return }
            couponDropdownButton.setPlaceholder(list.isEmpty ? "적용할 수 있는 쿠폰이 없습니다." : "쿠폰 적용하기")
            let manualItem = DropdownItem(id: nil, title: "쿠폰 선택 안함")
            let mappedList = list.map {
                DropdownItem(id: String($0.pk), title: "\($0.description) \($0.amount)\($0.type == "sub" ? "원" : "%")")
            }
            let fullList = [manualItem] + mappedList
            couponDropdownButton.setDropdown(items: fullList)
        }.store(in: &subscriptions)
        
        viewModel.$getActualPayPriceResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let response = response else { return }
            self?.totalPriceLabel.text = "\(Int(response.totalPrice).formattedWithComma)원"
        }.store(in: &subscriptions)
        
        viewModel.$isMatchButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] enabled in
            self?.matchButton.setupButtonStatus(isSelected: enabled)
        }.store(in: &subscriptions)
        
        let views: [AgreementView] = [
            payAgreementView,
            serviceAgreementView
        ]
        
        for (index, view) in views.enumerated() {
            view.agreementPublisher
                .sink { [weak self] isChecked in
                    self?.viewModel.agreementChecks[index] = isChecked
                }.store(in: &subscriptions)
        }
        cardDropdownButton.selectedItemPublisher
            .sink { [weak self] item in
                self?.viewModel.matchWalkerRequest.payMethod = item.id ?? ""
            }.store(in: &subscriptions)
        
        couponDropdownButton.selectedItemPublisher
            .sink { [weak self] item in
                guard let self = self else { return }
                let request = viewModel.getActualPayPriceRequest
                let id = Int(item.id ?? "") ?? 0
                viewModel.matchWalkerRequest.coupon = id
                viewModel.getActualPayPriceRequest = .init(walk: request.walk, walker: request.walker, coupon: id)
            }.store(in: &subscriptions)
        
        payAgreementView.detailButtonPublisher.sink {
            if let url = UrlManager.payment.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
        
        serviceAgreementView.detailButtonPublisher.sink {
            if let url = UrlManager.service.url {
                UIApplication.shared.open(url)
            }
        }.store(in: &subscriptions)
    }
    
    func configure() {
        guard let item = viewModel.showingWalker else { return }
        profileImageView.loadImage(url: item.profileImage)
        walkerInfoLabel.text = "\(item.walkerName)(\(item.gender.koreanDescription)/\(item.age)세)"
        priceLabel.text = "\(item.price.formattedWithComma)원"
        feeLabel.text = "\(item.price.formattedWithComma)원"
        
    }
}
extension MatchWalkerContentViewController {
    @objc private func matchButtonTapped() {
        viewModel.matchWalker()
    }
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension MatchWalkerContentViewController {
    private func setupLayOuts() {
        [messageLabel, cancelButton, profileImageView, walkerInfoLabel, priceGuideLabel, priceLabel, feeGuideLabel, feeLabel, couponGuideLabel, couponDropdownButton, totalPriceGuideLabel, totalPriceLabel, paymentLabel, cardDropdownButton, payAgreementView, serviceAgreementView, matchButton
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(24)
            $0.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(50)
        }
        walkerInfoLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.height.equalTo(19)
        }
        priceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(walkerInfoLabel.snp.bottom).offset(4)
            $0.leading.equalTo(walkerInfoLabel)
            $0.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints {
            $0.centerY.equalTo(priceGuideLabel)
            $0.leading.equalTo(priceGuideLabel.snp.trailing).offset(4)
        }
        feeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(16)
        }
        feeLabel.snp.makeConstraints {
            $0.centerY.equalTo(feeGuideLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        couponGuideLabel.snp.makeConstraints {
            $0.top.equalTo(feeGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        couponDropdownButton.snp.makeConstraints {
            $0.top.equalTo(couponGuideLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        totalPriceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(couponDropdownButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        totalPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalPriceGuideLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        paymentLabel.snp.makeConstraints {
            $0.top.equalTo(totalPriceGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        
        cardDropdownButton.snp.makeConstraints {
            $0.top.equalTo(paymentLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        payAgreementView.snp.makeConstraints {
            $0.top.equalTo(cardDropdownButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        serviceAgreementView.snp.makeConstraints {
            $0.top.equalTo(payAgreementView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        matchButton.snp.makeConstraints {
            $0.top.equalTo(serviceAgreementView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
    }
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 20)
        profileImageView.backgroundColor = .neutral6
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 25
        
        walkerInfoLabel.textColor = .neutral11
        walkerInfoLabel.font = FontSet.pretendardBold(size: 16)
        
        priceGuideLabel.textColor = .neutral11
        priceGuideLabel.font = FontSet.pretendardMedium(size: 12)
        
        priceLabel.textColor = .secondary600
        priceLabel.font = FontSet.pretendardSemiBold(size: 12)
        [feeGuideLabel, couponGuideLabel, totalPriceGuideLabel, paymentLabel, paymentLabel].forEach {
            $0.textColor = .neutral9
            $0.font = FontSet.pretendardMedium(size: 14)
        }
        [feeLabel, totalPriceLabel].forEach {
            $0.textColor = .secondary500
            $0.font = FontSet.pretendardSemiBold(size: 14)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
