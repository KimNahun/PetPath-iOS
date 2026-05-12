//
//  SearchTextField.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import UIKit

final class SearchTextField: UITextField, UITextFieldDelegate {
    
    init(placeHolder: String) {
        super.init(frame: .zero)
        setupUI()
        self.placeholder = placeHolder
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        self.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // ✅ 키보드 내리기
        return true
    }
    
    
    
}
extension SearchTextField {
    private func setupUI() {
        self.font = FontSet.pretendardSemiBold(size: 12)
        self.tintColor = .neutral7
        self.textColor = .dark
        self.backgroundColor = .neutral4
        self.spellCheckingType = .no
        self.autocorrectionType = .no
        let imageView = UIImageView(image: UIImage(named: "magnifyingGlass"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 4, y: 0, width: 24, height: 24)
        let containerWidth: CGFloat = 4 + 24 + 4
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: 24))
        containerView.addSubview(imageView)
        imageView.center.y = containerView.bounds.midY
        self.leftView = containerView
        self.leftViewMode = .always
    }
}

