//
//  CardPasswordView.swift
//  PetPath
//
//  Created by 김나훈 on 3/23/25.
//

import Combine
import UIKit

final class CardPasswordView: UIView {
    
    // MARK: Properties
    let finishPublisher = PassthroughSubject<Void, Never>()
    private let viewModel: AddCardViewModel
    
    // MARK: - UI Components
    private let passwordGuideLabel = UILabel().then {
        $0.text = "카드 비밀번호"
        $0.textColor = .neutral6
        $0.font = FontSet.pretendardBold(size: 12)
    }
    private let passwordTextField = BindableTextField(mode: .secure, numberPad: true).then {
        $0.placeholder = "앞 두자리"
    }
    init(viewModel: AddCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func focusTextField() {
        passwordTextField.becomeFirstResponder()
    }
}

extension CardPasswordView {
    private func setupLayouts() {
        [passwordGuideLabel, passwordTextField].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        passwordGuideLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordGuideLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.width.equalTo(104)
            $0.height.equalTo(40)
        }
    }
    
    private func setupComponents() {
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.delegate = self
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}

extension CardPasswordView: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 2 {
            textField.text = String(text.prefix(2))
        }
        
        if text.count == 2 {
            passwordTextField.resignFirstResponder()
            finishPublisher.send()
        }
        viewModel.addCardForm.pwd = textField.text ?? ""
    }
}
