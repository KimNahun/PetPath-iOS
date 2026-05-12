//
//  MatchedWalkerView.swift
//  PetPath
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class MatchedWalkerView: UIView {
   
    private let viewModel: OwnerWalkDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private let titleLabel = UILabel().then {
        $0.text = "매칭 워커"
    }
    
    private let contentView = UIView()
    
    private let walkerImageView = AspectFitImageView()
    
    private let walkerInfoLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    private let separatorView = UIView()
    
    init(viewModel: OwnerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.$matchedWalkerinfo.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] item in
            guard let item = item else { return }
            self?.walkerImageView.loadImage(url: item.profileImage)
            self?.walkerInfoLabel.text = "\(item.walkerName)(\(item.gender.koreanDescription)/\(item.age)세)"
            self?.descriptionLabel.text = item.description
        }.store(in: &subscriptions)
    }
}

extension MatchedWalkerView {
    private func setupLayouts() {
        [titleLabel, contentView, separatorView].forEach {
            self.addSubview($0)
        }
        [walkerImageView, walkerInfoLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(21)
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(8)
            $0.height.equalTo(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        walkerImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(50)
        }
        walkerInfoLabel.snp.makeConstraints {
            $0.top.equalTo(walkerImageView)
            $0.leading.equalTo(walkerImageView.snp.trailing).offset(8)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(walkerImageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    private func setupComponents() {
        walkerImageView.backgroundColor = .neutral6
        walkerImageView.layer.masksToBounds = true
        walkerImageView.layer.cornerRadius = 25
        
        titleLabel.textColor = .neutral11
        titleLabel.font = FontSet.pretendardBold(size: 18)
        walkerInfoLabel.textColor = .neutral11
        walkerInfoLabel.font = FontSet.pretendardBold(size: 16)
        
        descriptionLabel.textColor = .dark
        descriptionLabel.font = FontSet.pretendardMedium(size: 12)
        descriptionLabel.numberOfLines = 0
        
        separatorView.backgroundColor = .neutral3
        
        contentView.setupShadow()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
