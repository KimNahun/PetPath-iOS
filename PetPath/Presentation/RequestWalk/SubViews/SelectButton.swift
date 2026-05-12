//
//  SelectButton.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import UIKit

final class SelectButton: UIButton {

    private let leftImageView = AspectFitImageView()
    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let guideLabel = UILabel()
    private let rightImageView = UIImageView(image: UIImage(named: "chevronRight"))

    init(title: String, leftImage: UIImage?) {
        super.init(frame: .zero)
        setupUI(title: title, leftImage: leftImage)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(title: String, leftImage: UIImage?) {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = .neutral3
        config.contentInsets = .zero
        self.configuration = config
        self.layer.cornerRadius = 15
        self.clipsToBounds = true

        leftImageView.image = leftImage
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.isHidden = leftImage == nil

        mainLabel.text = title
        mainLabel.font = FontSet.pretendardSemiBold(size: 14)
        mainLabel.textColor = .neutral10
        
        subLabel.font = FontSet.pretendardSemiBold(size: 14)
        subLabel.textColor = .neutral10
        subLabel.isHidden = true
        
        guideLabel.font = FontSet.pretendardSemiBold(size: 12)
        guideLabel.textColor = .neutral10
        guideLabel.isHidden = true

        rightImageView.contentMode = .scaleAspectFit

        [leftImageView, mainLabel, subLabel, guideLabel, rightImageView, guideLabel].forEach { addSubview($0) }

        leftImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(11)
            $0.size.equalTo(24)
        }
        mainLabel.snp.makeConstraints {
            $0.centerY.equalTo(leftImageView)
            if !leftImageView.isHidden { $0.leading.equalTo(leftImageView.snp.trailing).offset(10) }
            else { $0.leading.equalToSuperview().offset(11) }
            $0.trailing.lessThanOrEqualTo(rightImageView.snp.leading).offset(-8)
            $0.height.equalTo(leftImageView)
        }
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(11)
            $0.trailing.lessThanOrEqualTo(rightImageView.snp.leading)
            $0.height.equalTo(17)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(11)
            $0.trailing.lessThanOrEqualTo(rightImageView.snp.leading).offset(-8)
            $0.height.equalTo(14)
        }
        rightImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10.5)
            $0.size.equalTo(24)
        }
    }

    func updateText(mainText: String, subText: String, guideText: String? = nil) {
        mainLabel.text = mainText
        subLabel.text = subText
        subLabel.isHidden = false
        if let text = guideText {
            guideLabel.isHidden = false
            guideLabel.text = text
        }
    }

}
