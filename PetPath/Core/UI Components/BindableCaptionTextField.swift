//
//  BindableCaptionTextField.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import Combine
import UIKit

/// 라벨과 텍스트 필드를 포함하는 커스텀 뷰
final class BindableCaptionTextField: UIView {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []

    /// 입력 필드 상태 변화
    let statePublisher = PassthroughSubject<BindableTextField.TextFieldState, Never>()
    let textPublisher = PassthroughSubject<String, Never>()

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 12)
        $0.textColor = ColorSet.neutral6
    }

    private let textField: BindableTextField
    
    private let captionImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "caption")
        $0.isHidden = true
    }
    
    private let captionLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 10)
        $0.isHidden = true
    }
    
    // MARK: - Init
    init(title: String, mode: BindableTextField.TextFieldMode = .common) {
        self.textField = BindableTextField(mode: mode)
        super.init(frame: .zero)
        
        titleLabel.text = title
        setupUI()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Binding
    private func bind() {
        textField.statePublisher
            .sink { [weak self] state in
                self?.applyState(state)
                self?.statePublisher.send(state)
            }.store(in: &subscriptions)
        
        textField.textPublisher.sink { [weak self] text in
            self?.captionLabel.isHidden = true
            self?.captionImageView.isHidden = true
            self?.textPublisher.send(text)
        }.store(in: &subscriptions)
    }
    
    // MARK: - UI 업데이트
    private func applyState(_ state: BindableTextField.TextFieldState, captionText: String? = nil) {
        switch state {
        case .normal:
            titleLabel.textColor = ColorSet.neutral6
            textField.layer.borderColor = ColorSet.neutral6.cgColor
            captionLabel.textColor = ColorSet.neutral6
        case .focused:
            titleLabel.textColor = ColorSet.neutral10
            textField.layer.borderColor = ColorSet.neutral10.cgColor
            captionLabel.textColor = ColorSet.neutral10
        case .error:
            titleLabel.textColor = ColorSet.error1
            textField.layer.borderColor = ColorSet.error1.cgColor
            captionLabel.textColor = ColorSet.error1
        case .success:
            titleLabel.textColor = ColorSet.tertiary
            textField.layer.borderColor = ColorSet.tertiary.cgColor
            captionLabel.textColor = ColorSet.tertiary
        }
        captionLabel.isHidden = state == .normal || state == .focused
        captionImageView.isHidden = state == .normal || state == .focused
    }

    // MARK: - UI 세팅
    private func setupUI() {
        [titleLabel, textField, captionImageView, captionLabel].forEach {
            addSubview($0)
        }
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(14)
        }
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(37)
        }
        captionImageView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(5)
            $0.leading.equalTo(textField.snp.leading).offset(4)
            $0.width.equalTo(12.22)
            $0.height.equalTo(12)
        }
        captionLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.leading.equalTo(captionImageView.snp.trailing).offset(4)
        }
    }
    
    // MARK: - 외부에서 상태 변경 가능하도록 설정
    
    func setState(success: Bool) {
        textField.setState(success: success)
        captionLabel.isHidden = success
        captionImageView.isHidden = success
    }
    func setState(state: BindableTextField.TextFieldState) {
        textField.setState(state: state)
        captionLabel.isHidden = state == .normal
        captionImageView.isHidden = state == .normal
    }
    
    func setPlaceHolder(text: String) {
        textField.placeholder = text
    }
    func setCaptionText(text: String) {
        captionLabel.text = text
    }
}
