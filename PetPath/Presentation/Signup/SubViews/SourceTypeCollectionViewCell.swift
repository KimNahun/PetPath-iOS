//
//  SourceTypeCollectionViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 8/1/25.
//

import Combine
import UIKit

final class SourceTypeCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    var subscriptions = Set<AnyCancellable>()
    let agreementPublisher = PassthroughSubject<Bool, Never>()
    let textPublisher = PassthroughSubject<String, Never>()
    // MARK: - UI Components
    
    private let agreementView = AgreementView(text: "", showDetailButton: false)
        
    private let textField = BindableTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    private func bind() {
        agreementView.agreementPublisher.sink { [weak self] isSelected in
            self?.agreementPublisher.send(isSelected)
        }.store(in: &subscriptions)
        
        textField.textPublisher.sink { [weak self] text in
            self?.textPublisher.send(text)
        }.store(in: &subscriptions)
    }
    
    func configure(text: String, isSelected: Bool, message: String?, isFocusing: Bool) {
        bind()
        agreementView.setupText(text: text)
        agreementView.setButtonStatus(isSelected: isSelected)
        textField.isUserInteractionEnabled = isFocusing
        textField.isHidden = message == nil
        textField.text = message
        [agreementView, textField].forEach {
            $0.snp.removeConstraints()
        }
        if let _ = message {
            agreementView.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.top.equalToSuperview()
            }
            textField.snp.makeConstraints {
                $0.top.equalTo(agreementView.snp.bottom).offset(6)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview()
            }
        } else {
            agreementView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.horizontalEdges.equalToSuperview().inset(16)
            }
        }
    }
}

extension SourceTypeCollectionViewCell {
    private func setupUI() {
        [agreementView, textField].forEach {
            contentView.addSubview($0)
        }
    }
}
