//
//  SelectedWalkerContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class SelectedWalkerContentViewController: UIViewController {
    
    let selectPublisher = PassthroughSubject<Void, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let viewModel: OwnerWalkDetailViewModel
    
    private let messageLabel = UILabel().then {
        $0.text = "워커 선택하기"
    }
    private let profileImageView = AspectFitImageView()
    
    private let walkerInfoLabel = UILabel()
    
    private let priceGuideLabel = UILabel().then {
        $0.text = "제시 금액"
    }
    
    private let scrollView = UIScrollView()
    
    private let priceLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let selectButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("워커 선택하기", for: .normal)
    }
    
    init(viewModel: OwnerWalkDetailViewModel) {
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
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        
    }
    
    func configure(item: GetApplyWalkerListDTO) {
        profileImageView.loadImage(url: item.profileImage)
        walkerInfoLabel.text = "\(item.walkerName)(\(item.gender.koreanDescription)/\(item.age)세)"
        priceLabel.text = "\(item.price.formattedWithComma)원"
        descriptionLabel.text = item.description
    }
}
extension SelectedWalkerContentViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func selectButtonTapped() {
        selectPublisher.send()
    }
   
}

extension SelectedWalkerContentViewController {
    private func setupLayOuts() {
        [messageLabel, profileImageView, walkerInfoLabel, priceGuideLabel, priceLabel, scrollView, cancelButton, selectButton].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(50)
        }
        walkerInfoLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.height.equalTo(19)
        }
        priceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(walkerInfoLabel.snp.bottom).offset(4)
            $0.leading.equalTo(walkerInfoLabel)
            $0.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(priceGuideLabel)
            $0.leading.equalTo(priceGuideLabel.snp.trailing).offset(4)
            $0.height.equalTo(14)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(13)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(154)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        selectButton.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        descriptionLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(selectButton)
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
        
        descriptionLabel.textColor = .dark
        descriptionLabel.font = FontSet.pretendardMedium(size: 12)
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
