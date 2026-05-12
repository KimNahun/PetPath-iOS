//
//  CustomTextField.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class CustomTextField: UITextField, UITextFieldDelegate {
    let textPublisher = PassthroughSubject<String, Never>()
    init(placeholder: String) {
        super.init(frame: .zero)
        setupUI(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(placeholder:) instead.")
    }
    
    private func setupUI(placeholder: String) {
        self.delegate = self
        self.font = FontSet.pretendardMedium(size: 12)
        self.tintColor = .neutral7
        self.textColor = .dark
        self.backgroundColor = .neutral4
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.spellCheckingType = .no
        self.autocorrectionType = .no
        self.placeholder = placeholder
        self.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 24))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // ✅ 키보드 내리기
        return true
    }
    @objc private func textChanged() {
           textPublisher.send(self.text ?? "")
       }
}
