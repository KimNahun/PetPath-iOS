//
//  CardExpiryView.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class CardExpiryView: UIView {
    
    // MARK: Properties
    let finishPublisher = PassthroughSubject<Void, Never>()
    private let viewModel: AddCardViewModel
    
    // MARK: - UI Components
    private let expiryGuideLabel = UILabel().then {
        $0.text = "카드 유효기간"
        $0.textColor = .neutral6
        $0.font = FontSet.pretendardBold(size: 12)
    }
    private let monthTextField = BindableTextField(numberPad: true).then {
        $0.placeholder = "월(2자리)"
    }
    private let yearTextField = BindableTextField(numberPad: true).then {
        $0.placeholder = "년(4자리)"
    }
    private lazy var textFields: [UITextField] = [monthTextField, yearTextField]
    
    init(viewModel: AddCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func focusTextField() {
        monthTextField.becomeFirstResponder()
    }
}

extension CardExpiryView {
    private func setupLayouts() {
        [expiryGuideLabel, monthTextField, yearTextField].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        expiryGuideLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        monthTextField.snp.makeConstraints {
            $0.top.equalTo(expiryGuideLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.width.equalTo(104)
            $0.height.equalTo(40)
        }
        yearTextField.snp.makeConstraints {
            $0.top.equalTo(expiryGuideLabel.snp.bottom).offset(4)
            $0.leading.equalTo(monthTextField.snp.trailing).offset(8)
            $0.width.equalTo(104)
            $0.height.equalTo(40)
        }
    }
    
    private func setupComponents() {
        textFields.forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            $0.delegate = self
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}

extension CardExpiryView: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let maxCount = textField == monthTextField ? 2 : 4
        guard let text = textField.text else { return }
        
        if text.count > maxCount {
            textField.text = String(text.prefix(maxCount))
        }
        
        if text.count == maxCount {
            moveToNextTextField(currentTextField: textField)
        }
        viewModel.addCardForm.expiryYear = yearTextField.text ?? ""
        viewModel.addCardForm.expiryMonth = monthTextField.text ?? ""
    }
    
    private func moveToNextTextField(currentTextField: UITextField) {
        if currentTextField == monthTextField {
            yearTextField.becomeFirstResponder()
        } else if currentTextField == yearTextField {
            currentTextField.resignFirstResponder()
            finishPublisher.send()
        }
    }
}
