//
//  BindableTextFieldView.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit

/// 라벨과 텍스트 필드를 포함하는 커스텀 뷰
final class BindableTextFieldView: UIView {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []

    /// 입력 필드 상태 변화
    private let textFieldState = PassthroughSubject<BindableTextField.TextFieldState, Never>()
    let textPublisher = PassthroughSubject<String, Never>()

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 12)
        $0.textColor = ColorSet.neutral6
    }

    private let textField: BindableTextField
    
    // MARK: - Init
    init(title: String, mode: BindableTextField.TextFieldMode = .common, numberPad: Bool = false) {
        self.textField = BindableTextField(mode: mode)
        if numberPad {
            textField.keyboardType = .numberPad
        }
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
            }.store(in: &subscriptions)
        textField.textPublisher.sink { [weak self] text in
            self?.textPublisher.send(text)
        }.store(in: &subscriptions)
    }
    
    // MARK: - UI 업데이트
    private func applyState(_ state: BindableTextField.TextFieldState) {
        switch state {
        case .normal:
            titleLabel.textColor = ColorSet.neutral6
            textField.layer.borderColor = ColorSet.neutral6.cgColor
        case .focused:
            titleLabel.textColor = ColorSet.neutral10
            textField.layer.borderColor = ColorSet.neutral10.cgColor
        case .error:
            titleLabel.textColor = ColorSet.error1
            textField.layer.borderColor = ColorSet.error1.cgColor
        case .success:
            titleLabel.textColor = ColorSet.tertiary
            textField.layer.borderColor = ColorSet.tertiary.cgColor
        }
    }

    // MARK: - UI 세팅
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(textField)

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(14)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 외부에서 상태 변경 가능하도록 설정
    func setState(success: Bool) {
        textField.setState(success: success)
    }
    
    func setState(state: BindableTextField.TextFieldState) {
        textField.setState(state: state)
    }
    
    func setPlaceHolder(text: String) {
        textField.placeholder = text
    }
    func setText(text: String) {
        textField.text = text
    }
    func getText() -> String {
        return textField.text ?? ""
    }
}
