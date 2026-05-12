//
//  WalkerRequireView.swift
//  PetPath
//
//  Created by 김나훈 on 7/9/25.
//

import Combine
import UIKit

final class WalkerRequireView: UIView {
    let trainTapPublisher = PassthroughSubject<Void, Never>()
    let newWalkTapPublisher = PassthroughSubject<Void, Never>()
    
    private let titleLabel = UILabel().then {
        $0.text = "워커 활동 필수사항"
    }
    private let trainView = UIView()
    
    private let trainImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "dogFoot")
    }
    
    private let trainLabel = UILabel().then {
        $0.text = "워커 교육 이수"
    }
    
    private let trainTextLabel = UILabel().then {
        $0.text = "워커 교육을 이수하지 않으면 산책에 지원할 수 없어요.\n지금 바로 교육을 완료하고 산책 지원에 참여해보세요!"
    }
    
    private let chevronImageView1 = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    private let newWalkView = UIView()

    private let newWalkImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "dogFoot")
    }
    private let newWalkLabel = UILabel().then {
        $0.text = "신규 산책 알림 설정"
    }
    private let newWalkTextLabel = UILabel().then {
        $0.text = "현재 견주를 열심히 모집하고 있어요!\n새로운 산책요청이 있다면 알려드릴게요! (선택)"
    }
    private let chevronImageView3 = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        bind()
        let trainTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTrainView))
        trainView.addGestureRecognizer(trainTapGesture)
        trainView.isUserInteractionEnabled = true
        
        let newWalkTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapNewWalkView))
        newWalkView.addGestureRecognizer(newWalkTapGesture)
        newWalkView.isUserInteractionEnabled = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func didTapTrainView() {
        trainTapPublisher.send()
    }

    @objc private func didTapNewWalkView() {
        newWalkTapPublisher.send()
    }
    
    func setup(trainSuccess: Bool, newWalkSuccess: Bool) {
        trainView.isHidden = trainSuccess
        newWalkView.isHidden = newWalkSuccess

        trainView.snp.removeConstraints()
        newWalkView.snp.removeConstraints()

        var lastView: UIView = titleLabel
        let spacing: CGFloat = 16
        let activeViews: [UIView] = [
            trainSuccess ? nil : trainView,
            newWalkSuccess ? nil : newWalkView
        ].compactMap { $0 }

        for view in activeViews {
            view.snp.makeConstraints {
                $0.top.equalTo(lastView.snp.bottom).offset(spacing)
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(96)
            }
            lastView = view
        }

        if let last = activeViews.last {
            last.snp.makeConstraints {
                $0.bottom.equalToSuperview()
            }
        }
    }
    
    private func bind() {
        
    }
}

extension WalkerRequireView {
    private func setupLayouts() {
        [titleLabel, trainView, newWalkView].forEach {
            self.addSubview($0)
        }
        [trainImageView, trainLabel, trainTextLabel, chevronImageView1].forEach {
            trainView.addSubview($0)
        }
        [newWalkImageView, newWalkLabel, newWalkTextLabel, chevronImageView3].forEach {
            newWalkView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        trainView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(96)
            $0.bottom.equalToSuperview()
        }
        trainImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        trainLabel.snp.makeConstraints {
            $0.centerY.equalTo(trainImageView)
            $0.leading.equalTo(trainImageView.snp.trailing).offset(2)
        }
        trainTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.trailing.equalTo(chevronImageView1.snp.leading).offset(-8)
        }
        chevronImageView1.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        newWalkImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        newWalkLabel.snp.makeConstraints {
            $0.centerY.equalTo(newWalkImageView)
            $0.leading.equalTo(newWalkImageView.snp.trailing).offset(2)
        }
        newWalkTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.trailing.equalTo(chevronImageView3.snp.leading).offset(-8)
        }
        chevronImageView3.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
    }
    private func setupComponents() {
        titleLabel.textColor = .dark
        titleLabel.font = FontSet.pretendardBold(size: 14)
        [trainLabel, newWalkLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardSemiBold(size: 14)
        }
        [trainTextLabel, newWalkTextLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardMedium(size: 12)
            $0.numberOfLines = 0
        }
        [newWalkView, trainView].forEach {
            $0.backgroundColor = ColorSet.fromHex("FFFCE6")
            $0.layer.cornerRadius = 14
            $0.layer.masksToBounds = true
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
