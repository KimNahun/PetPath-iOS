//
//  CardBirthdayView.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import UIKit

final class CardBirthdayView: UIView {
    
    // MARK: Properties
    private let viewModel: AddCardViewModel
    
    // MARK: - UI Components
    private let birthdayGuideLabel = UILabel().then {
        $0.text = "생년월일"
        $0.textColor = .neutral6
        $0.font = FontSet.pretendardBold(size: 12)
    }
    
    private let yearTextField = BindableTextField(numberPad: true).then {
        $0.placeholder = "년(4자리)"
    }
    
    private let monthTextField = BindableTextField(numberPad: true).then {
        $0.placeholder = "월(2자리)"
    }
    
    private let dayTextField = BindableTextField(numberPad: true).then {
        $0.placeholder = "일(2자리)"
    }
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [yearTextField, monthTextField, dayTextField])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        return stackView
    }()
    
    private lazy var textFields: [UITextField] = [yearTextField, monthTextField, dayTextField]
    
    init(viewModel: AddCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func focusTextField() {
        yearTextField.becomeFirstResponder()
    }
}
extension CardBirthdayView {
    private func setupLayouts() {
        [birthdayGuideLabel, textFieldStackView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        birthdayGuideLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        textFieldStackView.snp.makeConstraints {
            $0.top.equalTo(birthdayGuideLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        textFields.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(40)
            }
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

extension CardBirthdayView: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == yearTextField, let text = textField.text, text.count > 4 {
            textField.text = String(text.prefix(4))
        }
        else if textField == monthTextField, let text = textField.text, text.count > 2 {
            textField.text = String(text.prefix(2))
        }
        
        if textField == yearTextField, textField.text?.count == 4 {
            monthTextField.becomeFirstResponder()
        }
        
        viewModel.addCardForm.birthYear = yearTextField.text ?? ""
        viewModel.addCardForm.birthMonth = monthTextField.text ?? ""
        viewModel.addCardForm.birthDay = dayTextField.text ?? ""
    }
}
