//
//  OwnerRequireView.swift
//  PetPath
//
//  Created by 김나훈 on 7/13/25.
//

import Combine
import UIKit

final class OwnerRequireView: UIView {
    let cardTapPublisher = PassthroughSubject<Void, Never>()
    let dogTapPublisher = PassthroughSubject<Void, Never>()
    
    private let titleLabel = UILabel().then {
        $0.text = "산책 요청 필수사항"
    }
    private let dogView = UIView()
    
    private let dogImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "dogFoot")
    }
    
    private let dogLabel = UILabel().then {
        $0.text = "강아지 등록"
    }
    
    private let dogTextLabel = UILabel().then {
        $0.text = "산책할 강아지를 먼저 등록해 주세요!\n강아지 정보를 참고해서 워커가 산책을 진행해요."
    }
    
    private let chevronImageView1 = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    private let cardView = UIView()
    
    private let cardImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "dogFoot")
    }
    
    private let cardLabel = UILabel().then {
        $0.text = "결제수단 등록"
    }
    
    private let cardTextLabel = UILabel().then {
        $0.text = "산책 신청 전에 결제수단을 등록해 주세요.\n등록 후에는 간편하게 서비스를 이용할수 있어요!"
    }
    
    private let chevronImageView2 = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronRight")
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        bind()
        let trainTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTrainView))
        dogView.addGestureRecognizer(trainTapGesture)
        dogView.isUserInteractionEnabled = true

        let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCardView))
        cardView.addGestureRecognizer(cardTapGesture)
        cardView.isUserInteractionEnabled = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func didTapTrainView() {
        dogTapPublisher.send()
    }

    @objc private func didTapCardView() {
        cardTapPublisher.send()
    }
    
    func setup(dogSuccess: Bool, cardSuccess: Bool) {
        dogView.isHidden = dogSuccess
        cardView.isHidden = cardSuccess

        dogView.snp.removeConstraints()
        cardView.snp.removeConstraints()

        if !dogSuccess && !cardSuccess {
            dogView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(96)
            }
            cardView.snp.makeConstraints {
                $0.top.equalTo(dogView.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(96)
                $0.bottom.equalToSuperview()
            }
        } else if !dogSuccess && cardSuccess {
            dogView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(96)
                $0.bottom.equalToSuperview()
            }
        } else if dogSuccess && !cardSuccess {
            cardView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(96)
                $0.bottom.equalToSuperview()
            }
        }
    }
    
    private func bind() {
        
    }
}

extension OwnerRequireView {
    private func setupLayouts() {
        [titleLabel, dogView, cardView].forEach {
            self.addSubview($0)
        }
        [dogImageView, dogLabel, dogTextLabel, chevronImageView1].forEach {
            dogView.addSubview($0)
        }
        [cardImageView, cardLabel, cardTextLabel, chevronImageView2].forEach {
            cardView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        dogView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(96)
        }
        cardView.snp.makeConstraints {
            $0.top.equalTo(dogView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(96)
            $0.bottom.equalToSuperview()
        }
        dogImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        dogLabel.snp.makeConstraints {
            $0.centerY.equalTo(dogImageView)
            $0.leading.equalTo(dogImageView.snp.trailing).offset(2)
        }
        dogTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.trailing.equalTo(chevronImageView1.snp.leading).offset(-8)
        }
        chevronImageView1.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        cardImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        cardLabel.snp.makeConstraints {
            $0.centerY.equalTo(cardImageView)
            $0.leading.equalTo(cardImageView.snp.trailing).offset(2)
        }
        cardTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.trailing.equalTo(chevronImageView2.snp.leading).offset(-8)
        }
        chevronImageView2.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
    }
    private func setupComponents() {
        titleLabel.textColor = .dark
        titleLabel.font = FontSet.pretendardBold(size: 14)
        [dogLabel, cardLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardSemiBold(size: 14)
        }
        [dogTextLabel, cardTextLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardMedium(size: 12)
            $0.numberOfLines = 0
        }
        [cardView, dogView].forEach {
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
