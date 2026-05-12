//
//  InquryContentTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import Combine
import UIKit

final class InquryContentTableViewCell: UITableViewCell {
    
    private let titleBackgroundView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.textColor = .dark
        $0.numberOfLines = 0
    }
    
    private let chevronImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "chevronDown")
    }
    
    private let answerBackgroundView = UIView().then {
        $0.backgroundColor = .neutral4
    }
    
    private let answerLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = FontSet.pretendardSemiBold(size: 10)
        $0.textAlignment = .left
        $0.textColor = .neutral11
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(text: String, isSelected: Bool, answer: String) {
        titleLabel.text = text
        chevronImageView.image = isSelected ? UIImage(named: "chevronRight") : UIImage(named: "chevronDown")
        answerLabel.text = answer
        answerBackgroundView.isHidden = !isSelected
        if isSelected {
            titleBackgroundView.snp.remakeConstraints {
                $0.top.horizontalEdges.equalToSuperview()
            }
            answerBackgroundView.snp.remakeConstraints {
                $0.top.equalTo(titleBackgroundView.snp.bottom)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        } else {
            titleBackgroundView.snp.remakeConstraints {
                $0.top.horizontalEdges.bottom.equalToSuperview()
            }
        }
    }
    
}

extension InquryContentTableViewCell {
   
}

extension InquryContentTableViewCell {
    private func setupLayouts() {
        [titleBackgroundView, answerBackgroundView].forEach {
            contentView.addSubview($0)
        }
        [titleLabel, chevronImageView].forEach {
            titleBackgroundView.addSubview($0)
        }
        answerBackgroundView.addSubview(answerLabel)
        
    }
    private func setupConstraints() {
        titleBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.bottom.equalToSuperview()
        }
        answerBackgroundView.snp.makeConstraints {
            $0.top.equalTo(titleBackgroundView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(9)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-4)
        }
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-7.57)
            $0.size.equalTo(19)
        }
        answerLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(7)
        }
    }
    private func setupComponents() {
        [titleBackgroundView, answerBackgroundView].forEach {
            $0.layer.borderColor = ColorSet.neutral6.cgColor
            $0.layer.borderWidth = 1.0
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}
