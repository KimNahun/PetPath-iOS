//
//  BindableTextField.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import Combine
import UIKit

/// 상태 변화를 감지하는 UITextField
final class BindableTextField: UITextField, UITextFieldDelegate {
    
    /// 입력 필드 타입 (일반, 보안)
    enum TextFieldMode {
        case common   // 일반 텍스트
        case secure   // 항상 `***` 표시
    }
    
    /// 상태 변화를 알리기 위한 Publisher
    let statePublisher = PassthroughSubject<TextFieldState, Never>()
    let textPublisher = PassthroughSubject<String, Never>()
    
    /// 텍스트 필드 상태
    enum TextFieldState {
        case normal   // 기본 상태
        case focused  // 포커스 상태
        case error    // 에러 상태
        case success // 입력 완료
    }
    
    /// 현재 모드 (기본값: common)
    private let mode: TextFieldMode
    private var textFieldState: TextFieldState = .normal {
        didSet {
            applyState()
        }
    }
    
    /// 기본 스타일 설정
    private func setupUI() {
        self.borderStyle = .roundedRect
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 8
        self.layer.borderColor = ColorSet.neutral6.cgColor
        self.textColor = .black
        self.spellCheckingType = .no
        self.autocorrectionType = .no
        self.layer.masksToBounds = true
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: ColorSet.neutral6])
        self.leftViewMode = .always
        self.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)
        self.addTarget(self, action: #selector(textFieldDidBegin), for: .editingDidBegin)
    }
    
    /// 초기화 (기본 크기 적용 X)
    init(mode: TextFieldMode = .common, numberPad: Bool = false, font: UIFont = FontSet.pretendardMedium(size: 14), leftWidth: CGFloat = 4) {
        self.mode = mode
        super.init(frame: .zero)
        setupUI()
        if numberPad {
            self.keyboardType = .numberPad
        }
        self.isSecureTextEntry = mode == .secure
        self.delegate = self
        self.font = font
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: leftWidth, height: 0))
    }
    
    required init?(coder: NSCoder) {
        self.mode = .common
        super.init(coder: coder)
        setupUI()
        self.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // ✅ 키보드 내리기
        return true
    }
    
    /// 텍스트 필드 값이 변경될 때 호출
    @objc private func textDidChange() {
        guard let text = self.text else { return }
        textPublisher.send(text)
    }
    
    /// 포커스를 얻었을 때
    @objc private func textFieldDidBegin() {
        textFieldState = .focused
    }
    
    /// 포커스를 잃었을 때
    @objc private func textFieldDidEnd() {
        if textFieldState == .focused { textFieldState = .normal }
    }
    
    func setState(success: Bool) {
        if success { textFieldState = .success }
        else { textFieldState = .error }
    }
    func setState(state: TextFieldState) {
        textFieldState = state
    }
    
    /// 상태에 따른 UI 변경
    private func applyState() {
        switch textFieldState {
        case .normal:
            self.layer.borderColor = ColorSet.neutral6.cgColor
        case .focused:
            self.layer.borderColor = ColorSet.neutral10.cgColor
        case .error:
            self.layer.borderColor = ColorSet.error1.cgColor
        case .success:
            self.layer.borderColor = ColorSet.tertiary.cgColor
        }
        statePublisher.send(textFieldState)
    }
}

