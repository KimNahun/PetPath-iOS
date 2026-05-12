//
//  CardNumberView.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class CardNumberView: UIView {
    
    // MARK: Properties
    let finishPublisher = PassthroughSubject<Void, Never>()
    private let viewModel: AddCardViewModel
    
    // MARK: - UI Components
    private let numberGuideLabel = UILabel().then {
        $0.text = "카드 번호"
        $0.textColor = .neutral6
        $0.font = FontSet.pretendardBold(size: 12)
    }
    private let firstTextField = BindableTextField(numberPad: true)
    private let secondTextField = BindableTextField(mode: .secure, numberPad: true)
    private let thirdTextField = BindableTextField(mode: .secure, numberPad: true)
    private let fourthTextField = BindableTextField(numberPad: true)
    private lazy var textFields: [UITextField] = [firstTextField, secondTextField, thirdTextField, fourthTextField]
       
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstTextField, secondTextField, thirdTextField, fourthTextField])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        return stackView
    }()
    
    private let messageLabel = UILabel().then {
        $0.text = "해당 카드 정보는 결제 대행사(나이스페이먼츠)를 통한 결제를 위해 필요한 정보입니다.\n\n해당 카드 정보는 결제 대행사(나이스페이먼츠)로 전달되며 펫워커에서는 입력한 카드정보를 저장하지 않습니다."
        $0.numberOfLines = 0
        $0.font = FontSet.pretendardRegular(size: 12)
        $0.textColor = .neutral7
    }
    
    init(viewModel: AddCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardNumberView {
    private func setupLayouts() {
        [numberGuideLabel, textFieldStackView, messageLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        numberGuideLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        textFieldStackView.snp.makeConstraints {
            $0.top.equalTo(numberGuideLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        [firstTextField, secondTextField, thirdTextField, fourthTextField].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(textFieldStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupComponents() {
        [firstTextField, secondTextField, thirdTextField, fourthTextField].forEach {
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

extension CardNumberView: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 4 {
            textField.text = String(text.prefix(4))
        }
        
        if text.count == 4 {
            moveToNextTextField(currentTextField: textField)
        }
        viewModel.addCardForm.cardParts = textFields.map { $0.text ?? "" }
    }
    
    private func moveToNextTextField(currentTextField: UITextField) {
        if let index = textFields.firstIndex(of: currentTextField), index < textFields.count - 1 {
            textFields[index + 1].becomeFirstResponder()
        } else {
            currentTextField.resignFirstResponder()
            finishPublisher.send()
        }
    }
    
}
